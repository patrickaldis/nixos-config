{ config, lib, ... }:
let
  cfg = config.obsidian;

  tree = ../obsidian;

  # Caches that ../obsidian advertises but which only resolve from inside the
  # office: machines.nix derives substituters from the forwarded cache ports on
  # obsidian.webhop.org, and cache.nix offers the open-source S3 bucket. Every
  # build otherwise stalls waiting for them to time out.
  unreachableSubstituters = [
    "s3://obsidian-open-source"
    "http://obsidian.webhop.org:9150" # eris
    "http://obsidian.webhop.org:8950" # fileserver
    "http://obsidian.webhop.org:9050" # metis
  ];

  # ../obsidian is vendored verbatim from Obsidian Systems' nixos-configuration
  # repo, so none of its modules have an enable flag -- they all set config
  # unconditionally. This whole directory is import-tree'd into every host and
  # `imports` cannot depend on `config`, so rather than import the tree
  # conditionally we import it always and wrap each of its modules' config
  # section in cfg.enable. Option declarations are left alone: declaring
  # obsidian.staff and friends on a host that never enables this costs nothing.
  # The formals are the union of what the tree's modules ask for: the module
  # system injects arguments by inspecting a function's formals, so a bare
  # `args:` wrapper would be handed no pkgs. `args` must not be built out of
  # `config` either -- `imports` below would then force config while the module
  # list is still being collected, which is an infinite recursion.
  gate =
    m:
    { config, options, lib, pkgs, ... }@args:
    let
      module =
        let
          v = if lib.isPath m then import m else m;
        in
        if lib.isFunction v then v args else v;
      # Modules in the tree come in both forms: an explicit `config` attribute,
      # or the shorthand where the config sits at the top level.
      conf =
        if module ? config then
          module.config
        else
          removeAttrs module [
            "options"
            "imports"
            "_file"
            "key"
          ];
    in
    {
      options = module.options or { };
      imports = map gate (module.imports or [ ]);
      config = lib.mkIf cfg.enable conf;
    };
in
{
  imports = [
    # ./users is a separate entry point in the vendored tree: ./default.nix
    # deliberately does not pull it in.
    (gate tree)
    (gate (tree + "/users"))
  ];

  options.obsidian = {
    enable = lib.mkEnableOption "Obsidian Systems' work configuration (binary caches, build machines, staff accounts) from ../obsidian";
  };

  # An `apply` is the only hook that sees the merged list, and the definitions
  # we are undoing live inside the vendored tree we would rather not patch.
  options.nix.settings.substituters = lib.mkOption {
    apply = v: if cfg.enable then lib.lists.subtractLists unreachableSubstituters v else v;
  };
}
