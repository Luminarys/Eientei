# Eientei

A simple file uploading and sharing service.

## Features
* Simple uploading, no registration required
* Automated archival of files to the Internet Archive
* Fallback service that can be used if migrating from another Pomf clone

## Installation
### Prerequisites
* Erlang
* Elixir
* NPM
* PostgreSQL

### Configuration
1. In `config/` copy file `template.secret.exs` to `dev.secret.exs` and `prod.secret.exs`.
2. In the main directory run `mix phoenix.gen.secret` to generate a new secret.
3. In the two secret config files and using the generated secret, modify the line:
```
config :eientei, Eientei.Endpoint,
  # Generate this by running mix phoenix.gen.secret
  secret_key_base: "Insert generated secret key here!"
```
4. In your two secret configs, look through the settings and set them accordingly:
    * Set the `use_ia_archive` option to true if you would like automatic archivals. If enabled fill out the fields accordingly.
    * Set the `fallback_service` to true if you're migrating from a previous service. If you enable it, set the url parameter, making sure not to add on a trailing /.
    * Configure all settings in the general configuration and database configuration sections.

### Setup
1. In the main directory run `npm install`
2. Run `MIX_ENV=prod mix deps.get` to obtain dependencies
3. Run `MIX_ENV=prod mix compile` to compile code and dependencies
4. Compile assets by running `./node_modules/brunch/bin/brunch build --production`
5. Digest assets by running `MIX_ENV=prod mix phoenix.digest`
6. Run `MIX_ENV=prod mix ecto.create` to create the database in PostgreSQL
7. Run `MIX_ENV=prod mix ecto.migrate` to create the tables within the database

### Running
1. Run `MIX_ENV=prod mix phoenix.server` to start the server.
2. Success! You have succesfully started Eientei and it will be running on port 4000. You should now setup nginx or some other web service to reverse proxy connections to the service.

## TODO
1. Improve code control flow in various places with Monads
2. Bug fixes/general code checks
