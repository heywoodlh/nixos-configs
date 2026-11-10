{ lib, ... }:

let
  baseUrl = "http://files.barn-banana.ts.net/kiwix";
  excludedCategories = [ "gutenberg" ];
  parsed = map (line: lib.splitString " " line) (
    lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) (
      lib.splitString "\n" (builtins.readFile ../../flakes/kube/kiwix/zims.txt)
    )
  );
  entries = lib.filter (entry: !(lib.elem (lib.elemAt entry 0) excludedCategories)) parsed;
  toUrl = entry: "${baseUrl}/${lib.elemAt entry 0}/${baseNameOf (lib.elemAt entry 1)}";
in {
  heywoodlh.home.kiwix = {
    enable = true;
    urls = map toUrl entries;
  };
}
