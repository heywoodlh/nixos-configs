''
  alias amass='mkdir -p ~/.local/amass && docker run -it --rm -v ~/.local/amass:/.config/amass/ docker.io/caffix/amass $@'

  alias msfconsole='mkdir -p ~/.local/metasploit && docker run -it --rm --net host -v ~/.local/metasploit/:/root/.msf4 -w /root/session -v $(pwd):/root/session docker.io/heywoodlh/metasploit msfconsole $@'

  alias msfvenom='mkdir -p ~/.local/metasploit && docker run -it --rm -v ~/.local/metasploit/:/root/.msf4 -w /root/session -v $(pwd):/root/session docker.io/heywoodlh/metasploit msfvenom $@'
''
