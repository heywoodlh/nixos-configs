{
  fallback = true;
  connect-timeout = 1;
  extra-substituters = [
    "https://nix-community.cachix.org"
    "http://attic.barn-banana.ts.net/nixos"
    "http://attic.barn-banana.ts.net/nix-darwin"
    "https://heywoodlh-helix.cachix.org"
  ];
  extra-trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nixos:4q9iokR56gpJfsHh0UKn9Hj1cPplvM879XVgnRstpNU="
    "nix-darwin:hBC1vKJgE6O9S5jiasCHUepCV/cBvUtPEtV2sumBF6A="
    "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
  ];
}
