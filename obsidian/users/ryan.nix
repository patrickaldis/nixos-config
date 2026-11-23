let name = "ryan"; in

{
  users.extraUsers.${name} = {
    inherit name;
    group = name;
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "obsidian" ];
    createHome = true;
    home = "/home/${name}";
    useDefaultShell = true;
    hashedPassword = "$6$YU0nQYiHsx$EFUAT0yfI31WG.J7Uo/F7MWNgXkSEBaT2oKSAghXAdOSL2pJlDtBfq2ySdzUilAF2Jhwe24p9jdYZLIxmhB96.";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4ahCacOyhoroTkVLtMYYei+ZcjyRNIpk8XUIeaToSwVrhOWIPWqdgPOo9CDoUcvCPp5alnr6BCFOZKxw0maIoFU1pNiQNxTeIkR3NTmX/2j+wCEIZrKJVtIhmvHTzUR9Dav6ZtDhQ5G+fbGtdqHPMoKxRpzWAsBfg7jZz2bRX/tfiqpYuDSb4YKfirSBfNiqTHyMohEtStd4E9qMQ3B9Q2h/9G8PTaJNyGvwq3GD8ehaU0d3QdWk4Z2oK1kmJaDam5yxWMQVs9iUqrTyC98TOhfZzfjPzsBkmkCyQMizNE9EkCtJ0eCOZSH9RXKK//C4jQkH4uNRck2iKStD0YEWX ryan@naga"
    ];
  };

  users.extraGroups.${name}.gid = 1000;
}
