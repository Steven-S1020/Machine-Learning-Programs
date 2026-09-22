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
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        name = "ML Python Flake";

        buildInputs = with pkgs; [
          python313
        ]
        ++ (with python313Packages; [
          gym
          matplotlib
          networkx
          opencv-python
          plotly
          scikit-learn
          scipy
          seaborn
          tensorboard
          tensorflow
          tensorflow-estimator-bin
        ]);

        shellHook = ''
        '';
      };
    };
}

