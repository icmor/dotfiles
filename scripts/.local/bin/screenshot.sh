#!/bin/bash

file=$(ls ~/Pictures/ | dmenu -i)

[ -z "$file" ] && exit 0

if [ -f ~/Pictures/${file} ]; then
   select=$(echo -e 'yes\nno' | dmenu -i -p "${file} already exists. Overwrite?")
   [ "$select" != "yes" ] && exit 0
fi

import -window root ~/Pictures/${file}
