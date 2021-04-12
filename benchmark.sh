#!/bin/bash
source configurations.sh

go-tpc tpcc -T ${TPCC_THREADS} --host ${TIDB} --warehouses ${TPCC_WAREHOUSE} --time ${TPCC_DURATION} run | tee nohup.run
./listener/on_benchmark_finished.sh

# cd scripts
# ./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t128.update_non_index.run
# sleep 15m
# ./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t256.update_non_index.run
# sleep 15m
# ./oltp_update_non_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t512.update_non_index.run
# sleep 15m

# ./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t128.update_index.run
# sleep 15m
# ./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t256.update_index.run
# sleep 15m
# ./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t512.update_index.run
# sleep 15m

# ./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=128 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t128.read_write.runsleep 15m
# ./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t256.read_write.runsleep 15m
# ./oltp_read_write.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=512 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=2700 run | tee t512.read_write.run
