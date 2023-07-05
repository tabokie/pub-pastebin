# ./rm_n.sh <n>
i=0
for e in $(ls); do
    echo "removing $((i++))-th: $e"
    rm $e
    if [[ $i == $1 ]]; then
        break
    fi
done

