#!/bin/bash

source configurations.sh
USER_NAME=root
CLUSTER_NAME="tidb-test"
NODES_ADDR=("172.16.6.211" "172.16.6.213" "172.16.6.159" "172.16.4.203" "172.16.5.213")
TIKV_PORT=20160

CLUSTER_STATE="r"
NODES_STATE=( "r" "r" "r" "r" "r" )

kill_one() {
    node_idx=$((`shuf -i 1-${#NODES_STATE[@]} -n 1` - 1))
    echo "kill node $node_idx by signal"
    ssh kv${node_idx} "sudo killall tikv-server"
    sleep 5s
}
kill_hard() {
    node_idx=$((`shuf -i 1-${#NODES_STATE[@]} -n 1` - 1))
    echo "kill node $node_idx by systemd"
    ssh kv${node_idx} "sudo systemctl stop tikv-20160.service"
    sleep 60s
    echo "restart node $node_idx by systemd"
    ssh kv${node_idx} "sudo systemctl start tikv-20160.service"
    sleep 60s
}
scale() {
    node_idx=$((`shuf -i 1-${#NODES_STATE[@]} -n 1` - 1))
    echo "scale in node $node_idx"
    tiup cluster scale-in $CLUSTER_NAME --node ${NODES_ADDR[node_idx]}:$TIKV_PORT -y
    sleep 150s
    echo "scale out node $node_idx"
    yes | tiup cluster scale-out $CLUSTER_NAME ./topology.${node_idx} -i ${PRIVATE_SSH_KEY}
    sleep 150s
}
toggle() {
    node_idx=$((`shuf -i 1-${#NODES_STATE[@]} -n 1` - 1))
    if [[ ${NODES_STATE[node_idx]} == "r" ]]; then
        NODES_STATE[node_idx]="v"
        echo "toggle node $node_idx to vanilla"
        SOURCE_TOML="tikv.vanilla"
    else
        NODES_STATE[node_idx]="r"
        echo "toggle node $node_idx to raft engine"
        SOURCE_TOML="tikv.engine"
    fi
    ssh kv${node_idx} "cp ${SOURCE_TOML} /data/deploy/tikv-20160/conf/tikv.toml && sudo killall tikv-server"
}
toggle_hard() {
    if [[ ${CLUSTER_STATE} == "r" ]]; then
        CLUSTER_STATE="v"
        SOURCE_META="meta.vanilla"
        echo "toggle cluster to vanilla"
    else
        CLUSTER_STATE="r"
        SOURCE_META="meta.engine"
        echo "toggle cluster to raft engine"
    fi
    cp $SOURCE_META ~/.tiup/storage/cluster/clusters/${CLUSTER_NAME}/meta.yaml
    tiup cluster reload ${CLUSTER_NAME} -y
    sleep 5s
}

declare -a actions=( kill_one kill_hard scale toggle toggle_hard )

while : ; do
    idx=$((`shuf -i 1-${#actions[@]} -n 1` - 1))
    ${actions[idx]}
done
