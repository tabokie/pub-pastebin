#!/bin/bash
set -ueo pipefail

sudo apt-get -v &> /dev/null && sudo apt-get update && sudo apt-get install -y screen mysql-server vim wget git gcc && curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash && sudo apt -y install sysbench
which yum &> /dev/null && sudo yum install -y screen mysql vim wget git gcc && curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.rpm.sh | sudo bash && sudo yum -y install sysbench
# tiup
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
# go-tpc
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/pingcap/go-tpc/master/install.sh | sh
sleep 1

source ./configurations.sh
SERVERS="${TIDB} ${TIKV} ${OTHER_SERVERS}"

cp ./data/topology_template.yaml ./data/topology.yaml
sed -i "s@DEPLOY_DIR@${DEPLOY_DIR}@g" ./data/topology.yaml
sed -i "s@TIDB_ADDR@${TIDB}@g" ./data/topology.yaml
sed -i "s@USER_NAME@${USER_NAME}@g" ./data/topology.yaml
for addr in ${TIKV}; do
    echo "  - host: ${addr}" >> ./data/topology.yaml
done
# connect to servers
if [[ ${SSH_KEY} = "" ]]; then
    read -p "setup ssh? (y/n)" set_ssh
    if [[ ${set_ssh} = "y" ]]; then
        ssh-keygen -t rsa -b 4096 -f ${PRIVATE_SSH_KEY} -P ""
        for addr in ${SERVERS}; do
            ssh-copy-id -i ${PRIVATE_SSH_KEY} ${USER_NAME}@${addr}
        done
    fi
else
    sudo chmod 600 ${SSH_KEY}
fi
# check connectivity
for addr in ${SERVERS}; do
    addr=${USER_NAME}@${addr}
    ssh ${SSH_FLAGS} ${addr} "sudo echo 'successful sudo'"
    scp ${SSH_FLAGS} ./scripts/* ${addr}:~/
done
# check directory
./prepare_dir.sh
echo "setup alias for servers"
i=0
for addr in ${TIDB}; do
    printf "Host db${i}\n    Hostname ${addr}\n    User ${USER_NAME}\n" >> ~/.ssh/config
    if [ "${PRIVATE_SSH_KEY}" ]; then
	    printf "    IdentityFile ${PRIVATE_SSH_KEY}\n" >> ~/.ssh/config
    fi
    i=$((i+1))
done
i=0
for addr in ${TIKV}; do
    printf "Host kv${i}\n    Hostname ${addr}\n    User ${USER_NAME}\n" >> ~/.ssh/config
    if [ "${PRIVATE_SSH_KEY}" ]; then
	    printf "    IdentityFile ${PRIVATE_SSH_KEY}\n" >> ~/.ssh/config
    fi
    i=$((i+1))
done
i=0
for addr in ${OTHER_SERVERS}; do
    printf "Host ot${i}\n    Hostname ${addr}\n    User ${USER_NAME}\n" >> ~/.ssh/config
    if [ "${PRIVATE_SSH_KEY}" ]; then
	    printf "    IdentityFile ${PRIVATE_SSH_KEY}\n" >> ~/.ssh/config
    fi
    i=$((i+1))
done
sudo chmod 600 ~/.ssh/config
