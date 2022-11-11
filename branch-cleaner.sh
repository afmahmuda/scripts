git branch -vv | gawk '{print $1,$4}' | grep 'gone]' | gawk '{print $1}' >/tmp/merged-branches && vi /tmp/merged-branches && xargs git branch -D </tmp/merged-branches
