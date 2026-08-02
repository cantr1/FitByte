# AWS Notes
This file details how I setup my AWS server to run this project.

1.) Update and install docker
2.) Start and enable docker daemon - `sudo systemctl enable --now docker`
3.) Started a Postgres container - `docker run --name fitbyte-pgsql-db -e POSTGRES_PASSWORD=<pw> -v pgdata:/var/lib/postgresql -p 5432:5432 -d postgres:latest`
4.) Installed psql to test DB connection - `sudo dnf install postgresql15 -y`
5.) Connected to local DB - `psql postgres://postgres:<pw>@localhost:5432`
6.) Installed Goose for DB management and migrations = `go install github.com/pressly/goose/v3/cmd/goose@latest`
7.) Cloned this repo
8.) Ran a goose migration from the `sql/schema` directory
9.) Modified the variables in `bash/env_vars`
10.) Ran the script to install the service in `bash/install_service.sh`

__found that I needed to run this to keep the postgres container restarting on boot: `docker update --restart unless-stopped <container_name_or_id>`__