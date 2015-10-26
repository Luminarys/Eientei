# Eientei

A simple file uploading and sharing service.

## Features
* Simple uploading, no registration required
* Automated archival of files to the Internet Archive
* Fallback service that can be used if migrating from another Pomf clone

## Installation
### Prerequisites
* Elixir
* NPM
* PostgreSQL

### Configuration
1. In `config/` copy file `template.secret.exs` to `dev.secret.exs` and `prod.secret.exs`.
2. In the main directory run `mix phoenix.gen.secret` to generate a new secret.
3. In the prod secret config files, set the `secret_key_base` parameter using this generated string. Note that if you want to run Eientei in the development environment you should generate another secret key, and apply the following instructions to the dev.secret.exs with appropriately modified settings.
4. In prod secret config, look through the settings and set them accordingly:
    * Set the `use_ia_archive` option to true if you would like automatic archivals. If enabled fill out the fields accordingly.
    * Set the `fallback_service` to true if you're migrating from a previous service. If you enable it, set the url parameter, making sure not to add on a trailing / and look at the alert params.
    * Configure all settings in the general configuration and database configuration sections.

### Setup
* Run `EXPORT MIX_ENV=prod`, or use dev instead of prod if you'd like to use the development environment.
* For first time setup, or if the db needs updates run `make setup`
* If you just want to recompile assets after an update, run `make`

### Running
1. Run `MIX_ENV=prod mix phoenix.server` to start the server. If you'd like to use a custom port, run `PORT=your_port MIX_ENV=prod mix phoenix.server`.
Alternatively you can run `./deploy.sh` which will start your server on either port 21111 or 21112 depending on which one is occupied. You can use this to do upgrades production, setting your nginx to try the 21111 server then 21112 with an upstream block and then just starting a new instance after an upgrade and shutting off the old one.
2. Success! You have succesfully started Eientei and it will be running on port 21111 or the one you defined. You should now setup nginx or some other web service to reverse proxy connections to the service.

## TODO
1. Bug fixes/general code checks
2. Custom styling
3. Tests
