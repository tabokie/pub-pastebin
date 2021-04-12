
#!/bin/bash
set -ueo pipefail

source ./configurations.sh
SERVERS="${TIDB} ${TIKV}"

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
