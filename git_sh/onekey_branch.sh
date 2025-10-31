cd ~/Desktop/$2
sh ../create_new_branch.sh $1
sh ../merge_branch.sh master
sh ../sync_local_to_remote.sh $1
