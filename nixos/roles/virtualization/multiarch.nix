{ config, pkgs, lib, ... }:

{
  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
  ] ++ lib.optionals pkgs.stdenv.isx86_64 [
    "aarch64-linux"
  ] ++ lib.optionals pkgs.stdenv.isAarch64 [
    "x86_64-linux"
  ];
}
