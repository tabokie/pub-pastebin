# pub-pastebin

git clone -b $WORKSPACE https://github.com/tabokie/pub-pastebin.git

wget https://raw.githubusercontent.com/tabokie/pub-pastebin/$WORKSPACE/$PATH

## tidb-cluster

Used for quick setup of a standard TIDB cluster. Clone this branch to the
control machine and run the following:

```
# copy the ssh key if any to control machine by scp -i KEY KEY CONTROL:~/
# edit configurations.sh.
# put customized binary and configurations into /binary folder
# with the name tikv-server-SUFFIX and tikv-SUFFIX.toml.
./prepare.sh
./load.sh # load data and create snapshot
./benchmark.sh
./backup_metrics.sh
./load.sh # reload with old metrics preserved
./reset.sh # reset to previous snapshot
./switch.sh NAME [hard] # switch to another version, with option to reset data
```
