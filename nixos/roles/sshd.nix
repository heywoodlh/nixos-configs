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
    sftpServerExecutable = "internal-sftp";
    settings.permitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
    mosh
  ];

  users.users.heywoodlh = {
    openssh.authorizedKeys.keys = [ 
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1aOhZI4Uo8jpPnmJe2aalB/HT2n42bo270IVxyRLURrmNrro8y/MEDD55GU9AVieVu2P+W4xBlWYaDJjSngWAh+zV6hrEhCSeGXiRnIZ+dpOBU5gcOFJxOpvSVawmqJFTjFUAdkHSLYuf9dtbasDkbxyyb/8Hh9jFjT0bisSRKi/SEmkh5m4nU7ySa1ltb6htUgQ/Y71Fi09BJWhktiT9HrtL4Gs0wzch9biaH/AFGbRNEnAZgQMAL/zS08IfevR7sYoHyjwVSwWVmA4TOhsm+auu9zPV4WgrnY2BNy+H9tF74AP6s+sf19uQG/2qVS3xcrvw2VhQCwPGHpv0o0tGLaCQBwjmqhbrBzVO4Hy1d/vskxe7Zr6IEEbQTLXTsYo6/yiEXOTzOvN7/V/zzdZkeUdRFGxqIu3EABH5wxNYOMwXNlOjnsxsE5VTovkMeIb+No1itaj1xGXuKBKJzRzKJ9pPLxtiaOimXxG4LYg3Ef50V6JzwT7UxY4DiS3JBUxQSxQ5CxifKRN/pCzUMlsdm+yIoXhy57r6JjFtnzet2Ytz12Vp8vRx6ZNH7upMxMBxmWH0sG7hf7fLjmVuurcL7pIB5U7a5rwUhfTjLUAJSg+DDvaOHyhBUsZp7wRxwoJuctvfxoxSkQtNlimWOwuPQgmNIfjjPQUKwM3j95RZiw== tyranny"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPjnAIPI3ypyi8qn8QNlh8jlVxtaZYKRxXjJ1CDWj+Luuv3cbdsmM8V2SeRToeJHCV/qROa8nEnrnFrUqQ3+9qE= chg-mac@secretive.C02GC0NYMD6R.local"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ== bitwarden" 
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBmGLMTS02Ck2EkTTWxGkLp3B+l/6uvxMSlwrQ7gBTojZYnZab4AncwyHyFA08vGXCm/jKOMsyqmNHXQZkmZ4QA= nix-macbook-air@secretive.nix-macbook-air.local"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NUJMRopUF8JvhLK4/l4zkgxZWNIZwxgfEWEoYsD9MnfCj9nflLxHM5zJ7pPx7DYoXaLguvdyCJlDNDlvd3vGW0RgfTyflZJzsQ6HxwsxO1dlyYJY6m0fekUXrFJBcU8uk0mMBO6rrMKMqz077qofCdzbf7vvdR5AsSy2pFcjiNSW0TwGCg3lrEUDX10bKFYkhHqSL/rF9ajZRs7EVVfFmilzGYKxRsvzpP6p72Gdxy50ebMcrUHAilwMzQnode8H+C25hQrkTJWhv9kmcNb//mJcar7atrvEGEBfUJ9/5A3FL6RNap1NPfLQ2w/mXtgfAqyHi1sq/f/+Kje1MazIu4y/U5oSGH3fc5iraN2wF0jIKO1LvDJQmbSrfjCq4FrBs24waPGtp+VcESfBIHYxyr740JMoi6BSjzvJR7gnyWkwWAEjoTBVL8szr2cbogna/g2pHmKDLagJlMOKQNTkPCUboKKj/Dy3wvim/m0D+aBXpkWnGiR7zEchiLV45Bc= tabby"
    ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [ 
      "from=\"100.126.114.23\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqdFcgb5hjpk09z4y7YW8ocSghB7QuuX71izgwSQgcBam2TYi+wsFYpnx+IJmRNp3470jjib/qUZkOICrpjLMiFuveGeySp4ZxzNjIvr/GcTOewmmoAFiQm5JU/Z1Sm8ZtqbglhLJiuMP7ybdCGzKnmiNCyCEE2U39KA+6mH68eGBvYLa7MKuRiv2X0DC2WJoxPHW9nnzIhB7L6nokzs08LBox6j5CM2UoXoFAbb8/06iURzBPXp2uNn0S1VJ3QX7W3GV5vUNnmWriWukNb5+G1yNafRbr6WwvfL+n9wXH3gMavma/NRaPE9B9smjJJ5201v8YBOBFPjJ9w0iUr/mN/bsba5g83APTAD88obRqrkcFFCFxRSZZ6CxvUEN0om9O3GasU734xt1eReO5w4LYw84/j7SmNwsezG8c6/lLUnW7e0VqP7UQ+6Y7Db/HVZ8v9rRxMWI6IbVKYTS/LtTEvkcOvO7gJlBsa1gxUxyKDczP/O6Y4d2BLmXmbql5nvU= root@nix-backups"
    ];
  };
}
