{ config, pkgs, lib, ... }: with lib; {
  # Set up "Virtual Distributed Ethernet" infrastructure for QEMU
  # This is necessary to make focus/test-deploy work
  # TODO: Can we run this using unshare, instead?
  systemd.services = {
      obsidian-test-net-vde =
        let runDir = "obsidian-test-net-vde";
	    pidFile = "/run/${runDir}/vde_switch.pid";
	in {
        description = "Networking for deployment test VMs - vde_switch";
        after = [ "network-pre.target" ];
        unitConfig.ConditionCapability = "CAP_NET_ADMIN";
        serviceConfig = {
	  Type = "forking";
	  Restart = "always";
	  RuntimeDirectory = [ runDir ];
	  PIDFile = pidFile;
	};
        script = ''
	  echo asdf
          ${pkgs.vde2}/bin/vde_switch -tap tap0 -mod 660 -group obsidian_kvm &
	  echo $! >${pidFile}
          ${pkgs.iproute}/bin/ip link set dev tap0 up
          ${pkgs.iproute}/bin/ip addr add 10.0.2.1/24 dev tap0
          ${pkgs.procps}/sbin/sysctl -w net.ipv4.ip_forward=1
          ${pkgs.iptables}/sbin/iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -j MASQUERADE
        '';
      };
      obsidian-test-net-dhcpd4 =
        let configFile = pkgs.writeText "dhcpd.conf" ''
	      log-facility local1;
              subnet 10.0.2.0 netmask 255.255.255.0 {
                authoritative;
                range 10.0.2.15 10.0.2.200;
                default-lease-time 3600;
                max-lease-time 3600;
                option subnet-mask 255.255.255.0;
                option broadcast-address 10.0.2.255;
                option routers 10.0.2.1;
                option domain-name-servers 8.8.8.8, 8.8.4.4;
                option domain-name "${config.networking.hostName}";
              }
            '';
	    pidFile = "/run/obsidian-test-net-dhcpd4/dhcpd.pid";
	    stateDir = "/var/lib/obsidian-test-net-dhcpd4";
	in {
        description = "Networking for deployment test VMs - dhcpd4";
        wantedBy = [ "network.target" ];
        after = [ "network-pre.target" ];
        requires = [ "obsidian-test-net-vde.service" ];
	preStart = ''
	  mkdir -m 755 -p ${stateDir}
	  touch ${stateDir}/dhcpd.leases
	'';
        serviceConfig = {
	  Type = "forking";
	  Restart = "always";
	  RuntimeDirectory = [ "obsidian-test-net-dhcpd4" ];
	  PIDFile = pidFile;
	  ExecStart = concatMapStringsSep " " escapeShellArg [
	    "@${pkgs.dhcp}/sbin/dhcpd" "dhcpd4" "-4"
	    "-pf" pidFile
	    "-cf" configFile
	    "-lf" "${stateDir}/dhcpd.leases"
	    "-user" "root" "-group" "nogroup"
	    "tap0"
	  ];
	};
      };
    };

  users.groups.obsidian_kvm.gid = 2000;
}
