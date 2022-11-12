# https://bbs.archlinux.org/viewtopic.php?pid=1585788#p1585788
pacman -Qi | egrep '^(Name|Installed)' | cut -f2 -d':' | paste - - | column -t | sort -nrk 2 | grep MiB