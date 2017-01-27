#!/usr/bin/env bash
source .env

echo "Installing USM-boilerplate"

echo "Pulling and building docker images"
docker-compose pull

echo "Starting DB"
docker run -d --env-file .env -v "$PWD"/data_postgres:/var/lib/postgresql/data --name pg_init_db postgres:"$PG_VERSION" > /dev/null
docker run --rm -v "$PWD":/src -w /src --link pg_init_db:postgres --name pg_init_db_w8 appropriate/nc sh -c "echo \"Waiting for postgres container...\"; until nc -z postgres 5432 &> /dev/null; do sleep 2; done"
echo "Initializing DB"
docker run --rm --link pg_init_db:postgres --name pg_init_db_app postgres:"$PG_VERSION" psql -h postgres -U postgres -c "CREATE DATABASE $PG_DB_NAME;"
docker run --rm --link pg_init_db:postgres --name pg_init_db_app postgres:"$PG_VERSION" psql -h postgres -U postgres -c "ALTER USER $PG_DB_USER WITH SUPERUSER PASSWORD '$PG_DB_PASS';"
if [[ $TEST_DATA_FILE ]]; then
  docker run --rm -v "$PWD"/database:/src --link pg_init_db:postgres --name pg_init_db_app postgres:"$PG_VERSION" psql -h postgres -U postgres -d "$PG_DB_NAME" -f /src/"$TEST_DATA_FILE"
fi

echo "DB init successful"
docker stop pg_init_db > /dev/null
docker rm pg_init_db > /dev/null

echo "Installing node packages"
docker run --rm -ti --env-file .env -v "$PWD"/frontend:/src -w /src kkarczmarczyk/node-yarn yarn
docker run --rm -ti --env-file .env -v "$PWD"/admin:/src -w /src kkarczmarczyk/node-yarn yarn
docker run --rm -ti --env-file .env -v "$PWD"/api:/src -w /src kkarczmarczyk/node-yarn yarn

echo ""
echo "    +-------------------------------------------------------------------+"
echo "    | It seems that the installation was successful.                    |"
echo "    | Now run ./start.sh to start project and open http://localhost     |"
echo "    | Login: admin                                                      |"
echo "    | Password: 11aaAA                                                  |"
echo "    +-------------------------------------------------------------------+"
echo ""
