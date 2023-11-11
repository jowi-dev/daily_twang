{
  description = "The Development environment for daily twang";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ pkgs.postgresql pkgs.elixir_1_15 pkgs.pgcli pkgs.inotify-tools pkgs.nodejs ];
        JOE = "WORKS";
        shellHook = ''
          echo "Welcome to the Daily Twang Development Environment" 
          alias joe-setup='echo "hello world"'

          # Setup Envs for PG
          export PGHOST=$HOME/.postgres
          export PGDATA=$PGHOST/data
          export PGDATABASE=postgres
          export PGLOG=$PGHOST/postgres.log

          mkdir -p $PGHOST

          if [ ! -d $PGDATA ]; then
            initdb --auth=trust --no-locale --encoding=UTF8
          fi

          if ! pg_ctl status

          then
            pg_ctl start -l $PGLOG -o "--unix_socket_directories='$PGHOST'"
          fi
          createdb $PGDATABASE
          psql -c "CREATE ROLE postgres LOGIN CREATEDB"

          mix deps.get
          (cd assets/ && npm i)

        '';
      };
    };

}

#how to add shell specific aliases in a nix flake nix
#Adding shell-specific aliases in a Nix flake can be achieved by modifying the `shell.nix` file within your flake to include the desired aliases for the particular shell you are using. Nix flakes are a way to manage Nix packages and configurations in a reproducible manner.
#
#Here's a general approach to adding shell-specific aliases in a `shell.nix` file within a Nix flake:
#
#1. Identify the shell for which you want to add aliases (e.g., bash, zsh).
#
#2. Modify the `shell.nix` file to include the aliases in the shellHook attribute, which is used to execute shell-specific commands when entering the Nix shell.
#
#Here's an example of how you might add aliases for the bash shell in a `shell.nix` file:
#
#```nix
#{
#  description = "A very basic flake";
#
#  inputs = {
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#  };
#
#  outputs = { self, nixpkgs }: {
#
#    devShell.x86_64-linux = pkgs.mkShell {
#      buildInputs = with pkgs; [
#        # Add packages here
#      ];
#
#      shellHook = ''
#        # Add your bash-specific aliases here
#        alias ll='ls -l'
#        alias la='ls -a'
#        # ... more aliases
#      '';
#    };
#  };
#}
#```
#
#In this example, the `shellHook` attribute is used to define the aliases `ll` and `la` for the bash shell. When you enter the Nix shell by running `nix develop` or `nix-shell`, these aliases will be available.
#
#If you are using a different shell, you would need to modify the `shellHook` to be compatible with that shell's syntax. For example, for zsh, you might include zsh-specific syntax or configurations.
#
#Please note that the `shellHook` is a string of shell commands, so make sure you use the correct syntax for the shell you are targeting. If you want to support multiple shells, you can include conditional logic in the `shellHook` to check which shell is being used and set up the appropriate aliases.
#
#Remember that the changes you make to `shell.nix` will only take effect the next time you enter the Nix shell. You can exit and re-enter the shell, or you can source the aliases directly in your current shell session if needed.
