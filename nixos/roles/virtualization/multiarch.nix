{ config, pkgs, lib, ... }:

{
  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    "aarch64-linux"
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isAarch64 [
    "x86_64-linux"
  ];
}
