// A generated module for LinuxBuilds functions

package main

import (
	"context"
	"dagger/linux-builds/internal/dagger"
)

type LinuxBuilds struct{}

// Function to build a Nix package
func (m *LinuxBuilds) nixBuild(ctx context.Context, source *dagger.Directory, target string) *dagger.Container {
	ctr, err := dag.Container().
		From("docker.io/heywoodlh/nix:latest").
		WithMountedDirectory("/nixos-configs", source).
		WithWorkdir("/nixos-configs").
		WithFile("/etc/nix/nix.custom.conf", source.File(".dagger/nix.conf")).
		WithMountedCache("/store", dag.CacheVolume("nix-store")).
		WithExec([]string{"nix", "--store", "local?store=/store", "build", "/nixos-configs#" + target, "--quiet", "--show-trace"}).
		Sync(ctx)

	if err != nil {
		panic(err)
	}

	return ctr
}

// Function to build a Nix package
func (m *LinuxBuilds) PushToAttic(ctx context.Context, source *dagger.Directory, target string) *dagger.Container {
	ctr, err := dag.Container().
		From("docker.io/heywoodlh/nix:latest").
		WithMountedDirectory("/nixos-configs", source).
		WithWorkdir("/nixos-configs").
		WithFile("/etc/nix/nix.custom.conf", source.File(".dagger/nix.conf")).
		WithMountedCache("/store", dag.CacheVolume("nix-store")).
		WithExec([]string{"nix", "--store", "'local?store=/store'", "run", "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client", "--", "push", "nixos", "/store"}).
		Sync(ctx)

	if err != nil {
		panic(err)
	}

	return ctr
}

// Function to build Home-Manager desktop configuration
func (m *LinuxBuilds) HomeDesktopBuild(ctx context.Context,
	// +defaultPath="/"
	source *dagger.Directory) *dagger.Container {
	return m.nixBuild(ctx, source, "homeConfigurations.heywoodlh.activationPackage")
}

// Function to build Home-Manager server configuration
func (m *LinuxBuilds) HomeServerBuild(ctx context.Context,
	// +defaultPath="/"
	source *dagger.Directory) *dagger.Container {
	return m.nixBuild(ctx, source, "homeConfigurations.heywoodlh-server.activationPackage")
}

// Function to build NixOS desktop configuration
func (m *LinuxBuilds) NixosDesktopBuild(ctx context.Context,
	// +defaultPath="/"
	source *dagger.Directory) *dagger.Container {
	return m.nixBuild(ctx, source, "nixosConfigurations.nixos-desktop.config.system.build.toplevel")
}

// Function to build NixOS server configuration
func (m *LinuxBuilds) NixosServerBuild(ctx context.Context,
	// +defaultPath="/"
	source *dagger.Directory) *dagger.Container {
	return m.nixBuild(ctx, source, "nixosConfigurations.nixos-server.config.system.build.toplevel")
}
