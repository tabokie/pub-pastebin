#!/bin/bash
set -ueo pipefail

sudo apt-get -v &> /dev/null && sudo apt-get update && sudo apt-get install -y screen mysql-server vim wget git gcc
which yum &> /dev/null && sudo yum install -y screen mysql vim wget git gcc
# tiup
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh
# go-tpc
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/pingcap/go-tpc/master/install.sh | sh
sleep 1

source ./configurations.sh
SERVERS="${TIDB} ${TIKV}"

cp ./data/topology_template.yaml ./data/topology.yaml
sed -i "s/TIDB_ADDR/${TIDB}/g" ./data/topology.yaml
sed -i "s/USER_NAME/${USER_NAME}/g" ./data/topology.yaml
for addr in ${TIKV}; do
    echo "  - host: ${addr}" >> ./data/topology.yaml
done
# connect to servers
if [ "${SSH_KEY}" = "" ]; then
    read -p "setup ssh? (y/n)" set_ssh
    if [ "${set_ssh}" = "y" ]; then
        ssh-keygen -t rsa -b 4096 -f ./data/key -P ""
        for addr in ${SERVERS}; do
            ssh-copy-id ${USER_NAME}@${addr}
        done
    fi
fi
# check connectivity
for addr in ${SERVERS}; do
    addr=${USER_NAME}@${addr}
    ssh ${SSH_FLAGS} ${addr} "sudo echo 'successful sudo'"
    scp ${SSH_FLAGS} ./scripts/* ${addr}:~/
done
# check directory
read -p "setup dir? (y/n)" set_dir
if [ "${set_dir}" = "y" ]; then
    for addr in ${SERVERS}; do
        addr=${USER_NAME}@${addr}
        echo "on ${addr}:"
        ssh ${SSH_FLAGS} ${addr} "lsblk"
        read -p "mount dir? (y/n)" mount_dir
        if [ "${mount_dir}" = "y" ]; then
            read -p "which device?" device
            read -p "mount name?" name
            ssh ${SSH_FLAGS} ${addr} "~/mount.sh ${device} /${name} && sudo rm -rf /data \
                && sudo rm -rf /backup && sudo ln -s /${name} /data \
                && sudo ln -s /${name} /backup && sudo chown -R ${USER_NAME}:${USER_NAME} \
                /data && sudo chown -R ${USER_NAME}:${USER_NAME} /backup && sudo \
                chown -R ${USER_NAME}:${USER_NAME} /${name}"
        else
            ssh ${SSH_FLAGS} ${addr} "sudo mkdir -p /data && sudo mkdir -p /backup && sudo chown -R \
                ${USER_NAME}:${USER_NAME} /data && sudo chown -R ${USER_NAME}:${USER_NAME} /backup"
        fi
    done
else
    for addr in ${SERVERS}; do
        addr=${USER_NAME}@${addr}
        OWNER=$(ssh ${SSH_FLAGS} ${addr} "ls -ld ${DATA_DIR}" | awk '{print $3}')
        if [ ${OWNER} != ${USER_NAME} ]; then
            echo "DATA_DIR owner isn't ${USER_NAME}" 
        fi
        OWNER=$(ssh ${SSH_FLAGS} ${addr} "ls -ld ${BACKUP_DIR}" | awk '{print $3}')
        if [ ${OWNER} != ${USER_NAME} ]; then
            echo "BACKUP_DIR owner isn't ${USER_NAME}" 
        fi
    done
fi
echo "setup alias for servers"
i=0
for addr in ${TIDB}; do
    echo "Host db${i}
        Hostname ${addr}
        User ${USER_NAME}
        IdentityFile ${PRIVATE_SSH_KEY}" >> ~/.ssh/config
    if [ "${PRIVATE_SSH_KEY}" ]; then
	echo "IdentityFile ${PRIVATE_SSH_KEY}" >> ~/.ssh/config
    fi
    i=$((i+1))
done
i=0
for addr in ${TIKV}; do
    echo "Host kv${i}
        Hostname ${addr}
        User ${USER_NAME}
        IdentityFile ${PRIVATE_SSH_KEY}" >> ~/.ssh/config
    if [ "${PRIVATE_SSH_KEY}" ]; then
        echo "IdentityFile ${PRIVATE_SSH_KEY}" >> ~/.ssh/config
    fi
    i=$((i+1))
done
sudo chmod 600 ~/.ssh/config
