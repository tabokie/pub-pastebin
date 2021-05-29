#!/bin/bash
source configurations.sh

go-tpc tpcc -T ${TPCC_THREADS} --warehouses ${TPCC_WAREHOUSE} --time ${TPCC_DURATION} run | tee nohup.run
./listener/on_benchmark_finished.sh

