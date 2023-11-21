{ lib, config, pkgs, osquery-fix-nixpkgs, ... }:

let
  secret = pkgs.fetchurl {
    url = "http://100.113.9.57:9080/secret.txt";
    sha256 = "sha256-foUAIXGl1IpTc2i0gKARz7HKPxUNo0uEBvE/jRvc6co=";
  };
  cert = pkgs.fetchurl {
    url = "http://100.113.9.57:9080/fleet.pem";
    sha256 = "sha256-n6wRM5SXALOaJNwXsyc29tED2OnjwQzNk/Z5yckCqLU=";
  };
  system = pkgs.system;
in {
  services.osquery = {
    enable = false; # Until openssl is fixed
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
