{ pkgs, vimPlugins, mcphub, mcphub-nvim, ... }:

let
  system = pkgs.system;
  mcphub-pkg = pkgs.buildNpmPackage (finalAttrs: {
    pname = "mcp-hub";
    version = "dev";

    src = mcphub;

    npmDepsHash = "sha256-nyenuxsKRAL0PU/UPSJsz8ftHIF+LBTGdygTqxti38g=";

    meta = {
      description = "Centralized manager for MCP servers with dynamic server management and monitoring";
      homepage = "https://www.npmjs.com/package/mcp-hub";
    };
  });
  mcphub-plugin = mcphub-nvim.packages.${system}.default;
in {
  plugins = with vimPlugins; [
    copilot-vim
    codecompanion-nvim
    codecompanion-history-nvim
    mcphub-plugin
    llm-nvim
  ];

  rc = ''
    lua << EOF
      require("mcphub").setup({
        cmd = "${mcphub-pkg}/bin/mcp-hub",
      })
    EOF
  '';
}
