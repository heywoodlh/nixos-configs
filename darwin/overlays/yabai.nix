self: super: {
  yabai = let
    replace = {
      "aarch64-darwin" = "--replace '-arch x86_64' ''";
      "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
    }.${super.pkgs.stdenv.system};
  in super.yabai.overrideAttrs(
    o: rec {
      version = "4.0.0";
      src = super.fetchFromGitHub {
        owner = "koekeishiya";
        repo = "yabai";
        rev = "v${version}";
        sha256 = "sha256-rllgvj9JxyYar/DTtMn5QNeBTdGkfwqDr7WT3MvHBGI=";
      };
      postPatch = ''
        substituteInPlace makefile ${replace};
      '';
      buildPhase = ''
        PATH=/usr/bin:/bin /usr/bin/make install
      '';
    }
  );
}
