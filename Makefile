build:
	MIX_ENV=prod mix deps.get
	MIX_ENV=prod mix compile
	./node_modules/brunch/bin/brunch build --production
	MIX_ENV=prod mix phoenix.digest

setup:
	npm install
	MIX_ENV=prod mix deps.get
	MIX_ENG=prod mix compile
	./node_modules/brunch/bin/brunch build --production
	MIX_ENV=prod mix phoenix.digest
	MIX_ENV=prod mix ecto.create
	MIX_ENV=prod mix ecto.migrate
