# dump
pg_dump -h hostname -p port -U username -d database_name -C > dump_file.sql
# restore
psql -h hostname -p port -U username any_database_name < dump_file.sql
