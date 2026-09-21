{ config, secrets, ... }:{
  age.secrets.wifi = {
    file = "${secrets}/wifi.age";
    mode = "0440";
    group = "wpa_supplicant";
  };
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  networking.wireless = {
    enable = true;
    scanOnLowSignal = false;
    secretsFile = config.age.secrets.wifi.path;
    networks = builtins.listToAttrs
    (map (name: { inherit name; value.pskRaw = "ext:PSK_${name}"; })
      [ "BTWholeHome-QXR" "Patricks iPhone"]);
  };
}
