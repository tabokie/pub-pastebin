#!/bin/bash
set -ueo pipefail

source configurations.sh

./private/deploy.sh
./private/sync_cluster.sh ${1}
./private/sync_tikv.sh ${1}
./private/restore_metrics.sh
tiup cluster start ${TIUP_NAME}
mysql -u root -h ${TIDB} -P 4000 --execute="set global tidb_hashagg_final_concurrency=1;set global tidb_hashagg_partial_concurrency=1;set global tidb_disable_txn_auto_retry=0;"
sleep 5

go-tpc tpcc --warehouses ${TPCC_WAREHOUSE} -T ${TPCC_LOAD_THREADS} prepare

# break down to avoid 'server is busy' failure
TPCC_TABLES="item customer district orders new_order order_line history warehouse stock"
for i in $TPCC_TABLES; do
    echo analyzing table $i
    mysql -u root -h ${TIDB} -P 4000 --database="test" --execute="analyze table ${i};"
    sleep 1
done
echo analyze finished
# wait for pending compaction
sleep 60
./private/stop.sh
sleep 5
./private/backup_cluster.sh ${1}
./listener/on_load_finished.sh

