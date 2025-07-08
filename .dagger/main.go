// A generated module for LinuxBuilds functions

package main

import (
	"context"
	"dagger/linux-builds/internal/dagger"
	"log"
	"os"
)

type LinuxBuilds struct{}

// Function to build a Nix package
func (m *LinuxBuilds) nixBuild(ctx context.Context, source *dagger.Directory, target string) *dagger.Container {
	dirname, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}
	atticDir := dirname + "/.config/attic"
	return dag.Container().
		From("docker.io/heywoodlh/nix:latest").
		WithMountedDirectory("/nixos-configs", source).
		WithMountedDirectory("/root/.config/attic", atticDir).
		WithMountedFile("/etc/nix/nix.custom.conf", source().WithFile("/.dagger/nix.conf")).
		WithWorkdir("/nixos-configs").
		WithExec([]string{"nix", "build", "/nixos-configs#" + target})
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
