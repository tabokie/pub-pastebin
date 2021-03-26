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

sudo chmod 600 ${SSH_KEY}

cp ./data/topology_template.yaml ./data/topology.yaml
sed -i "s/TIDB_ADDR/${TIDB}/g" ./data/topology.yaml
sed -i "s/USER_NAME/${USER_NAME}/g" ./data/topology.yaml
sed -i "s/DEPLOY_DIR/${DEPLOY_DIR}/g" ./data/topology.yaml
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
        while read -p "action? (mount/link/mkdir/exit)" action && [ "${action}" != "exit" ]; do
            case "${action}"
            in
                mount)
                    read -p "which device?(sda)" device
                    read -p "mount point?(/data)" mnt
                    ssh ${SSH_FLAGS} ${addr} "~/mount.sh ${device} ${mnt} && sudo \
                        chown -R ${USER_NAME}:${USER_NAME} ${mnt}"
                    ;;
                link)
                    read -p "target?(/data1)" target
                    read -p "name?(/data)" name
                    ssh ${SSH_FLAGS} ${addr} "sudo rm -rf ${name} \
                        && sudo ln -s ${target} ${name} \
                        && sudo chown -R ${USER_NAME}:${USER_NAME} ${name}"
                    ;;
                mkdir)
                    read -p "dir?(/data1)" dir
                    ssh ${SSH_FLAGS} ${addr} "sudo mkdir -p ${dir} && sudo chown -R \
                        ${USER_NAME}:${USER_NAME} ${dir}"
                    ;;
            esac
        done
    done
fi
for addr in ${SERVERS}; do
    addr=${USER_NAME}@${addr}
    OWNER=$(ssh ${SSH_FLAGS} ${addr} "ls -ld ${WORKING_DIR}" | awk '{print $3}')
    if [ ${OWNER} != ${USER_NAME} ]; then
        echo "WORKING_DIR owner isn't ${USER_NAME}"
    fi
    OWNER=$(ssh ${SSH_FLAGS} ${addr} "ls -ld ${BACKUP_DIR}" | awk '{print $3}')
    if [ ${OWNER} != ${USER_NAME} ]; then
        echo "BACKUP_DIR owner isn't ${USER_NAME}"
    fi
done
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
