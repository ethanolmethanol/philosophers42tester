#!/bin/bash

getphiloprocess(){
	p=$(ps aux | grep '[p]hilo' | grep " $1 $2 $3 $4" | awk '{print $2}')
	# echo $p > /dev/stderr
	if [ -n "$p" ] && [ -n "$1" ];then kill $p;fi
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

shoulddie(){
	(./philo $1 $2 $3 $4 $5 > ./$dir/shd_$1_$2_$3_$4_$5) &
	s=$(( ( $2 / 1000 ) + 2))
	sleep "$s"s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	e=$(cat ./$dir/shd_$1_$2_$3_$4_$5 | grep died | wc -l)
	if [ -n "$p" ] || [ $e -ne 1 ]; 
	then echo -e "$1 $2 $3 $4 $5 :$RED fail (did not stop or died philo != 1)$NC";
	else echo -e "$1 $2 $3 $4 $5 :$GREEN success (1 died)$NC";
	fi
}

shouldstop(){
	(./philo $1 $2 $3 $4 $5 > ./$dir/shst_$1_$2_$3_$4_$5) &
	s=$((( ( ( 2 + ($1 % 2) ) * $3 * $5 ) / 1000 ) + 2))
	sleep "$s"s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	e=$(cat ./$dir/shst_$1_$2_$3_$4_$5 | grep died | wc -l)
	if [ -n "$p" ] || [ $e -ne 0 ]; 
	then echo -e "$1 $2 $3 $4 $5 :$RED fail (did not stop or died)$NC";
	else echo -e "$1 $2 $3 $4 $5 :$GREEN success (stopped)$NC";
	fi
}

shoulderror(){
	(./philo $@ 2> ./$dir/err_$1_$2_$3_$4_$5) &
	sleep 1s
	p=$(getphiloprocess $1 $2 $3 $4 $5)
	e=$(cat ./$dir/err_$1_$2_$3_$4_$5)
	if [ -z "$e" ];
	then echo -e "$@ :$RED fail (no error)$NC";
	else echo -e "$@ :$GREEN success (error)$NC";
	fi
}

runtests(){
	cd ./philo$bonus
	make && make clean
	$(mkdir -p $dir)
	for n in "-5 600 200 200" "4 -5 200 200" "4 600 -5 200" "4 600 200 -5" "4 600 200 200 -5" "0 0 0 0 0" "" "10" "10 10" "10 10 10" "10 10 10 10 10 10"
	do
		(shoulderror $n) &
		if [ -n "$1" ]; then wait; fi
	done
	for n in "5 800 200 200" "5 600 150 150" "4 410 200 200" "100 800 200 200" "105 800 200 200" "200 800 200 200"
	do
		(shouldnotstop $n) &
		if [ -n "$1" ]; then wait; fi
	done
	for n in "1 800 200 200" "4 310 200 100" "4 200 205 200"
	do
		(shoulddie $n) &
		if [ -n "$1" ]; then wait; fi
	done
	for n in "5 800 201 200 7" "4 410 201 200 10"
	do
		(shouldstop $n) &
		if [ -n "$1" ]; then wait; fi
	done
	wait
	echo "Testing complete !"
	rm -rf $dir
	cd ..
	exit 0
}

if [ "$1" = "bonus" ];
then bonus="_bonus"; runtests bonus;
else bonus=""; runtests;
fi

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