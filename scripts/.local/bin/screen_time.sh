#!/bin/bash

IFS='
'
for stamp
in $(journalctl -S today -u sleep.target -u multi-user.target | grep target)
do
    case "$stamp" in
	*"Multi-User"*)
	    if [[ "$stamp" == *"Reached"* ]]; then
		state="up"
	    else
		state="down"
	    fi
	    ;;
	*"Sleep"*)
	    if [[ "$stamp" == *"Reached"* ]]; then
		state="down"
	    else
		state="up"
	    fi
	    ;;
    esac
    if [[ -z "$start_time" ]]; then
	if [[ "$state" == "up" ]]; then
	    start_time="$(echo "$stamp" | cut -d ' ' -f 3)"
	else
	    start_time="00:00:00"
	    end_time="$(echo "$stamp" | cut -d ' ' -f 3)"
	fi

    elif [[ "$state" == "up" ]]; then
	start_time="$(echo "$stamp" | cut -d ' ' -f 3)"
	continue

    else
	end_time="$(echo "$stamp" | cut -d ' ' -f 3)"
	time=$(($time \
		    + $(($(date --date "$end_time" +%s) \
			     - $(date --date "$start_time" +%s)))))
    fi
done

time=$(($time \
	    + $(($(date --date $(date +%H:%M) +%s) \
		     - $(date --date "$end_time" +%s)))))
echo $(date -d@$time -u +%H:%M)
