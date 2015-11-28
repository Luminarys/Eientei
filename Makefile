build:
	mix deps.get
	mix compile
	./node_modules/brunch/bin/brunch build --production
	mix phoenix.digest

setup:
	npm install
	bower install
	mix deps.get
	mix compile
	./node_modules/brunch/bin/brunch build --production
	mix phoenix.digest
	mix ecto.create
	mix ecto.migrate
