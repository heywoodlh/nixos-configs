{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.pandoc;
  docxMd = pkgs.writeText "template.md" ''
    ```{=openxml}
    <w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>FirstName LastName</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>01 August 2027</w:t></w:r></w:p>
    <w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>CourseName</w:t></w:r></w:p>
    ```

    # My Document Title

    Content here...
  '';
  docxGen = pkgs.writeShellScriptBin "docx-gen.sh" ''
    set -x
    cp ${docxMd} -n -v output.md
  '';
  docx = pkgs.writeShellScriptBin "docx.sh" ''
    usage="Usage: $0 ./input.md ./output.docx\nAppend any text you would like added to top-right corner of doc (space-separated)\ni.e. $0 ./input.md ./output.docx \"FirstName LastName\" \"01 August 2027\" \"CourseName\""
    [[ -z "$@" ]] && printf "$usage" && exit 0
    echo "$0" | grep -qE -- "--help|-h" && printf "$usage" && exit 0

    # Check for input file
    if [[ -z "$1" ]] || [[ ! -e "$1" ]]
    then
      echo "No argument provided or $1 does not exist. Exiting."
      exit 1
    fi
    input="$1"

    output="$2"
    [[ -z "$output" ]] && output="output.docx"
    # Append `.docx` suffix if not provided
    echo "$output" | grep -q ".docx" || output="''${output}.docx"

    shift 2
    if [[ -n "$*" ]]; then
      tmpmd=$(mktemp --suffix=.md)
      trap 'rm -f "$tmpmd"' EXIT
      printf '```{=openxml}\n' > "$tmpmd"
      for arg in "$@"; do
        printf '<w:p><w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>%s</w:t></w:r></w:p>\n' "$arg" >> "$tmpmd"
      done
      printf '```\n\n' >> "$tmpmd"
      cat "$input" >> "$tmpmd"
      ${pkgs.pandoc}/bin/pandoc "$tmpmd" --output="$output"
    else
      ${pkgs.pandoc}/bin/pandoc "$input" --output="$output"
    fi
  '';
in {
  options = {
    heywoodlh.home.pandoc = mkOption {
      default = true;
      description = ''
        Enable heywoodlh pandoc tooling.
      '';
      type = bool;
    };
  };

  config = mkIf cfg {
    home.packages = with pkgs; [
      pandoc
      docx
      docxGen
    ];
  };
}
