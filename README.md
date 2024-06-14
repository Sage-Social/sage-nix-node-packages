# Sage Specific NodePackages for Nix

## Description

This Nix flake provides a development environment tailored for Sage-specific Node.js packages. It uses the `nixpkgs` and `flake-utils` inputs to define and configure the shell environment and package dependencies. `node2nix` is used to repackage the node packages in `package.json` to nix. 

Node2Nix documentation: https://github.com/svanderburg/node2nix

This is roughly the same method that nixpgks (official package repository) uses for Node Packages. This is not quite as smooth as their implementation see Future Improvements section. 

## Inputs

- `nixpkgs`: References the unstable branch of the Nixpkgs repository.
- `flake-utils`: A library to simplify the management of Nix flakes.

## Outputs

The outputs are generated using the `flake-utils.lib.eachDefaultSystem` function, ensuring the configuration is applied to all supported systems. The key components of the output are:

- `pkgs`: Imported from the `nixpkgs` input, specific to the system being built for.
- `nodeEnv`: The Node.js environment configured by the `default.nix` file.
- `packageName`: The name assigned to the Node.js packages, set to "nodePackages".
- `packages.${packageName}`: The Node.js dependencies defined in the `default.nix` file.
- `defaultPackage`: The default package for the current system.
- `devShells.default`: The default development shell environment configured with the specified build inputs and a shell hook.

## Development Shell Configuration

The development shell is configured to include the following packages:

- `nodejs_20`: Node.js version 20 from the Nixpkgs repository.
- `nodePackages`: The Node.js dependencies defined in the `default.nix` file.
- `node2nix`: A tool to convert `package.json` files to Nix expressions.

Additionally, a shell hook is provided to display a welcome message upon entering the shell environment.

## Usage

This is generally supposed to be used as a package in other Nix/Flake environments. This is currently commited to the public github repo at: https://github.com/Sage-Social/sage-nix-node-packages

### As a Package 
To import the node packages into another shell using a flake.nix file it would looks something like the following file. This is pulling the latest version of the package repository from the main branch in GitHub. 

```
{
  description = "Basic node v20 environment with EAS from Sage Packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sagepgks.url = "github:Sage-Social/sage-nix-node-packages";
  };

 outputs = { nixpkgs, flake-utils, sagepgks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        spkgs = sagepgks.packages.${system}.nodePackages;
      in {
        devShells.default = pkgs.mkShell { 
          buildInputs = [ 
            pkgs.nodejs_20 spkgs
          ]; 
        };
      }
    );
}
```

### As a Shell

To use this development shell, pick one of the following methods:

- **Use direnv:**

    ```bash
    direnv allow
    ```
    
    Then exit and enter the directory again. 

- **Enter the development shell:**

    ```bash
    nix develop
    ```

    This will drop you into a shell environment with Node.js, the specified Node.js dependencies, and `node2nix` available.

## Add Node Packages and Publish

To add new packages enter a shell through one of the methods above. 

Update or add new packages using `npm` as usual:

```bash 
npm install <package name>
npm update 
npm update <package name>
```

When ready to create the nix package remove the `node_modules` directory and the `package-lock.json` file

```bash
rm -r node_modules
rm package-lock.json
```

Run Node2Nix to update the default.nix, node-env.nix, and node-package.nix files:

```bash
 node2nix -i package.json -o node-packages.nix -c default.nix
```

Create pull request into main and once landed this package will be available. 

## Future Improvements

1. Run the `node2nix` build process in github actions
2. version using releases in GitHub so we can reference specific versions using: https://github.com/Sage-Social/sage-nix-node-packages/2.3.4 or something similar
3. Find a better way to edit the package.json file so `rm -r node_modules` and `rm package-lock.json` are not requried. I have tried a few commands and there is a way to prevent the package-lock.json from being created but no way to stop downloads to node_modules. However you can use `npm install --package-lock-only --no-package-lock <package>` but it is brittle and could be broken by a previous wrong command adding a package-lock. 
4. Cleanup package so we can request a specific package and not have to install all of them. E.g. `sagepkgs.eas-cli` vs `sagepkgs`. I know this is possible because `nixpkgs.nodePackages.eas-cli` works but I have not yet figured out exactly how they did it. 
5. Move this to a private repo. Technically this works right now exept for people that are using password protected SSH keys like myself. It seemed a bit too brittle to depend on so this is currently a public repository of publicly availble packages. 
