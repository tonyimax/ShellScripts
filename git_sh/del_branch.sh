cd ~/Desktop/$1
git push origin --delete $2
git switch master
git branch --delete $2
