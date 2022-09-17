{ config, pkgs, ... }:

{
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = true;
      authentication = ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
        host all all 172.16.0.0/12 md5
      '';
    };
    pgadmin = {
      enable = true;
      initialEmail = "i@gao4.pw";
      initialPasswordFile = pkgs.writeText "qwq" "password";
      settings = {
        DEFAULT_SERVER = "0.0.0.0";
      };
    };
  };
}