{ config, pkgs, ... }:

{
  enable = true;
  package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
}
