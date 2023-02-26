username="postgres"
port="5432"
db_name="my_database_name"
db_dump_filename="./${db_name}.sql"
pg_dump --host hostname --port ${port} --username ${username} --schema-only --verbose --file ${db_dump_filename} ${db_name}
sed -i '' '/^--/d' ./${db_dump_filename}
