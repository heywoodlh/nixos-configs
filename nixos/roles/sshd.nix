{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    # For Mosh
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
  };

  services.openssh = {
    enable = true;
    #sftpServerExecutable = "internal-sftp";
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    mosh
  ];

  users.users.heywoodlh = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1aOhZI4Uo8jpPnmJe2aalB/HT2n42bo270IVxyRLURrmNrro8y/MEDD55GU9AVieVu2P+W4xBlWYaDJjSngWAh+zV6hrEhCSeGXiRnIZ+dpOBU5gcOFJxOpvSVawmqJFTjFUAdkHSLYuf9dtbasDkbxyyb/8Hh9jFjT0bisSRKi/SEmkh5m4nU7ySa1ltb6htUgQ/Y71Fi09BJWhktiT9HrtL4Gs0wzch9biaH/AFGbRNEnAZgQMAL/zS08IfevR7sYoHyjwVSwWVmA4TOhsm+auu9zPV4WgrnY2BNy+H9tF74AP6s+sf19uQG/2qVS3xcrvw2VhQCwPGHpv0o0tGLaCQBwjmqhbrBzVO4Hy1d/vskxe7Zr6IEEbQTLXTsYo6/yiEXOTzOvN7/V/zzdZkeUdRFGxqIu3EABH5wxNYOMwXNlOjnsxsE5VTovkMeIb+No1itaj1xGXuKBKJzRzKJ9pPLxtiaOimXxG4LYg3Ef50V6JzwT7UxY4DiS3JBUxQSxQ5CxifKRN/pCzUMlsdm+yIoXhy57r6JjFtnzet2Ytz12Vp8vRx6ZNH7upMxMBxmWH0sG7hf7fLjmVuurcL7pIB5U7a5rwUhfTjLUAJSg+DDvaOHyhBUsZp7wRxwoJuctvfxoxSkQtNlimWOwuPQgmNIfjjPQUKwM3j95RZiw== tyranny"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ== bitwarden"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBmGLMTS02Ck2EkTTWxGkLp3B+l/6uvxMSlwrQ7gBTojZYnZab4AncwyHyFA08vGXCm/jKOMsyqmNHXQZkmZ4QA= nix-macbook-air@secretive.nix-macbook-air.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc8AsAcXbCv3ujEpxgpgfcJIslsGTFypkU6fQMp2HdU"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBO5jIGdWoLLGP8F5yqI4j9UQUQSwTfqHDn+SqukOYdlXQAVnlAfY2hk9dPPJhf2yyC+eTLxZARFkdBVgzLW2LNg= heywoodlh@ipadpro"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC048tlchSyxPGn/gPHOtf7x2DwKEx3IJD7gfpjR9qCprmcKnOUKjW1TvnqkwIRh9wfYSE4g1iKuer8cP3gm9lZmpYA30e8ZJqms0mH+IqD4IC24vM7NWEsYBXjia31PgZvbk7ZR0dor/qItJBkeccuVGxnOlJYvlTLKUSAej/PArsRLtVewdhIEeW275EERnXtINlItIWq3ei2qj887Sw7eh3JSuYMtmVh+j+XBnPf7NirlXGzAtJn2yeBVyvNEj4QiJNvz3M9EZ0ZniPeY4wNXaKyAj+JVEBe1/0yyMt7ePgf4e8cO8LVZnRCISukMySX1ECjPybVt6KKqmtd9mKo3GZwU/fU4wiz+i/mX7HiFxD9W0H8SInfuWbza/zYOzNVFOjypiKfC6ANESCAhfUbT+1L3mgfia2bKPnpMKmg2HtyFfE8x5wC6Xtot01jkPb+4crqUdycktcJtN3+bUC1FENLPaKSie8T6GbtRFGQqPaJ6U+4yTQvwwXS6C4oRmk= root@nix-ipad"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "from=\"100.126.114.23\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqdFcgb5hjpk09z4y7YW8ocSghB7QuuX71izgwSQgcBam2TYi+wsFYpnx+IJmRNp3470jjib/qUZkOICrpjLMiFuveGeySp4ZxzNjIvr/GcTOewmmoAFiQm5JU/Z1Sm8ZtqbglhLJiuMP7ybdCGzKnmiNCyCEE2U39KA+6mH68eGBvYLa7MKuRiv2X0DC2WJoxPHW9nnzIhB7L6nokzs08LBox6j5CM2UoXoFAbb8/06iURzBPXp2uNn0S1VJ3QX7W3GV5vUNnmWriWukNb5+G1yNafRbr6WwvfL+n9wXH3gMavma/NRaPE9B9smjJJ5201v8YBOBFPjJ9w0iUr/mN/bsba5g83APTAD88obRqrkcFFCFxRSZZ6CxvUEN0om9O3GasU734xt1eReO5w4LYw84/j7SmNwsezG8c6/lLUnW7e0VqP7UQ+6Y7Db/HVZ8v9rRxMWI6IbVKYTS/LtTEvkcOvO7gJlBsa1gxUxyKDczP/O6Y4d2BLmXmbql5nvU= root@nix-backups"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCdV+pafFt9OEvp5Zs95V7UDChTLlKrNG5KBvpGegjmnp9CPk1lvaiJWOfLp5UUuG/Q+i05cKVeWxzNaRSuvCljxkxBZQdurKiffp18TuPABKQgplEMEaCJtOFd8h2o5iBC+05QU8Q4kR3tsh6PRhTaUuWHzfsZUqgx0Qj5DLzDCttdJWC+cxxRXe25Mwvj9no171zSpmLdvtmxw+HYqCPsLYFjvX6xR1kHGbNQgyOxOb9DdzJOILbLU1+Y90R46u8+nsXSgxiE2hxBt2qcT090JiQneJIOCn2iTh74+nquXbPPhXe/E+ztxCLGCnfgeTDywJzsy7REdUyvOhmp1Vg8LneXSNfThHKakVXsgLLMMAWDwBB6FmhgRkoLAiApV30zvXB3W3TlQ9SFfAFGbAuDukzmm7FqQHN6VGCQgE9KP6fdTox1JfR3SYS1mlqGxczTSsP5BEJ+IhZD3WnKWngNwpb8t2ArzVMaYJ9xTp1ZhZP/9lEQWvqfsBZdRpGgMU= root@nix-tools"
      "from=\"100.98.176.50\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKDaas4ocDsCbhLBEtz0DJtJ9JI4GKwd2+XnKMrIMYnS6YzuS2DbSiDp9i0Q8eEbhxzywQqHwQLKf+4QFh+EdUCS6XVAjvgjDZtTVykwwB6VgZNpE4W99Lm24n166MyzNXCwl1WNTz2dNpLDFzW6o4/vDMAguv4Wg6QScAu/J3OqZ3UAgc/Gfm+ajAVN824KNqEabMNoqhf6Nrtzxzq95tYtJUhY7fR8hzQp8o7wVLYSkMuz09vZKUJTAolsV7/p7gyN0MmX1Jt4/35gXKZ35ShnrxXU7In8eAaFY+y3nqkg9N0uxhI2cnUWLSkHCtbyY5MFz9sfEVqebqTKLKXvC7fBIphrpwcPTPuHIeUQUnK2hfAcJ9paBWfU5stBBK5GzfzoQyqnauITOAQ++bR41XBki2WF+CbCgC4+aK90AVx6pR7WCviHtfzTfhtR1qr3iC9c8HGIEGvVODbU1/k09UC2TqMG+aSBq5mIdvPXjXJvGryo29wOEwDduyzrlZ7ps= heywoodlh@ansible-operator"
    ];
  };
}
