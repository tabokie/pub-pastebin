# wide table
./scripts/wide_update.lua --mysql-host=172.16.5.31 --mysql-port=4000 --mysql-user=root --mysql-db=test --time=600 --mysql-ignore-errors=all --report-interval=10 --db-driver=mysql --threads=256 --percentile=99 --columns=200 --table_size=1000000 --tables=1 prepare/run
# tpcc
go-tpc --port 4027 -T 20 tpcc --db test --warehouses 5000 --time 8h prepare/run
# ycsb
./go-ycsb/bin/go-ycsb load mysql -p mysql.port=4027 -P ycsb-workload -p threadcount=64 -p readproportion=0.4 -p updateproportion=0.6
# sysbench
./scripts/oltp_update_index.lua --mysql-host=172.16.5.32 --mysql-port=4028 --mysql-user=root --mysql-db=test --time=600 --mysql-ignore-errors=all --report-interval=10 --db-driver=mysql --threads=256 --percentile=99 --columns=200 --table_size=1000000 --tables=1 prepare/run
# tiup
tiup cluster deploy tidb-test nightly ./topology.yaml --user pingcap --password
# mysql
mysql -u root -h 172.16.5.32 -P 4028
# br
bin/br backup full --pd pd0:2379 --storage "local:///data/backup/full" \
    --log-file "/logs/br_backup.log"
# edit remote
vim scp://root@172.16.4.75//nvme0n1/tabokie/deploy-tpcc/tikv-20179/conf/tikv.toml
# br
export AWS_ACCESS_KEY_ID=${AccessKey}
export AWS_SECRET_ACCESS_KEY=${SecretKey}
br restore full --pd "${PDIP}:2379" --storage "s3://${Bucket}/${Folder}" --s3.region "${region}" --send-credentials-to-tikv=true --log-file restorefull.log
