{
  description = "Python Flake for ML";
  inputs = {
    system-flake.url = "path:/etc/nixos";
    nixpkgs.follows = "system-flake/nixpkgs";
  };

  outputs =
  { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      pythonEnv = pkgs.python313.withPackages (ps: with ps; [
        gym
        matplotlib
        networkx
        numpy
        opencv-python
        plotly
        scikit-learn
        scipy
        seaborn
        tensorboard
        tensorflow
        tensorflow-estimator-bin
      ]);
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        name = "ML Python Flake";

        packages = [
          pythonEnv
        ];

        # Stop CondaPkg from downloading its own (broken-on-NixOS) Python,
        # and make PythonCall use the Nix one instead.
        JULIA_CONDAPKG_BACKEND = "Null";
        JULIA_PYTHONCALL_EXE = "${pythonEnv}/bin/python";

        # PythonCall embeds libpython directly, bypassing Nix's python wrapper,
        # so expose the site-packages explicitly.
        shellHook = ''
          export PYTHONPATH="${pythonEnv}/${pkgs.python313.sitePackages}"
        '';
      };
    };
}
