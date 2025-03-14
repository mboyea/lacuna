-- ! psql v17.2
-- ? documentation: https://www.postgresql.org/docs/17/
-- ? sql language:  https://www.postgresql.org/docs/17/sql.html
-- ? meta-commands: https://www.postgresql.org/docs/17/app-psql.html#APP-PSQL-META-COMMANDS
-- ? data types:    https://www.postgresql.org/docs/17/datatype.html

-- CREATE DATABASE IF NOT EXISTS $POSTGRES_DATABASE_MAIN
\getenv database_main POSTGRES_DATABASE_MAIN
SELECT 'CREATE DATABASE ' || :'database_main'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'database_main')\gexec

-- USE $POSTGRES_DATABASE_MAIN
\c :database_main

-- CREATE USER IF NOT EXISTS $POSTGRES_WEBSERVER_USERNAME WITH PASSWORD $POSTGRES_WEBSERVER_PASSWORD
\getenv webserver_username POSTGRES_WEBSERVER_USERNAME
\getenv webserver_password POSTGRES_WEBSERVER_PASSWORD
\set do 'BEGIN\n  CREATE USER ' :webserver_username ' WITH PASSWORD ' :'webserver_password' ';\n  EXCEPTION WHEN duplicate_object THEN RAISE NOTICE ''%, skipping'', SQLERRM USING ERRCODE = SQLSTATE;\nEND'
DO :'do';
\unset do

BEGIN TRANSACTION;

/*
CREATE TABLE IF NOT EXISTS asset (
  id SERIAL PRIMARY KEY,
  publish_date TIMESTAMP DEFAULT NOW(),
  mime_type TEXT NOT NULL,
  byte_size INTEGER NOT NULL,
  data BYTEA NOT NULL
);
*/

COMMIT;
