build:
	export MIX_ENV=prod
	mix deps.get
	mix compile
	./node_modules/brunch/bin/brunch build --production
	mix phoenix.digest

setup:
	export MIX_ENV=prod
	npm install
	mix deps.get
	mix compile
	./node_modules/brunch/bin/brunch build --production
	mix phoenix.digest
	mix ecto.create
	mix ecto.migrate
