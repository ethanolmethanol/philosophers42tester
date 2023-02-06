#!/bin/bash

getphiloprocess(){
	p=$(ps aux | grep '[p]hilo' | grep " $1 $2 $3 $4" | awk '{print $2}')
	# echo $p > /dev/stderr
	if [ -n "$p" ];then kill $p;fi
	echo $p
	exit 0
}

dir="logs"
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

shouldnotstop(){
	(./philo $1 $2 $3 $4 $5 > ./$dir/shnst_$1_$2_$3_$4_$5) &
	sleep 10s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	if [ -n "$p" ];
	then echo -e "$1 $2 $3 $4 $5 :$GREEN success (did not stop)$NC";
	else echo -e "$1 $2 $3 $4 $5 :$RED fail (stopped)$NC";
	fi
}

shouldstop(){
	(./philo $1 $2 $3 $4 $5 > ./$dir/shst_$1_$2_$3_$4_$5) &
	sleep 5s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	if [ -n "$p" ]; 
	then echo -e "$1 $2 $3 $4 $5 :$RED fail (did not stop)$NC";
	else echo -e "$1 $2 $3 $4 $5 :$GREEN success (stopped)$NC";
	fi
}

shoulderror(){
	(./philo $1 $2 $3 $4 $5 2> ./$dir/err_$1_$2_$3_$4_$5) &
	sleep 1s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	e=$(cat ./$dir/err_$1_$2_$3_$4_$5)
	if [ -n "$p" ] || [ -z "$e" ];
	then echo -e "$1 $2 $3 $4 $5 :$RED fail (no error)$NC";
	else echo -e "$1 $2 $3 $4 $5 :$GREEN success (error)$NC";
	fi
}

runtests(){
	$(mkdir -p $dir)
	(shouldnotstop 5 800 200 200) &
	(shouldnotstop 5 600 150 150) &
	(shouldnotstop 4 410 200 200) &
	(shouldnotstop 100 800 200 200) &
	(shouldnotstop 105 800 200 200) &
	(shouldnotstop 200 800 200 200) &
	# wait
	(shouldstop 1 800 200 200) &
	(shouldstop 4 310 200 100) &
	(shouldstop 4 200 205 200) &
	(shouldstop 5 800 201 200 7) & # having tests with same arguments 1 2 3 4 can yield unwanted results.
	(shouldstop 4 410 201 200 10) &
	# wait
	(shoulderror -5 600 200 200) &
	(shoulderror 4 -5 200 200) &
	(shoulderror 4 600 -5 200) &
	(shoulderror 4 600 200 -5) &
	(shoulderror 4 600 200 200 -5) &
	(shoulderror 0 0 0 0 0) &
	wait
	echo "Testing complete !"
	rm -rf $dir
	exit 0
}

runtests

# 5 800 200 200
# no one should die
# 5 600 150 150
# no one should die
# 4 410 200 200
# no one should die
# 100 800 200 200
# no one should die
# 105 800 200 200
# no one should die
# 200 800 200 200
# no one should die

# 1 800 200 200
# a philo should die
# 4 310 200 100
# a philo should die
# 4 200 205 200
# a philo should die
# 5 800 200 200 7
# no one should die, simulation should stop after 7 eats
# 4 410 200 200 10
# no one should die, simulation should stop after 10 eats
# -5 600 200 200
# should error and not run (no crashing)
# 4 -5 200 200
# should error and not run (no crashing)
# 4 600 -5 200
# should error and not run (no crashing)
# 4 600 200 -5
# should error and not run (no crashing)
# 4 600 200 200 -5
# should error and not run (no crashing)