{ lib, config, pkgs, ... }:

{
  services.osquery = {
    enable = true;
    flags = {
      # Setup certs and secrets with these commands:
      # sudo mkdir -p /opt/osquery
      # sudo curl http://files.barn-banana.ts.net/fleet/fleet.pem -o /opt/osquery/fleet.pem
      # sudo curl http://files.barn-banana.ts.net/fleet/secret.txt -o /opt/osquery/secret.txt
      tls_server_certs = "/opt/osquery/fleet.pem";
      enroll_secret_path = "/opt/osquery/secret.txt";
      tls_hostname = "fleet.heywoodlh.io";
      host_identifier = "instance";
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
