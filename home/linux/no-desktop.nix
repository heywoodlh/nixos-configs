{ ... }:

{
  programs.zsh.initExtra = ''
    PROMPT=$'%~ %F{green}$(git branch --show-current 2&>/dev/null) %F{red}$(env | grep -i SSH_CLIENT | grep -v "0.0.0.0" | cut -d= -f2 | awk \'{print $1}\' 2&>/dev/null) %F{white}\n> '
  '';

  heywoodlh.home.llm = {
    lmstudio.enable = false;
  };
}
