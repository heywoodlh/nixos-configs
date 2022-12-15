self: super: {
  yabai = let
    replace = {
      "aarch64-darwin" = "--replace '-arch x86_64' ''";
      "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
    }.${super.pkgs.stdenv.system};
  in super.yabai.overrideAttrs(
    o: rec {
      version = "5.0.1";
      src = super.fetchFromGitHub {
        owner = "koekeishiya";
        repo = "yabai";
        rev = "v${version}";
        sha256 = "sha256-5WtWLfiWVOqshbsx50fuEv8ab3U0y6z5+yvXoxpLokU=";
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
