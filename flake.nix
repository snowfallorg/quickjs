{
  description = "Snowfall QuickJS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    unstable.url = "github:nixos/nixpkgs";

    snowfall = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      lib = inputs.snowfall.mkLib {
        inherit inputs;
        src = ./.;
      };
    in
    lib.mkFlake {
      outputs-builder = channels:
        let
          qjs = lib.mkBuilder channels.nixpkgs;
        in
        {
          packages.default = "quickjs";

          packages.example = qjs.build {
            files = [
              ./examples/example-a.js
              ./examples/example-b.js
            ];
          };
        };
    };
}
