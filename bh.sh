#!/bin/bash

#####################################################
#     Multithreaded blockheight monitor Script      #
#         by ForgingPenguin a.k.a tharude           #
#####################################################

# Variables

## Mainnet Nodes ##
node0=("01.lskwallet.space:8000" "01.lskwallet")
node1=("02.lskwallet.space:8000" "02.lskwallet")
node2=("03.lskwallet.space:8000" "03.lskwallet")
node3=("04.lskwallet.space:8000" "04.lskwallet")
node4=("main-pri.lskwallet.space:8000" "main primary")
node5=("lisk.liskwallet.io:8000" "liskwallet.io")
node6=("lisk.fastwallet.online:8000" "fastwallet")
node7=("lisk.cryptostorms.net:8000" "cryptostorms")
node8=("lisknode.io:8000" "lisknode.io")
node9=("https://login.lisk.io" "login.lisk.io")
#node10=()

## Testnet Nodes ##
tnode0=("testnet.lisk.io:7000" "lisk.io")
tnode1=("test-pri.lskwallet.space:7000" "test primary")
tnode2=("test-bak.lskwallet.space:7000" "test backup")
tnode3=("lisk.testwallet.online:7000" "testwallet")
tnode4=("158.69.216.49:7000" "158.69.216.49")
#tnode5=()
#tnode6=()
#tnode7=()
#tnode8=()
#tnode9=()
#tnode10=()

apicall="/api/loader/status/sync"

## Arrays ##
declare -a nodes=(node0[@] node1[@] node2[@] node3[@] node4[@] node5[@] node6[@] node7[@] node8[@] node9[@]) # node10[@])
declare -a tnodes=(tnode0[@] tnode1[@] tnode2[@] tnode3[@] tnode4[@]) # tnode5[@] tnode6[@] tnode7[@] tnode8[@] tnode9[@])
declare -a height=()
declare -a theight=()

# Get array length

arraylength=${#nodes[@]}
tarraylength=${#tnodes[@]}

# Initial Poloniex data fetch

curl -m 3 -s https://poloniex.com/public?command=returnTicker > ./Polo.txt

## Main loop ##

while true; do

# Spawning curl mainnet processes loop

for n in {1..$arraylength..$arraylength}; do   # start $(arraylength) fetch loops
	for (( i=1; i<${arraylength}+1; i++ )); do
		saddr=${!nodes[i-1]:0:1}
		echo $i $(curl -m 3 -s $saddr$apicall | cut -f 5 -d ":" | sed 's/}$//') >> out.txt &
        done
        wait
done

# Spawning curl testnet processes loop

for n in {1..$tarraylength..$tarraylength}; do   # start $(tarraylength) fetch loops
	for (( i=1; i<${tarraylength}+1; i++ )); do
		tsaddr=${!tnodes[i-1]:0:1}
		echo $i $(curl -m 3 -s $tsaddr$apicall | cut -f 5 -d ":" | sed 's/}$//') >> tout.txt &
	done
	wait
done

# Array read

while read ind line; do
	height[$ind]=$line # assign array values
	done < ./out.txt
rm ./out.txt

while read ind line; do
	theight[$ind]=$line # assign array values
	done < ./tout.txt
rm ./tout.txt

# Output

clear

echo -e "\e[33m----- MAINNET BLOCKHEIGHTS -----\033[0m"

# Finding the highest block

highest=$(echo "${height[*]}" | sort -nr | cut -f 2 -d " ")
echo -e "\e[32m  Highest block is ==> $highest \033[0m"

# Decreasing current blockheight for checks
two=$((highest-2)) # two blocks behind
five=$((highest-5)) # five blocks behind

echo -e "\e[33m--------------------------------\033[0m"

for (( i=1; i<${arraylength}+1; i++ )); do
	sname=${!nodes[i-1]:1:1}
		if [ ! ${height[$i]} ];
		then
			echo -e "  $sname\t\e[31m ==>\tNo Data\033[0m"
		elif [ ${height[$i]} -lt $five ];
		then
			echo -e "  $sname\t\e[31m ==>\t${height[$i]}\033[0m"
		elif [ ${height[$i]} -lt $two ];
		then
			echo -e "  $sname\t\e[33m ==>\t${height[$i]}\033[0m"
		else
			echo -e "  $sname\t\t\e[32m${height[$i]}\033[0m"
		fi
done

echo
echo -e "\e[33m----- TESTNET BLOCKHEIGHTS -----\033[0m"

# Finding the highest testnet block

thighest=$(echo "${theight[*]}" | sort -nr | cut -f 2 -d " ")
echo -e "\e[32m  Highest block is ==> $thighest \033[0m"

# Decreasing current blockheight for checks
two=$((thighest-2)) # two blocks behind
five=$((thighest-5)) # five blocks behind

echo -e "\e[33m--------------------------------\033[0m"

for (( i=1; i<${tarraylength}+1; i++ )); do
	tsname=${!tnodes[i-1]:1:1}
		if [ ! ${theight[$i]} ];
		then
			echo -e "  $tsname\t\e[31m ==>\tNo Data\033[0m"
		elif [ ${theight[$i]} -lt $five ];
		then
			echo -e "  $tsname\t\e[31m ==>\t${theight[$i]}\033[0m"
		elif [ ${theight[$i]} -lt $two ];
		then
			echo -e "  $tsname\t\e[33m ==>\t${theight[$i]}\033[0m"
		else
			echo -e "  $tsname\t\t\e[32m${theight[$i]}\033[0m"
		fi
done

## Ticker for BTC_LSK / ETH_LSK peers on Poloniex
((x++))
if [ $x = "3" ]; then
curl -m 2 -s https://poloniex.com/public?command=returnTicker > ./Polo.txt
x=0
fi
echo -e "\n\n"
cat Polo.txt | cut -d'}' -f129 | tr '{}"",' ':' | awk -F ':::' '{print "     Poloniex BTC_LSK\n" "---------------------------\n" "\033[93m Last: \t\t"$3"\033[0\n", "\033[32m High: \t\t"$5"\033[0\n", "\033[91m" " Low: \t\t"$7"\033[0m";}';
echo
cat Polo.txt | cut -d'}' -f131 | tr '{}"",' ':' | awk -F ':::' '{print "     Poloniex ETH_LSK\n" "---------------------------\n" "\033[93m Last: \t\t"$3"\033[0\n", "\033[32m High: \t\t"$5"\033[0\n", "\033[91m" " Low: \t\t"$7"\033[0m";}';

sleep 10

done
