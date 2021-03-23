# analyze_database.sh test_db_name
for table in $(mysql -u root -h ${TIDB} -P 4000 -D ${1} -Bse "show tables");
  do mysql -u root -h ${TIDB} -P 4000 -D ${1} -Bse "analyze table $table";
  sleep 1;
done
