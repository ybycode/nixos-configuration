{ stdenv, lib, buildGoModule, fetchFromGitHub, plugins ? [], vendorHash ? "" }:

with lib;

let imports = flip concatMapStrings plugins (pkg: "\t\t\t_ \"${pkg}\"\n");

	main = ''
		package main

		import (
			caddycmd "github.com/caddyserver/caddy/v2/cmd"

			_ "github.com/caddyserver/caddy/v2/modules/standard"
${imports}
		)

		func main() {
			caddycmd.Main()
		}
	'';


in buildGoModule rec {
	pname = "caddy";
	version = "2.0.0";

	# goPackagePath = "github.com/caddyserver/caddy/v2";

	subPackages = [ "cmd/caddy" ];

	src = fetchFromGitHub {
                owner = "caddyserver";
                repo = "caddy";
		rev = "v2.8.4";
                # hash = lib.fakeHash;
                hash = "sha256-CBfyqtWp3gYsYwaIxbfXO3AYaBiM7LutLC7uZgYXfkQ=";
	};

	inherit vendorHash;

	overrideModAttrs = (_: {
		preBuild    = ''
                  echo '${main}' > cmd/caddy/main.go
                  got mod tidy
                '';
		postInstall = ''
                  cp go.sum go.mod $out/ && ls $out/
                  got mod tidy
                '';
	});

	postPatch = ''
		echo '${main}' > cmd/caddy/main.go
		cat cmd/caddy/main.go
	'';

	postConfigure = ''
		cp vendor/go.sum ./
		cp vendor/go.mod ./
	'';

	meta = with lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
		maintainers = with maintainers; [ rushmorem fpletz zimbatm ];
	};
}
