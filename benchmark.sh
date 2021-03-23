#!/bin/bash
source configurations.sh

go-tpc tpcc -T ${TPCC_THREADS} --host ${TIDB} --warehouses ${TPCC_WAREHOUSE} --time ${TPCC_DURATION} run | tee nohup.run
./listener/on_benchmark_finished.sh

cd scripts && ./oltp_write_only.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=256 --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} --time=600 run | tee nohup.run
