{ config, pkgs, ... }:

let
  secret = pkgs.fetchurl {
    url = "https://drive.heywoodlh.io/s/L2gFPmozS8gxwGt/download/secret.txt";
    hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2Ww=";
  };
  cert = pkgs.fetchurl {
    url = "https://drive.heywoodlh.io/s/8g58tycZyR487ES/download/fleet.pem";
    hash = "sha256-lTeyxzJNQeMdu1IVdovNMtgn77jRIhSybLdMbTkf2Ww=";
  };
in {
  services.osquery = {
    enable = true;
    flags = {
      tls_hostname = "fleet.heywoodlh.io";
      tls_server_certs = "${cert}";
      host_identifier = "instance";
      enroll_secret_path = "${secret}";
      enroll_tls_endpoint = "/api/osquery/enroll";
      config_plugin = "tls";
      config_tls_endpoint = "/api/v1/osquery/config";
      config_refresh = "10";
      disable_distributed = "false";
      distributed_plugin = "tls";
      distributed_interval = "10";
      distributed_tls_max_attempts = "3";
      distributed_tls_read_endpoint = "/api/v1/osquery/distributed/read";
      distributed_tls_write_endpoint = "/api/v1/osquery/distributed/write";
      logger_plugin = "tls";
      logger_tls_endpoint = "/api/v1/osquery/log";
      logger_tls_period = "10";
      disable_carver = "false";
      carver_start_endpoint = "/api/v1/osquery/carve/begin";
      carver_continue_endpoint = "/api/v1/osquery/carve/block";
      carver_block_size = "8000000";
    };
  };
}
