{
  description = "RASBET";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      with pkgs;{
        devShell = mkShell
          {
            name = "rasbet";
            buildInputs = [
              inotify-tools
              docker-compose
              elixir
            ];
          };
      }
    );
}

