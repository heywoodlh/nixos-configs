#! /usr/bin/env nix-shell
#! nix-shell -i bash -p curl jq nix gnused
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/ae815cee91b417be55d43781eb4b73ae1ecc396c.tar.gz

latest_version=$(curl -s https://api.github.com/repos/Eugeny/tabby/releases/latest | jq -r '.tag_name')
base_url="https://github.com/Eugeny/tabby/releases/download/${latest_version}"
version=$(echo $latest_version | tr -d 'v') # remove 'v' character in release name
files=("tabby-${version}-macos-arm64.zip" "tabby-${version}-macos-x86_64.zip" "tabby-${version}-linux-arm64.deb" "tabby-${version}-linux-x64.deb")
echo 'Updating version in tabby.nix'
sed -Ei "s/myTabbyVersion = \"(.*)\"/myTabbyVersion = \"${version}\"/g" tabby.nix

for file in "${files[@]}"
do
  url="${base_url}/${file}"
  echo "Updating hash for ${url}"
  myHash=$(nix-prefetch-url --type sha256 ${url})
  # Update x86_64 MacOS version
  echo -n "${file}" | grep -iq macos-x86_64 && sed -Ei "s/x86_64-darwin-hash = \"(.*)\"/x86_64-darwin-hash = \"${myHash}\"/g" tabby.nix
  # Update aarch64 MacOS version
  echo -n "${file}" | grep -iq macos-arm64 && sed -Ei "s/aarch64-darwin-hash = \"(.*)\"/aarch64-darwin-hash = \"${myHash}\"/g" tabby.nix
  # Update x86_64 Linux version
  echo -n "${file}" | grep -iq linux-x64 && sed -Ei "s/x86_64-linux-hash = \"(.*)\"/x86_64-linux-hash = \"${myHash}\"/g" tabby.nix
  # Update arm64 Linux version
  echo -n "${file}" | grep -iq linux-arm64 && sed -Ei "s/aarch64-linux-hash = \"(.*)\"/aarch64-linux-hash = \"${myHash}\"/g" tabby.nix
done
