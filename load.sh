#!/bin/bash
# load.sh tpcc|sysbench
set -ueo pipefail

source configurations.sh

./private/deploy.sh ${VERSION}
./private/sync_cluster.sh ${1}
./private/sync_tikv.sh ${1}
./private/restore_metrics.sh
tiup cluster start ${TIUP_NAME}
mysql -u root -h ${TIDB} -P 4000 --execute="set global tidb_enable_clustered_index=1;"
mysql -u root -h ${TIDB} -P 4000 --execute="set global tidb_hashagg_final_concurrency=1;set global tidb_hashagg_partial_concurrency=1;set global tidb_disable_txn_auto_retry=0;"
sleep 5

go-tpc tpcc --host ${TIDB} --warehouses ${TPCC_WAREHOUSE} -T ${TPCC_LOAD_THREADS} prepare

cd scripts && ./oltp_update_index.lua --mysql-host=${TIDB} --mysql-port=4000 --mysql-user=root --mysql-db=test --db-driver=mysql --report-interval=10 --threads=${SYSBENCH_LOAD_THREADS} --table_size=${SYSBENCH_TABLE_SIZE} --tables=${SYSBENCH_TABLE_COUNT} prepare
cd ..

./private/analyze_database.sh test
echo analyze finished
# wait for pending compaction
sleep 60
./private/stop.sh
sleep 5
./private/backup_cluster.sh ${1}
./listener/on_load_finished.sh
