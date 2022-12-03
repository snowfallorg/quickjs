{ inputs
, snowfall-inputs
, lib
}:

let
  inherit (inputs.nixpkgs.lib) concatStringsSep;
in
{
  # Create a `qjsbootstrap` builder.
  # Type: Attrs -> Attrs
  # Usage: mkBuilder pkgs
  #   result: { build: attrs: {/* ... */} }
  mkBuilder = pkgs: {
    # Build a new `qjsbootstrap` program.
    # Type: { files } -> Derivation
    # Usage: builder.build { files = [ ./my-script.js ]; }
    #   result: Derivation
    build = { files }:
      let
        file-names = concatStringsSep " " files;
      in
      pkgs.runCommandNoCC "qjs-app" { } ''
        cat ${pkgs.quickjs}/bin/qjsbootstrap ${file-names} > $out
        chmod +x $out
      '';
  };
}
