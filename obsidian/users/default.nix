{ lib, config, options, ... }:

{
  # Extra per-user settings
  imports = [
    ./ryan.nix
    ./ali.nix

    # { users.users.aesteves = import ./aesteves.nix; }
    { users.users.cale = import ./cale.nix; }
    # { users.users.cnucera = import ./cnucera.nix; }
    # { users.users.dbornside = import ./dbornside.nix; }
    { users.users.dnarula = import ./dnarula.nix; }
    { users.users.hectorescobedo = import ./hectorescobedo.nix; }
    # { users.users.iraiyan = import ./iraiyan.nix; }
    { users.users.jcericson = import ./jcericson.nix; }
    # { users.users.jgibbons = import ./jgibbons.nix; }
    # { users.users.lokmanhossain = import ./lokmanhossain.nix; }
    # { users.users.lsmith = import ./lsmith.nix; }
    { users.users.mharaj = import ./mharaj.nix; }
    # { users.users.rpulella = import ./rpulella.nix; }
    # { users.users.tsmalley = import ./tsmalley.nix; }
    { users.users.luigyleon = import ./luigyleon.nix; }
    # { users.users.soquinn = import ./soquinn.nix; }
    # { users.users.rsvendsen = import ./rsvendsen.nix; }
    { users.users.dbirdi = import ./dbirdi.nix; }
    # { users.users.wfancher = import ./wfancher.nix; }
    # { users.users.hsiebenhandl = import ./hsiebenhandl.nix; }
    # { users.users.agarcia = import ./agarcia.nix; }
    # { users.users.gsprout = import ./gsprout.nix; }
    # { users.users.aliao = import ./aliao.nix; }
    { users.users.ymeister = import ./ymeister.nix; }
    { users.users.aleijnse = import ./aleijnse.nix; }
    { users.users.dgreen = import ./dgreen.nix; }
    # { users.users.dberman = import ./dberman.nix; }
    # { users.users.jpotter = import ./jpotter.nix; }
    { users.users.nhomesley = import ./nhomesley.nix; }
    # { users.users.eolive = import ./eolive.nix; }
    # { users.users.aohri = import ./aohri.nix; }
    { users.users.patrick = import ./patrick.nix; }

    ./nix-trusted-proxy.nix
    ./nix-untrusted-proxy.nix
  ];

  options = let
    inherit (lib) mkOption types;
  in {
    obsidian.staff = mkOption {
      description = "User IDs for employees of Obsidian";
      type = types.attrsOf lib.types.int;
      default = {
        cale = 1;
        colin = 2;
        # dan = 3;
        # samkhanna = 4;
        # carlossierra = 5;
        # ryanleddy = 6;
        # anupamjain = 7;
        hectorescobedo = 8;
        luigyleon = 9;
        # sidraval = 10;
        # shealevy = 11;
        # lokmanhossain = 12;
        jcericson = 13;
        ishaqsloan = 14;
        # kmicklas = 15;
        # aesteves = 16;
        # eacameron = 17;
        # mreinhart = 18;
        # iraiyan = 19;
        # sratnakumar = 20;
        # dbornside = 21;
        # tsmalley = 22;
        # sbrofeldt = 23;
        # hwong = 24;
        # jgibbons = 25;
        # jdeikun = 26;
        # jhartzell = 27;
        # mbauer = 28;
        # dsalz = 29;
        # cbetancourt = 30;
        # rklotzner = 32;
        # smondet = 33;
        # pnaik = 34;
        # vsagar = 35;
        # jhenry = 36;
        # aalmamun = 37;
        dnarula = 38;
        # sreza = 39;
        # cnucera = 40;
        # wfancher = 41;
        # ecardenas = 42;
        # mhasan = 43;
        # cjohnston = 44;
        # obatchelor = 45;
        # jmininger = 46;
        # jbetz = 47;
        nhomesley = 48;
        # lsmith = 49;
        # ariyandi = 50;
        # bkolera = 51;
        # schowdhury = 52;
        # tmorris = 53;
        # hkraebel = 54;
        schalmers = 55;
        # anunez = 56;
        # oshepherd = 57;
        mharaj = 58;
        # soquinn = 59;
        # sthiruchelvam = 60;
        # rsvendsen = 61;
        hsloan = 62;
        dbirdi = 63;
        # hsiebenhandl = 64;
        # rpulella = 65;
        mvanaken = 66;
        # gsprout = 67;
        ymeister = 68;
        agarcia = 69;
        # aliao = 70;
        aleijnse = 71;
        dgreen = 72;
        # jpotter = 73;
        # dberman = 74;
        # eolive = 75;
        # aohri = 76;
        patrick = 78;
      };
    };
    obsidian.services = mkOption {
      description = "User accounts for services run on obsidian";
      type = types.attrsOf (lib.types.submodule {
        options = {
          id = mkOption { type = types.int; };
          hashedPassword = mkOption { type = types.nullOr types.str; };
        };
      });
      default = {
        # wrinkl = {
        #   id = 1;
        #   hashedPassword = "$6$KGS5q9hleV$G2rbu.T3gFWzmKjnUzsl.fLygiesnCfW6tE5YLuZ98uPtaUzLXTHfn4jgUgRr1fBEj1K.IUCXxPTBwD5xDYeL.";
        # };
        ci = {
          id = 2;
          hashedPassword = "$6$NRF3r4aCdPWfOh9T$MBCu5FH5Nr./HofqnM5RvMmAwdZAd7qPyOqbCpsqP5.CF7rrvz4..xypIs1CDV7j6ksUezwj/wbaRphEwerkT0";
        };
        # stela = {
        #   id = 3;
        #   hashedPassword = "$6$5.sYB3IUXzLAC6$REm2yMnRLhqv126sZqjeSlW5/e9MafkMZoVXlviQvH.00./qnJ2cewxWO17nuK2Ch6UEUqI7ez8I8MYD9fDxc.";
        # };
        printer = {
          id = 4;
          hashedPassword = "$6$vppUdrzAdXLXSBB0$6Jr1phDni9i3rb0e3TOmCavrBtaBHw.r52p/qLDG.drib1hzqDJkcSzkAOzXpPLEI4wdmjp8muf.lhz4hMYvA.";
        };
        mattermost = {
          id = 5;
          hashedPassword = "$6$ua7mYi0BBIia$3pfFJb9/di/X46DDA5Z6toQZPjA5ScB/rjRjJfO1I77rvcvJZWz7U247PJhxS4CF4mf./qPWvWSMh/Ptb85bu0";
        };
        incoming = {
          id = 6;
          hashedPassword = "$6$M2vzKFQP6$2salNsbH5irSvbOWlKcoXBb/5UcmArzR675lILgOTvEjEYwlvS0/U.rJaw3yyXxV3PyJA6ZyPQqjMrrBuz7sr0";
        };
        calendar = {
          id = 7;
          hashedPassword = "$6$WguwTXW9gcIx$wzs75xaHK5XMf7dpXR5r6MajqJXROBgykSwFMgSUDE8ckrD54SnUZdtiwx3YkHD72cvRQanPI2SUA5oJuhJt71";
        };
        cloud = {
          id = 8;
          hashedPassword = "$6$f3g6SX1xSHfU$1IlmQlaQKPpdypQ176dxqyBhLOAmNweK3kUxK0wTOwoB4RYKaK7pni8g3.W88PeMZam3iyycwB16T5xfvTnUP0";
        };
        # test = {
        #   id = 9;
        #   hashedPassword = "$6$dFaeqEy7EnfIz/.X$7/kBKAXiq2GO7gjah3ImlyGauotdGLiBLvCN5LGwhftOQ2dePSJPzRfdDmhZeFD9eqHU4zt1zPURnPykoCYVR1";
        # };
        git = {
          id = 10;
          hashedPassword = "$6$Zm9ZAGnL6n6M/vU5$TwUcsRNITVX9OgjAuT5VZu3zEwsB802gZAgwPm9n6L.WTThPjHRg.FfpOwmJ30qOKCDZ4/mDerXmIgmZsJzu41";
        };
        chat = {
          id = 11;
          hashedPassword = "$6$GEbOlnEOYqGtgTHC$Xoa1BUhO/7fb8oKzYX8oV8KtG6an/rKkQfV.NppXgfyoUM5hTxT0y/lj4zDlqDbmGPhjnALAhmV1dpy4GUX.L1";
        };
        nix_trusted_proxy = {
          id = 500;
          hashedPassword = "!"; # no login
        };
        nix_untrusted_proxy = {
          id = 501;
          hashedPassword = "!"; # no login
        };

      };
    };
  };

  config = let
    staffIdOffset = 2000;
    serviceIdOffset = 3000;
    forAttrs = lib.flip lib.mapAttrs;
  in {
    programs.zsh.enable = true;
    programs.fish.enable = true;
    users.defaultUserShell = "/run/current-system/sw/bin/zsh";

    users.users = forAttrs config.obsidian.staff (name: id: {
      inherit name;
      group = name;
      extraGroups = [ "users" ];
      uid = staffIdOffset + id;
      isNormalUser = true;
      createHome = true;
      home = "/home/${name}";
      useDefaultShell = true;
    }) // forAttrs config.obsidian.services (name: {id, hashedPassword, ...}: {
      inherit name;
      group = name;
      uid = serviceIdOffset + id;
      inherit hashedPassword;
      isSystemUser = true;
      createHome = false;
      home = "/var/empty";
      useDefaultShell = true;
    });

    users.groups = forAttrs config.obsidian.staff (name: id: {
      inherit name;
      gid = staffIdOffset + id;
    }) // forAttrs config.obsidian.services (name: {id, ...}: {
      inherit name;
      gid = serviceIdOffset + id;
    });
  };
}
