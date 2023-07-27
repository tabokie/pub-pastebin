#!/bin/bash
source configurations.sh

cd scripts

./oltp_point_select.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.point_select.run
sleep 5m
./oltp_point_select.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t256.point_select.run
sleep 5m
./oltp_point_select.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.point_select.run
sleep 5m

./oltp_read_only.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.read_only.run
sleep 5m
./oltp_read_only.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t256.read_only.run
sleep 5m
./oltp_read_only.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.read_only.run
sleep 5m

./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.update_non_index.run
sleep 5m
./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t256.update_non_index.run
sleep 5m
./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.update_non_index.run

cd ..
./private/stop.sh
./private/restore_cluster.sh ${1}
tiup cluster start ${TIUP_NAME}
cd scripts

./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.update_index.run
sleep 5m
./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t256.update_index.run
sleep 5m
./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.update_index.run

cd ..
./private/stop.sh
./private/restore_cluster.sh ${1}
tiup cluster start ${TIUP_NAME}
cd scripts

./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t128.read_write.run
sleep 5m
./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t256.read_write.run
sleep 5m
./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=${SYSBENCH_DURATION} run | tee t512.read_write.run

