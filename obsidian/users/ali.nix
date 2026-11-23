let name = "ali"; in

{
  users.extraUsers.${name} = {
    inherit name;
    group = name;
    uid = 1001;
    isNormalUser = true;
    extraGroups = [ "wheel" "obsidian" ];
    createHome = true;
    home = "/home/${name}";
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHLKXr65dc/5bk7rpmN4KhDzzE5ukJgM5V/HeMlSa+sfIC3e2KDHoc8iAS1ZKT3ObOBn7KvWPwouWipKg4hGunkEsGy5S7Ok+deq21BCKIEO49sPQICB9vReRrcY/9at5FIUexv7xWRuSXs0f8TCxaSCnCsqBIf5CYBFz9YNW6PSkrp4Mrcz/mWc8K2C6WfkZdW+zJW4jCKtHHxRMbO5/Ag/sT+zHdGSy4o15I2WUNgYf67kt4w/cjVqqLvQY1xcMpYSFfEmVhDVtALvX3EVb1j4xIpwZz9iy25Jvq90j3gBG5wL9nBZAuiAzozVGUj4ylafIqm9c2u1LybqTRa9YZ ali@reboot"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDW1UeblL9vu3jKprCCRgaavRyqQSels/qbdVk2dpM2lR+iDbz5lfQP2N+3RGWd/ocK5TmXowl78W+NCAYKI1dSFzcbKe/cyJR2kd9DYDNhAwMAhM3d+vAU0ad9FnfmQTpEYaCOOIwQDwMO6tlbqbMI9TfiRO67crr6lgt0Pdm+zA9hrQG8OlJlBX1K76vKdQahxBrm9mGvXvIKgbFuYYRgFh4Khq8teC8A8Y0jt7qPMRf5MCbcCxHIrrDGiYir7OqdiN6/AZzvOpAHlBV5kUmT15UblfTZcDvEVJ24PSsopGUufJTVWN3ykMRJteNezEZa6DeXsyb9PzZ7TrYaO6G3 ali@koroglu"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgbXYu2RBIWWXUZQM0fk77ijLKQAa3byK4GR784q2W/Im6R0yG9BqRTbAM9gdqVprxi5IbVIs5wKo3tzBscOOxWhtfwdlQxjlJbsJb4qDJQf9kSo39F2OmjpqDh16LliWi4VAYWv45kXfnM0JzFDCLetdmZkhwXJ1Sh744gdJGiIpq7WuJb3Otla1cryQlHoA5RnWqDCFvpY1Z49E89ZfBSPpzVuPifxut9hsWIfetc95ReqsRHNdt/Hd56r5Q6ks8nIlVbg4ZxMsm3WN8QQqgtJf7p7K1j/MM/Ejd/AeOoQVomOq9zorY2IcZa9UZ9MOU2xk7KSRr4mX/NR67pbbV ali@faiz"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDD0Ir07c5J/BEjLZBr2jQDCh1NFddMH6PAMtzyJkHKnaknYHcACmjH2NBi44stKHDwBXUjunUJvB1H2p2Pd4QSAk0XytTUvbYtGotCvhnNXHg5WjYH+6QG0fo+sMckIpsHvNkaB8XaF6tOrugwI+c1gRPQOLfa+YEYBD5TD4312hIa2d1VFEfie4L61vJCGgBE8/XU4EJ+s9FrSXcrLlMDtS6P9rdRl856o3ARKuBgm7RcuG73W5frUrxg8c9pqi16Awm9zbT/ReoOWE5r9dRbI5LeY0DyplgWkaufB9uMEO+mu7FfDJYp5M9XvKfwH1osYDyS6GmojxQbvMKjXfCwR6l0PgepgvhqAgxK0WqVz8WJfwmPsa+EqhRGByWNGCzakzyAH+G73JpNzBK5WTgpffrqehE1uzwy0RThKHkops3wazgfWee+/Iwbm7/flWclX75R7wn1mR/RNLKQHjmkkMnMFgnfkDJ4PWcvGFKH7DyNt7wWk2MOqCOZTLJM/T8= ali@kiviuq"
    ];
    hashedPassword = "$6$jB7nbBzB$R8C7TqJ2rRxztAOgz9X00MrBnZ7n12CKlXjEWKf4C.Mtw.REb8h1RNiOb1tBvGaYyaoDWhrmHRy0GHZam8i7Y1";
  };

  users.extraGroups.${name}.gid = 1001;
}
