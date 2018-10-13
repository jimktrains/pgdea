all: setup install_schema test clean

clean:
	dropdb pgdea_test || true

setup:
	createdb pgdea_test

install_schema:
	cat schema.sql | psql pgdea_test

test:
	cat test.sql | psql pgdea_test
