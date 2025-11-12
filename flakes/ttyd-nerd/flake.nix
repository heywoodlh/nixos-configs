{
  description = "ttyd flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    jetbrains = {
      url = "github:JetBrains/JetBrainsMono/v2.304";
      flake = false;
    };
    iosevka = {
      url = "github:iosevka-webfonts/iosevka/26bd341f7eacd904c8a76f1e6ec62385bced74a5";
      flake = false;
    };
    source-code-pro = {
      url = "github:adobe-fonts/source-code-pro/2.042R-u/1.062R-i/1.026R-vf";
      flake = false;
    };
    hack = {
      url = "https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-webfonts.tar.gz";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      jetbrains,
      iosevka,
      source-code-pro,
      hack,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        cp-fonts = ''
          mkdir "$dest"/html/src/style/webfont
          cp ${jetbrains}/fonts/webfonts/JetBrainsMono-Regular.woff2 "$dest"/html/src/style/webfont/jetbrains-mono-regular.woff2
          cp ${iosevka}/woff2/iosevka-regular.woff2 "$dest"/html/src/style/webfont/iosevka-regular.woff2
          cp ${source-code-pro}/WOFF2/TTF/SourceCodePro-Regular.ttf.woff2 "$dest"/html/src/style/webfont/source-code-pro-regular.woff2
          cp ${hack}/fonts/hack-regular.woff2 "$dest"/html/src/style/webfont/hack-regular.woff2
        '';
        ttydOverlay = (final: prev: {
          ttyd-nerd-fonts = prev.ttyd.overrideAttrs (oldAttrs: rec {
            buildInputs = with pkgs; oldAttrs.buildInputs ++ [
              git
            ];
            patchPhase = ''
               dest="$(pwd)" # used by cp-fonts
               ${cp-fonts}
               cp ${self}/src/html.h src/html.h
               git apply ${self}/ttyd.patch
            '' + prev.patchPhase or "";
          });
        });
        ttydPkgs = (pkgs.extend ttydOverlay);
        ttydPackage = ttydPkgs.ttyd-nerd-fonts;
        # Resources for generating html assets
        # Reference: https://github.com/tsl0922/ttyd/blob/main/.github/workflows/frontend.yml
        entrypoint = pkgs.writeText "entrypoint.sh" ''
          #!/usr/bin/env bash
          set -ex
          cd /app/ttyd/html
          #corepack enable
          #corepack prepare yarn@stable --activate
          npm install eslint-plugin-n@latest --save-dev
          yes | yarn install
          yarn run build
        '';
        dockerfile = pkgs.writeText "Dockerfile" ''
          # Docker image to easily generate HTML assets for TTY
          FROM docker.io/node:23
          RUN npm install -g eslint-plugin-n
          RUN mkdir -p /app
          COPY entrypoint.sh /entrypoint.sh
          COPY ttyd.patch /ttyd.patch
          VOLUME /app
          ENTRYPOINT ["/entrypoint.sh"]
        '';
        gen-sh = pkgs.writeShellScriptBin "gen.sh" ''
          set -ex
          dir="$(mktemp -d -p $HOME/tmp)"
          dest="$dir/app/ttyd"
          cp ${dockerfile} "$dir"/Dockerfile
          cp ${entrypoint} "$dir"/entrypoint.sh && chmod +xw "$dir"/entrypoint.sh
          cp ${self}/ttyd.patch "$dir"/ttyd.patch
          docker build -t ttyd-html "$dir"
          mkdir -p "$dir/app"
          rm -rf "$dest"
          git clone --depth=1 -b 1.7.7 https://github.com/tsl0922/ttyd "$dest"
          git -C "$dest" apply ${self}/ttyd.patch
          ${cp-fonts}
          docker run -v "$dest":/app/ttyd -it --rm ttyd-html
          mkdir -p $(pwd)/src
          cp "$dest"/src/html.h $(pwd)/src/html.h
        '';
      in
      {
        devShell = pkgs.mkShell {
          name = "ttyd";
          buildInputs = with pkgs; [
            ttydPkgs.ttyd
            gen-sh
          ];
        };
        packages = rec {
          ttyd = ttydPackage;
          gen = gen-sh;
          default = ttyd;
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
