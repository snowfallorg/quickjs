# QuickJS ❤ Nix

<a href="https://nixos.wiki/wiki/Flakes" target="_blank">
	<img alt="Nix Flakes Ready" src="https://img.shields.io/static/v1?logo=nixos&logoColor=d8dee9&label=Nix%20Flakes&labelColor=5e81ac&message=Ready&color=d8dee9&style=for-the-badge">
</a>
<a href="https://github.com/snowfallorg/lib" target="_blank">
	<img alt="Built With Snowfall" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Built%20With&labelColor=5e81ac&message=Snowfall&color=d8dee9&style=for-the-badge">
</a>
<a href="https://github.com/suchipi/quickjs" target="_blank">
	<img alt="Powered By QuickJS" src="https://img.shields.io/static/v1?logoColor=d8dee9&label=Powered%20By&labelColor=5e81ac&message=QuickJS&color=d8dee9&style=for-the-badge">
</a>

<p>
<!--
	This paragraph is not empty, it contains an em space (UTF-8 8195) on the next line in order
	to create a gap in the page.
-->
  
</p>

This flake provides [a fork of QuickJS](https://github.com/suchipi/quickjs) and a helper utility to easily build QuickJS-based programs.

## Try Without Installing

You can run QuickJS without committing to installing it by using the following command.

```bash
# To run the REPL.
nix run github:snowfallorg/quickjs

# Or to run a JavaScript file.
nix run github:snowfallorg/quickjs -- ./my-script.js
```

## Usage

First, include this flake as an input in your flake.

```nix
{
	description = "My awesome flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

		# Snowfall Lib is not required, but will make configuration easier for you.
		snowfall-lib = {
			url = "github:snowfallorg/lib";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		quickjs = {
			url = "github:snowfallorg/quickjs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};
}
```

Then add the overlay or use the `quickjs` package from this flake directly.

```nix
{
	description = "My awesome flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

		# Snowfall Lib is not required, but will make configuration easier for you.
		snowfall-lib = {
			url = "github:snowfallorg/lib";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		quickjs = {
			url = "github:snowfallorg/quickjs";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs:
		inputs.snowfall-lib.mkFlake {
			inherit inputs;
			src = ./.;

			overlays = with inputs; [
				# To make this flake's packages in your NixPkgs package set.
				quickjs.overlay
			];

			outputs-builder = channels:
				let
					inherit (channels.nixpkgs) system;
					# Use the `quickjs` package directly from the input instead.
					quickjs = inputs.quickjs.packages.${system}.quickjs;
				in {
					# Use either `pkgs.quickjs` or `quickjs` in some way.
				};
		};
}
```

## Library

This flake includes a helper library to create QuickJS-based applications using `qjsbootstrap`.

### `quickjs.lib.mkBuilder`

Create a `qjsbootstrap` builder.

Type: `Attrs -> Attrs`

Usage:

```nix
mkBuilder pkgs
```

Result:

```
{ build = attrs: {/* ... */}; }
```

#### `Builder.build`

Build a QuickJS-based application.

Type: `{ files } -> Derivation`

Usage:

```nix
builder.build {
	# Files are appended to `qjsbootstrap` in the order they are listed.
	files = [
		./my-library.js
		./my-script.js
	];
}
```

Result:

```
Derivation
```
