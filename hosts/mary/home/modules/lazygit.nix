{ pkgs, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        edit = "nvim {{filename}}";
        editAtLine = "nvim +{{line}} {{filename}}";
      };
      git = {
        pagers = [
          {
            pager = "${pkgs.delta}/bin/delta --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format='lazygit-edit://{path}:{line}'";
          }
        ];
      };
      quitOnTopLevelReturn = true;
    };
  };

}
