rm -rf git_sh
mkdir git_sh
ls -lt *.sh | grep "$(date +'%b %d')" | awk '{print $NF}' | xargs -I {} cp {} git_sh/
