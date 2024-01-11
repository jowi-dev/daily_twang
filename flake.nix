{
  description = "The Development environment for daily twang";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [ 
          gigalixir
          postgresql 
          elixir_1_15 
          pgcli 
          inotify-tools 
          nodejs 
        ];
        GIGALIXIR_APP_NAME = "daily-twang";
        shellHook = ''
          echo "Welcome to the Daily Twang Development Environment" 
          alias joe-setup='echo "hello world"'

          # Setup Envs for PG
          export APP_NAME=${GIGALIXIR_APP_NAME}
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
