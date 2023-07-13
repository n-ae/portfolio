host="hostname"
username="postgres"
port="5432"
db_name="my_schema"
table_name="public.my_table"
db_dump_filename="./${db_name}.sql"
pg_dump \
    --host ${host} \
    --port ${port} \
    --username ${username} \
    --schema-only \
    --verbose \
    --table ${table_name} \
    --file ${db_dump_filename} \
    ${db_name}
sed -i '' '/^--/d' ./${db_dump_filename}

role="my_role"
# fetch the lines including a certain string
grep -E "(${role})" ${db_dump_filename} > "${db_name}.${role}.sql"
