#!/bin/bash
set -ueo pipefail

source configurations.sh

./private/stop.sh
./private/restore_cluster.sh ${1}
tiup cluster start ${TIUP_NAME}
cd scripts

./oltp_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.insert.run
sleep 5m
./oltp_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.insert.run

cd ..
./private/stop.sh
./private/restore_cluster.sh ${1}
tiup cluster start ${TIUP_NAME}
cd scripts

mysql -u root -h ${TIDB} -P 4000 -Bse "create database test1";
mysql -u root -h ${TIDB} -P 4000 -Bse "create database test2";
./bulk_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test1 --db-driver=mysql --report-interval=10 --threads=32 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} prepare | tee t32.bulk_insert.prepare
./bulk_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test2 --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} prepare | tee t128.bulk_insert.prepare
./bulk_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test1 --db-driver=mysql --report-interval=10 --threads=32 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t32.bulk_insert.run
sleep 30m
./bulk_insert.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test2 --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.bulk_insert.run

