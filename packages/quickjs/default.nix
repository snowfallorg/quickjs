{ lib
, pkgs
, system
, fetchFromGitHub
, stdenv
, ninja
, nodejs-18_x
, gcc
, glibc
, ...
}:

let
  raw-node-packages = import ./node-packages/create-node-packages.nix {
    inherit system pkgs;
    nodejs = nodejs-18_x;
  };

  node-packages = lib.mapAttrs
    (key: value: value.override {
      dontNpmInstall = true;
    })
    raw-node-packages;

  shinobi = node-packages."@suchipi/shinobi-^0.0.4";
  shinobi-bin = "${shinobi}/lib/node_modules/@suchipi/shinobi/dist/index.js";

  rev = "a2f72708c860bfa0ef286a50bee9c2c947fe86f9";
  sha256 = "1zxh776yjlbynxpi44r44kggp1yajig6896fiv0gslcpsb4lwf1p";
in
stdenv.mkDerivation
{
  pname = "qjs";
  version = "unstable-2022-12-02";

  src = fetchFromGitHub {
    owner = "suchipi";
    repo = "quickjs";
    inherit rev sha256;
  };

  dontFixup = true;
  dontConfigure = true;
  SKIP_NPM_INSTALL = true;

  buildInputs = [
    ninja
    glibc.static
    nodejs-18_x
  ];

  postPatch = ''
    for script in $(grep -lr '^#!/usr/bin/env bash$'); do patchShebangs $script; done
  '';

  buildPhase = ''
    sed -i 's#npx shinobi#${shinobi-bin}#' ./meta/ninja/generate.sh
    sed -i 's#`git rev-parse --short HEAD`#${builtins.substring 0 9 rev}#' ./meta/ninja/defs.ninja.js

    ./meta/build.sh

    ls -l ./build/intermediate/qjsbootstrap-*.target ./build/bin/qjsbootstrap
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp ./build/bin/* $out/bin

    ls -l ./build/intermediate/qjsbootstrap-*.target $out/bin/qjsbootstrap
  '';
}
