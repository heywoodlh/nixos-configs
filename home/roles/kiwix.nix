{ lib, ... }:

let
  baseUrl = "http://files.barn-banana.ts.net/kiwix";
  entries = map (line: lib.splitString " " line) (
    lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) (
      lib.splitString "\n" (builtins.readFile ../../flakes/kube/kiwix/zims.txt)
    )
  );
  toUrl = entry: "${baseUrl}/${lib.elemAt entry 0}/${baseNameOf (lib.elemAt entry 1)}";
in {
  heywoodlh.home.kiwix = {
    enable = true;
    urls = map toUrl entries;
  };
}
