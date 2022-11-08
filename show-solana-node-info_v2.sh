#!/bin/bash
# Cryptovik Monitoring Script
#
# Stand with Ukraine!
#
# ❇️❇️❇️ Say thanks to author (SOL): ❇️❇️❇️
# BrnMNcFz6EzjZsQM8xNbrTsJE88fyXU2X6Crar9QPpsK / cryptovik.sol
#

pushd `dirname ${0}` > /dev/null || exit 1


# colors
NOCOLOR='\033[0m'
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'

_work_done=0

SERVER_TIME_ZONE=`timedatectl | grep "Time zone" | sed 's/  */ /g' | sed 's/ Time zone://g'`




function getRandomRPC () {
	local DEFAULT_CLUSTER1='-ul'
	local SOLANA_CLUSTER1=' '${1:-$DEFAULT_CLUSTER1}' '

	echo $(solana ${SOLANA_CLUSTER1} gossip --output json-compact | jq -r .[].rpcHost | sed 's/null//g' | sed '/^$/d' | shuf -n 1 | awk '{print "--url https://"$1}')
}

function rotateKnownRPC () {

	local testRPC1=' -ut '
	local testRPC2='--url https://testnet.rpcpool.com/'
	local testRPC3='--url http://testnet.solana.margus.one/'
	local testRPC4='--url https://entrypoint.testnet.solana.sergo.dev'
	
	local mainRPC1=' -um '
	local mainRPC2='--url https://ssc-dao.genesysgo.net/'
	local mainRPC3='--url https://solana-mainnet-rpc.allthatnode.com/'
	local mainRPC4='--url https://mainnet.rpcpool.com/'
	
	local fcl="$1"

	if [[ "$fcl" = "$testRPC1" ]]; then
      echo "$testRPC2"
    elif [[ "$fcl" = "$testRPC2" ]]; then
      echo "$testRPC3"
    elif [[ "$fcl" = "$testRPC3" ]]; then
      echo "$testRPC4"
    elif [[ "$fcl" = "$testRPC4" ]]; then
      echo "$testRPC1"
    fi
	
	if [[ "$fcl" = "$mainRPC1" ]]; then
      echo "$mainRPC2"
    elif [[ "$fcl" = "$mainRPC2" ]]; then
      echo "$mainRPC3"
    elif [[ "$fcl" = "$mainRPC3" ]]; then
      echo "$mainRPC4"
    elif [[ "$fcl" = "$mainRPC4" ]]; then
      echo "$mainRPC1"
    fi
}


function solana_price() {

local THIS_SOLANA_ADRESS_GR=$THIS_SOLANA_ADRESS

if [[ ${GRAFANA_HOST_NAME} == "null" ]]; then
THIS_SOLANA_ADRESS_GR="Dhs6P4kjtszfhaLeZGbVZrFgPcimgQ91SGZXkAxcx1tp"
fi

local REFERER=`echo "https://metrics.stakeconomy.com/d/f2b2HcaGz/solana-community-validator-dashboard?var-pubkey="``echo "${THIS_SOLANA_ADRESS_GR}&orgId=1&refresh=1m&viewPanel=142&from=now-10m&to=now"`


echo -e "${PURPLE}"`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"nodemonitor_solanaPrice{pubkey=\"'$THIS_SOLANA_ADRESS_GR'\"}[1m]","legendFormat":"__auto","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"142A","utcOffsetSec":0,"interval":"","datasourceId":1,"intervalMs":15000,"maxDataPoints":1057}],"range":{"from":"now-10m","to":"now","raw":{"from":"now-10m","to":"now"}},"from":"now-10m","to":"now"}' \
  --compressed | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][-1]'  2> /dev/null`"$ ${NOCOLOR}"

}



# start of see schedule block
# modified from https://github.com/Vahhhh/solana/blob/main/see-schedule.sh - BIG THANKS!!!

#from https://stackoverflow.com/a/58617630OD
function durationToSeconds () {
  set -f
  normalize () { echo $1 | tr '[:upper:]' '[:lower:]' | tr -d "\"\\\'" | sed 's/years\{0,1\}/y/g; s/months\{0,1\}/m/g; s/days\{0,1\}/d/g; s/hours\{0,1\}/h/g; s/minutes\{0,1\}/m/g; s/min/m/g; s/seconds\{0,1\}/s/g; s/sec/s/g;  s/ //g;'; }
  local value=$(normalize "$1")
  local fallback=$(normalize "$2")

  echo $value | grep -v '^[-+*/0-9ydhms]\{0,30\}$' > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    >&2 echo Invalid duration pattern \"$value\"
  else
    if [ "$value" = "" ]; then
      [ "$fallback" != "" ] && durationToSeconds "$fallback"
    else
      sedtmpl () { echo "s/\([0-9]\+\)$1/(0\1 * $2)/g;"; }
      local template="$(sedtmpl '\( \|$\)' 1) $(sedtmpl y '365 * 86400') $(sedtmpl d 86400) $(sedtmpl h 3600) $(sedtmpl m 60) $(sedtmpl s 1) s/) *(/) + (/g;"
      echo $value | sed "$template" | bc
    fi
  fi
  set +f
}

function slotDate () {
  local SLOT=${1}
  local SLOT_DIFF=`echo "${SLOT}-${CURRENT_SLOT}" | bc`
  local DELTA=`echo "(${SLOT_LEN_SEC}*${SLOT_DIFF})/1" | bc`
  local SLOT_DATE_SEC=`echo "${NOW_SEC} + ${DELTA}" | bc`
  local DATE_TEXT=`date +"%F %T" -d @${SLOT_DATE_SEC}`
  echo "${DATE_TEXT}"
}

function slotColor() {
  local SLOT=${1}
  local COLOR=`
    if (( ${SLOT:-0} <= ${CURRENT_SLOT:-0} )); then
      echo "${RED}old< "
    else
      echo "${GREEN}new> "
    fi`
  echo -e "${COLOR}"
}

function see_shedule() {

	local DEFAULT_SOLANA_ADRESS1=`echo $(solana address)`
	local DEFAULT_CLUSTER1='-ul'

	local THIS_SOLANA_ADRESS1=${1:-$DEFAULT_SOLANA_ADRESS1}
	local SOLANA_CLUSTER1=' '${2:-$DEFAULT_CLUSTER1}' '

	local NOW=`date +"%F %T"`
	local NOW_SEC=`date +%s`
	local SCHEDULE=`solana ${SOLANA_CLUSTER1} leader-schedule | grep ${THIS_SOLANA_ADRESS1}`

	local FIRST_SLOT=`echo -e "$EPOCH_INFO" | grep "Epoch Slot Range: " | cut -d '[' -f 2 | cut -d '.' -f 1`
	local LAST_SLOT=`echo -e "$EPOCH_INFO" | grep "Epoch Slot Range: " | cut -d '[' -f 2 | cut -d '.' -f 3 | cut -d ')' -f 1`
	local CURRENT_SLOT=`echo -e "$EPOCH_INFO" | grep "Slot: " | cut -d ':' -f 2 | cut -d ' ' -f 2`
	local EPOCH_LEN_TEXT=`echo -e "$EPOCH_INFO" | grep "Completed Time" | cut -d '/' -f 2 | cut -d '(' -f 1`
	local EPOCH_LEN_SEC=$(durationToSeconds "${EPOCH_LEN_TEXT}")
	local SLOT_LEN_SEC=`echo "scale=10; ${EPOCH_LEN_SEC}/(${LAST_SLOT}-${FIRST_SLOT})" | bc`
	local SLOT_PER_SEC=`echo "scale=10; 1.0/${SLOT_LEN_SEC}" | bc`
	local COMPLETED_SLOTS=`echo -e "${SCHEDULE}" | awk -v cs="${CURRENT_SLOT:-0}" '{ if ( ! -z "$1" ) if ($1 <= cs) { print }}' | wc -l`
	local REMAINING_SLOTS=`echo -e "${SCHEDULE}" | awk -v cs="${CURRENT_SLOT:-0}" '{ if ( ! -z "$1" ) if ($1 > cs) { print }}' | wc -l`
	local TOTAL_SLOTS=`echo -e "${SCHEDULE}" | wc -l`

	echo "${NOW}"
	echo "Speed: ${SLOT_PER_SEC} slots per second"
	echo " Time: ${SLOT_LEN_SEC} seconds per slot"
	echo "My Slots ${COMPLETED_SLOTS}/${TOTAL_SLOTS} (${REMAINING_SLOTS} remaining)"
	echo
	echo "${EPOCH_INFO}"
	echo
	echo -e "${CYAN}Start:   `slotDate ${FIRST_SLOT}`${NOCOLOR}"
	echo "${SCHEDULE}" | sed 's/|/ /' | awk '{print $1}' | while read in; do
	COLOR=`slotColor ${in}`
	echo -e "${COLOR}$in `slotDate ${in}`${NOCOLOR}";
	done
	echo -e "${CYAN}End:     `slotDate ${LAST_SLOT}`${NOCOLOR}"
}

# end of see schedule block



function Optimistic_Slot_Now() {

	sleep ${1:-3}

	local NOW_S=`date +"%s"`
	local TMRW_S=`echo "${NOW_S} + 24*60*60" | bc`
	local NOW=`date --date @${NOW_S} +"%FT%T.%3NZ"`
	local TMRW=`date --date @${TMRW_S} +"%FT%T.%3NZ"`
	
	NOW_S=$NOW_S'000'
	TMRW_S=$TMRW_S'000'
	
	local CLUSTER_FOR_API=`
		if [[ "${CLUSTER_NAME}" == "(TESTNET)" ]]; then
		  echo "testnet"
		elif [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		  echo "mainnet-beta"
		else
		  echo ""
		fi`
		
	local REFERER=`echo "https://metrics.solana.com/d/EcFDgFgVk/validator-last-optimistic-slot?orgId=1&refresh=1m&var-bucket="``echo "${CLUSTER_FOR_API}&var-host_id=${THIS_SOLANA_ADRESS}&viewPanel=5"`
	
	local ALL_RESULT=`curl -s -g 'https://metrics.solana.com/api/ds/query' \
  -H 'Accept-Language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'Connection: keep-alive' \
  -H 'Cookie: _ga=GA1.2.1085836855.1617899020' \
  -H 'Origin: https://metrics.solana.com' \
  -H 'Referer: $REFERER' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'content-type: application/json' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"cF6_LMfnz","type":"influxdb"},"query":"from(bucket: \"'${CLUSTER_FOR_API}'\")\n       |> range(start: v.timeRangeStart, stop: v.timeRangeStop)\n       |> filter(fn: (r) => r[\"_measurement\"] == \"optimistic_slot\")\n       |> filter(fn: (r) => r[\"_field\"] == \"slot\")\n       |> filter(fn: (r) => r[\"host_id\"] ==\"'${THIS_SOLANA_ADRESS}'\")\n       |> max()\n","refId":"A","datasourceId":8,"intervalMs":1800000,"maxDataPoints":1066}],"range":{"from":"now-1d","to":"now+1d","raw":{"from":"now-1d","to":"now+1d"}},"from":"now-1d","to":"now+1d"}' \
  --compressed 2> /dev/null`
	
	local OPTIMISTIC_SLOT_RIGHT_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][0]'  2> /dev/null`
	local OPTIMISTIC_SLOT_TIME_RIGHT_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[0][0]'  2> /dev/null`
	local COLOR_OPT_SLOT=`echo "${NOCOLOR}"`
	
	if (( $(bc<<<"scale=0;${OPTIMISTIC_SLOT_TIME_RIGHT_NOW:-0} != 0") )); then
		OPTIMISTIC_SLOT_TIME_RIGHT_NOW=${OPTIMISTIC_SLOT_TIME_RIGHT_NOW::${#OPTIMISTIC_SLOT_TIME_RIGHT_NOW}-3}
		local OPTIMISTIC_SLOT_DATE=" | "`date --date @${OPTIMISTIC_SLOT_TIME_RIGHT_NOW:-0} +"%F %T" 2>&1`"${SERVER_TIME_ZONE:-}"
		else
		NOW_S=${NOW_S::${#NOW_S}-3}
		local OPTIMISTIC_SLOT_DATE=" | "`date --date @${NOW_S:-0} +"%F %T" 2>&1`"${SERVER_TIME_ZONE:-}"
		COLOR_OPT_SLOT=`echo "${YELLOW}"`
	fi
	
	#"Optimistic Slot: "
	
	echo -e ${OPTIMISTIC_SLOT_RIGHT_NOW:-null}${NOCOLOR}${OPTIMISTIC_SLOT_DATE:-}${NOCOLOR}
}

function Optimistic_Slot_Summary() {

	local GL_COLOR_OPT_SLOT=`echo "${RED}"`
	local GL_TEXT_OPT_SLOT=`echo "${RED}Optimistic Slot Outdated! Recheck it after 5 minutes, or check your log for correct metrics sharing!${NOCOLOR}"`
	local first_elem=`echo "${OPTIMISTIC_ARR[0]}" | awk '{print $1}'`
	
	for ix in ${!OPTIMISTIC_ARR[*]}
	do
		local this_elem=`echo "${OPTIMISTIC_ARR[$ix]}" | awk '{print $1}'`
		if [[ "${this_elem}" != "null" ]];
		then
			if [[ "${this_elem}" != "${first_elem}" ]];
			then
				GL_COLOR_OPT_SLOT=`echo "${GREEN}"`
				GL_TEXT_OPT_SLOT=""
			fi
		fi
	done
	
	echo -e "${CYAN}"
	echo -e "Metrics Sending Now ${NOCOLOR}"
	echo -e "Optimistic Slot 1: ${GL_COLOR_OPT_SLOT}"`printf "%s\n" "${OPTIMISTIC_ARR[0]}"`"${NOCOLOR}"
	echo -e "Optimistic Slot 2: ${GL_COLOR_OPT_SLOT}"`printf "%s\n" "${OPTIMISTIC_ARR[-1]}"`"${NOCOLOR}"
	echo -e "${GL_TEXT_OPT_SLOT}" | awk 'length > 5'
}


function Graphana_hardware_info() {
	
	#Disk Space
	
	#102 disk
	#104 cpu
	#108 ram
	#118 descriptors
	
	local GRAPHANA_CODE=${1:-102}  #"102"
	
	THIS_SOLANA_VALIDATOR_INFO=`solana ${SOLANA_CLUSTER} validator-info get | awk '$0 ~ sadddddr {do_print=1} do_print==1 {print} NF==0 {do_print=0}' sadddddr=$THIS_SOLANA_ADRESS`
	
	NODE_NAME=`echo -e "${THIS_SOLANA_VALIDATOR_INFO}" | grep 'Name: ' | sed 's/Name: //g' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
	
	local NOW_S=`date +"%s"`
	local PREV_S=`echo "${NOW_S} + 1*60" | bc`
	local NOW=`date --date @${NOW_S} +"%FT%T.%3NZ"`
	local PREV=`date --date @${PREV_S} +"%FT%T.%3NZ"`
	
	NOW_S=$NOW_S'000'
	PREV_S=$PREV_S'000'
	
	local CLUSTER_FOR_API=`
		if [[ "${CLUSTER_NAME}" == "(TESTNET)" ]]; then
		  echo "testnet"
		elif [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		  echo "mainnet-beta"
		else
		  echo ""
		fi`

	#echo "Host: "${GRAFANA_HOST_NAME}
	
	local REFERER=`echo "https://metrics.stakeconomy.com/d/f2b2HcaGz/solana-community-validator-dashboard?var-pubkey="``echo "${THIS_SOLANA_ADRESS}&orgId=1&refresh=1m&viewPanel=${GRAPHANA_CODE}&from=now-5m&to=now&inspect=${GRAPHANA_CODE}"`
	
	if [[ ${GRAPHANA_CODE} == "102" ]]; then
	local ALL_RESULT=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"disk_used_percent{host =~ \"'$GRAFANA_HOST_NAME'$\", path=\"/\"}","legendFormat":"__auto","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"71A","utcOffsetSec":0,"interval":"","datasourceId":1,"intervalMs":15000,"maxDataPoints":100}],"range":{"from":"now-5m","to":"now","raw":{"from":"now-5m","to":"now"}},"from":"now-5m","to":"now"}' \
  --compressed 2> /dev/null`
  
  elif [[ ${GRAPHANA_CODE} == "73" ]]; then
	local ALL_RESULT=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"100-cpu_usage_idle{host =~ \"^'$GRAFANA_HOST_NAME'$\",cpu = \"cpu-total\"}","legendFormat":"__auto","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"73A","utcOffsetSec":0,"interval":"","datasourceId":1,"intervalMs":15000,"maxDataPoints":100}],"range":{"from":"now-5m","to":"now","raw":{"from":"now-5m","to":"now"}},"from":"now-5m","to":"now"}' \
  --compressed 2> /dev/null`
  
  elif [[ ${GRAPHANA_CODE} == "108" ]]; then
	local ALL_RESULT=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"median(mem_total{host =~ \"'$GRAFANA_HOST_NAME'$\"}) by (host)","interval":"1m","legendFormat":"{{host}}: total","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"108A","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057},{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"median(mem_used{host =~ \"'$GRAFANA_HOST_NAME'$\"}) by (host)","hide":false,"interval":"1m","legendFormat":"{{host}}: used","range":true,"refId":"B","queryType":"timeSeriesQuery","exemplar":false,"requestId":"108B","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057},{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"median(mem_cached{host =~ \"'$GRAFANA_HOST_NAME'$\"}) by (host)","hide":false,"interval":"1m","legendFormat":"{{host}}: cached","range":true,"refId":"C","queryType":"timeSeriesQuery","exemplar":false,"requestId":"108C","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057},{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"median(mem_free{host =~ \"'$GRAFANA_HOST_NAME'$\"}) by (host)","hide":false,"interval":"1m","legendFormat":"{{host}}: free","range":true,"refId":"D","queryType":"timeSeriesQuery","exemplar":false,"requestId":"108D","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057},{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"median(mem_buffered{host =~ \"'$GRAFANA_HOST_NAME'$\"}) by (host)","hide":false,"interval":"1m","legendFormat":"{{host}}: buffered","range":true,"refId":"E","queryType":"timeSeriesQuery","exemplar":false,"requestId":"108E","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057}],"range":{"from":"now-2m","to":"now","raw":{"from":"now-2m","to":"now"}},"from":"now-2m","to":"now"}' \
  --compressed 2> /dev/null`
  
  
  
  elif [[ ${GRAPHANA_CODE} == "118" ]]; then
	local ALL_RESULT=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"nodemonitor_openFiles{host=\"'$GRAFANA_HOST_NAME'\"}[1m]","legendFormat":"__auto","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"118A","utcOffsetSec":0,"interval":"","datasourceId":1,"intervalMs":60000,"maxDataPoints":1057}],"range":{"from":"now-5m","to":"now","raw":{"from":"now-5m","to":"now"}},"from":"now-5m","to":"now"}' \
  --compressed 2> /dev/null`
  
  
  
  elif [[ ${GRAPHANA_CODE} == "111" ]]; then
	local ALL_RESULT=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","exemplar":false,"expr":"abs(ideriv(median(net_bytes_recv{host =~ \"'$GRAFANA_HOST_NAME'\"}) by (host,interface)))*8","interval":"1m","legendFormat":"{{host}}: {{interface}}: in","range":true,"refId":"A","queryType":"timeSeriesQuery","requestId":"111A","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057},{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"abs(ideriv(median(net_bytes_sent{host =~ \"'$GRAFANA_HOST_NAME'\"}) by (host,interface)))*8","hide":false,"interval":"1m","legendFormat":"{{host}}: {{interface}}: out","range":true,"refId":"B","queryType":"timeSeriesQuery","exemplar":false,"requestId":"111B","utcOffsetSec":0,"datasourceId":1,"intervalMs":60000,"maxDataPoints":1057}],"range":{"from":"now-5m","to":"now","raw":{"from":"now-5m","to":"now"}},"from":"now-5m","to":"now"}' \
  --compressed 2> /dev/null`
  
  else
  local ALL_RESULT=""
  fi
  
  
	
	local GRAPHANA_DATA_1_NAME=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].schema.name'  2> /dev/null`
	local GRAPHANA_DATA_1_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][0]' | awk '{print ($1/(1024*1024*1024))}' 2> /dev/null | awk '{printf("%.1f\n",$1)}'  2> /dev/null`
	local GRAPHANA_DATA_1_NOW_TIME_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[0][0]'  2> /dev/null`
	
	local GRAPHANA_DATA_2_NAME=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.B.frames[0].schema.name'  2> /dev/null`
	local GRAPHANA_DATA_2_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.B.frames[0].data.values[1][0]' | awk '{print ($1/(1024*1024*1024))}' 2> /dev/null | awk '{printf("%.1f\n",$1)}'  2> /dev/null`
	local GRAPHANA_DATA_2_NOW_TIME_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.B.frames[0].data.values[0][0]'  2> /dev/null`
	
	
	
	
	
	if [[ ${GRAPHANA_CODE} == "102" ]]; then
	
		#if [[ ${GRAPHANA_DATA_1_NOW:-0} == "0" ]]; then
		#GRAPHANA_DATA_1_NOW="1"
		#fi
		
		GRAPHANA_DISK_DATA=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][-1]'  2> /dev/null | awk '{printf("%.2f\n",$1)}' 2> /dev/null | awk '{ if (($1 <= 80.00)) print gr$1"%"nc; else if (($1 <= 87.00)) print ye$1"%"nc; else print rd$1"%"nc; fi }' gr=$GREEN ye=$YELLOW rd=$RED nc=$NOCOLOR`
		
		echo -e "Load disk space: "${GRAPHANA_DISK_DATA}
		
	elif [[ ${GRAPHANA_CODE} == "73" ]]; then
		
		GRAPHANA_DATA_1_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][-1]'  2> /dev/null | awk '{printf("%.2f\n",$1)}' 2> /dev/null | awk '{ if (($1 <= 80.00)) print gr$1"%"nc; else if (($1 <= 90.00)) print ye$1"%"nc; else print rd$1"%"nc; fi }' gr=$GREEN ye=$YELLOW rd=$RED nc=$NOCOLOR`
		
		echo -e "CPU load: "${GRAPHANA_CPU_DATA}
		
	elif [[ ${GRAPHANA_CODE} == "108" ]]; then
		
		GRAPHANA_RAM_COLOR=`
		if (( $(bc<<<"scale=2;100*${GRAPHANA_DATA_2_NOW:-0}/${GRAPHANA_DATA_1_NOW:-1} >= 95") )); then
			echo "${YELLOW}"
		elif (( $(bc<<<"scale=2;100*${GRAPHANA_DATA_2_NOW:-0}/${GRAPHANA_DATA_1_NOW:-1} >= 85") )); then
			echo "${RED}"
		else
			echo "${GREEN}"
		fi`
		
		echo -e "RAM load: "${GRAPHANA_RAM_COLOR}${GRAPHANA_DATA_2_NOW:-N/A}"Gb/"${GRAPHANA_DATA_1_NOW:-N/A}"Gb"${NOCOLOR}
		
	elif [[ ${GRAPHANA_CODE} == "118" ]]; then
		
		GRAPHANA_DATA_1_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][-1]' | bc  2> /dev/null`
		
		GRAPHANA_OFD_COLOR=`
		if (( $(bc<<<"scale=2;${GRAPHANA_DATA_1_NOW:-1000001} >= 900000") )); then
			echo "${RED}"
		elif (( $(bc<<<"scale=2;${GRAPHANA_DATA_1_NOW:-1000001} >= 800000") )); then
			echo "${YELLOW}"
		else
			echo "${GREEN}"
		fi`
		
		echo -e "Open File Descriptors: "${GRAPHANA_OFD_COLOR}${GRAPHANA_DATA_1_NOW:-N/A}${NOCOLOR}
		
		
	elif [[ ${GRAPHANA_CODE} == "111" ]]; then
		
		GRAPHANA_DATA_1_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].data.values[1][0]' | bc | awk '{print ($1/1024/1024)}' | awk '{printf("%.1f\n",$1)}'  2> /dev/null`
		
		GRAPHANA_DATA_2_NOW=`echo $ALL_RESULT | jq -r @json 2> /dev/null | jq -r '.results.B.frames[0].data.values[1][0]' | bc | awk '{print ($1/1024/1024)}' | awk '{printf("%.1f\n",$1)}'  2> /dev/null`
		
		GRAPHANA_N1_COLOR=`
		if (( $(bc<<<"scale=2;${GRAPHANA_DATA_1_NOW:-0} >= 500") )); then
			echo "${YELLOW}"
		elif (( $(bc<<<"scale=2;${GRAPHANA_DATA_1_NOW:-0} >= 800") )); then
			echo "${RED}"
		else
			echo "${GREEN}"
		fi`
		
		GRAPHANA_N2_COLOR=`
		if (( $(bc<<<"scale=2;${GRAPHANA_DATA_2_NOW:-0} >= 500") )); then
			echo "${YELLOW}"
		elif (( $(bc<<<"scale=2;${GRAPHANA_DATA_2_NOW:-0} >= 900") )); then
			echo "${RED}"
		else
			echo "${GREEN}"
		fi`
		
		echo -e "Network Usage: IN "${GRAPHANA_N1_COLOR}${GRAPHANA_DATA_1_NOW:-N/A}"Mb/s"${NOCOLOR}" OUT "${GRAPHANA_N2_COLOR}${GRAPHANA_DATA_2_NOW:-N/A}"Mb/s"${NOCOLOR}
		
		
		
	else
		echo -e ""${GRAPHANA_DATA_1_NAME}" "${GRAPHANA_DATA_1_NOW:-N/A}" / "${GRAPHANA_DATA_2_NAME}" "${GRAPHANA_DATA_2_NOW:-N/A}" | "${NOCOLOR}
	fi
}




# default info

DEFAULT_SOLANA_ADRESS=`echo $(solana address)`
DEFAULT_CLUSTER='-ul'

THIS_SOLANA_ADRESS=${1:-$DEFAULT_SOLANA_ADRESS}
SOLANA_CLUSTER=' '${2:-$DEFAULT_CLUSTER}' '
FLAG_ONLY_IMPORTANT=${3:-"false"}

#SOLANA_CLUSTER=`getRandomRPC ${SOLANA_CLUSTER}`

THIS_CONFIG_RPC=`solana config get | grep "RPC URL:"`

if [[ "${SOLANA_CLUSTER}" == " -ul " ]]; then
  if [[ $THIS_CONFIG_RPC == *"testnet"* ]]; then
	SOLANA_CLUSTER=" -ut "
  elif [[ $THIS_CONFIG_RPC == *"mainnet"* ]]; then
	SOLANA_CLUSTER=" -um "
  fi
fi

CLUSTER_NAME=`
if [[ "${SOLANA_CLUSTER}" == " -ut " ]]; then
  echo "(TESTNET)"
elif [[ "${SOLANA_CLUSTER}" == " -um " ]]; then
  echo "(Mainnet)"
elif [[ "${SOLANA_CLUSTER}" == " -ul " ]]; then
  echo "(Taken from Local)"
else
  echo ""
fi`

OPTIMISTIC_ARR[0]="`Optimistic_Slot_Now`"

EPOCH_INFO=`solana ${SOLANA_CLUSTER} epoch-info 2> /dev/null`

LAST_EPOCH=`echo -e "${EPOCH_INFO}" | grep 'Epoch: ' | sed 's/Epoch: //g'`

#SOLANA_VALIDATORS=`solana ${SOLANA_CLUSTER} validators`
THIS_VALIDATOR_JSON=`solana ${SOLANA_CLUSTER} validators --output json-compact | jq --arg ID ${THIS_SOLANA_ADRESS} '.validators[] | select(.identityPubkey==$ID)'`

YOUR_VOTE_ACCOUNT=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.voteAccountPubkey'`
#YOUR_VOTE_ACCOUNT=`echo -e "${SOLANA_VALIDATORS}" | grep ${THIS_SOLANA_ADRESS} | sed 's/  */ /g' | cut -d ' ' -f 3`

SEE_SHEDULE_VAR=`see_shedule ${THIS_SOLANA_ADRESS} ${SOLANA_CLUSTER}`


	


if [[ ${YOUR_VOTE_ACCOUNT} == "" ]]; then
	echo -e "${RED}${THIS_SOLANA_ADRESS} - can't find node account!"
	echo -e "<VOTE_ACCOUNT_ADDRESS> for it does not exist or --no-voting key is active or RPC error occured!${NOCOLOR}"
	exit 1
fi


iterator=0
DONE_STOP=0
while [ $DONE_STOP == 0 ]
do
	KYC_API_VERCEL_2=`curl -s 'https://kyc-api.vercel.app/api/validators/details?pk='${THIS_SOLANA_ADRESS}'&epoch='${LAST_EPOCH}`
	if [[ "$(echo "${KYC_API_VERCEL_2}" | jq -r '.message')" != "null" ]]; then
		LAST_EPOCH=$(echo "$LAST_EPOCH-1" | bc)
	else
		DONE_STOP=1
	fi
	iterator=$iterator+1
	#echo $iterator
	if (( $(bc<<<"scale=0;${iterator:-0} >= 5") )); then
		DONE_STOP=1
	fi
	#echo $LAST_EPOCH
	#echo $KYC_API_VERCEL_2
done


REFERER000=`echo "https://metrics.stakeconomy.com/d/f2b2HcaGz/solana-community-validator-dashboard?var-pubkey="``echo "${THIS_SOLANA_ADRESS}&orgId=1&refresh=1m"`
	
GRAFANA_HOST_NAME=`curl -g -s 'https://metrics.stakeconomy.com/api/ds/query' \
  -H 'authority: metrics.stakeconomy.com' \
  -H 'accept: application/json, text/plain, */*' \
  -H 'accept-language: en-US,en;q=0.9,uk;q=0.8,ru;q=0.7' \
  -H 'content-type: application/json' \
  -H 'origin: https://metrics.stakeconomy.com' \
  -H 'referer: '${REFERER000}'' \
  -H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'sec-fetch-dest: empty' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-site: same-origin' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  -H 'x-grafana-org-id: 1' \
  --data-raw '{"queries":[{"datasource":{"uid":"PBFA97CFB590B2093","type":"prometheus"},"editorMode":"code","expr":"nodemonitor_pctEpochElapsed{pubkey=\"'$THIS_SOLANA_ADRESS'\"}[1m]","legendFormat":"__auto","range":true,"refId":"A","queryType":"timeSeriesQuery","exemplar":false,"requestId":"97A","utcOffsetSec":0,"interval":"","datasourceId":1,"intervalMs":600000,"maxDataPoints":81}],"range":{"from":"now-2m","to":"now","raw":{"from":"now-2m","to":"now"}},"from":"now-2m","to":"now"}' \
  --compressed | jq -r @json 2> /dev/null | jq -r '.results.A.frames[0].schema.fields[1].labels.host' | sed 's/ / /g' 2> /dev/null`


function Time_Now_1 () {

	TIME_NOW=`echo -e "${SEE_SHEDULE_VAR}" | sed -n -e 1p`
	
	#echo -ne '\n'
	echo -e "${GREEN}"
	echo -e "Time now: ${TIME_NOW:-''}${SERVER_TIME_ZONE:-''}${NOCOLOR}" | awk 'length > 30'
}

function Epoch_Progress_2 () {

	END_OF_EPOCH=`echo -e "${SEE_SHEDULE_VAR}" | tail -n1 | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | sed 's/End: /End of epoch:/g' | tr -s ' '`
	
	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "Epoch Progress ${CLUSTER_NAME}${NOCOLOR}"

	echo "$EPOCH_INFO" | grep 'Epoch: '
	echo "$EPOCH_INFO" | grep 'Epoch Completed Percent'
	echo "$EPOCH_INFO" | grep 'Epoch Completed Time'
	echo -e "${NOCOLOR}$END_OF_EPOCH ${NOCOLOR}"
}

function This_Node_3 () {

	SOLANA_VALIDATORS=`solana ${SOLANA_CLUSTER} validators`

	THIS_SOLANA_VALIDATOR_INFO=`solana ${SOLANA_CLUSTER} validator-info get | awk '$0 ~ sadddddr {do_print=1} do_print==1 {print} NF==0 {do_print=0}' sadddddr=$THIS_SOLANA_ADRESS`
	#THIS_SOLANA_VALIDATOR_INFO_JS=`solana -ut validator-info get --output json-compact | jq --arg ID $(solana address) '.[] | select(.identityPubkey==$ID)'`
	
	NODE_NAME=`echo -e "${THIS_SOLANA_VALIDATOR_INFO}" | grep 'Name: ' | sed 's/Name//g' | tr -s ' '`
	#NODE_NAME=`echo -e "${THIS_SOLANA_VALIDATOR_INFO_JS}" | jq -r '.info.name'`
	
	SOLANA_VERSION=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.version'`
	#SOLANA_VERSION=`solana ${SOLANA_CLUSTER} validators --output json-compact | jq --arg ID ${THIS_SOLANA_ADRESS} '.validators[] | select(.identityPubkey==$ID) | .version' | sed 's/\"//g'`
	
	MAJOR_CLUSTER_VERSION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k6 -nr | sed 1q | awk '{print $1}'`
	MAJOR_CLUSTER_VERSION_PERCENT=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k6 -nr | sed 1q | awk '{print $6}'`
	
	MAJOR_CLUSTER_VERSION_BY_POPULATION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k3 -nr | sed 1q | awk '{print $1}'`
	MAJOR_CLUSTER_VERSION_POPULATION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k3 -nr | sed 1q | awk '{print $3}'`
	
	NODE_COMMISSION=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.commission'`
	
	NODE_WITHDRAW_AUTHORITY=`solana ${SOLANA_CLUSTER} vote-account ${YOUR_VOTE_ACCOUNT} | grep 'Withdraw' | awk '{print $NF}'`

	IDACC_BALANCE=`solana ${SOLANA_CLUSTER} balance ${THIS_SOLANA_ADRESS} | sed 's/ SOL//g' `
	VOTEACC_BALANCE=`solana ${SOLANA_CLUSTER} balance ${YOUR_VOTE_ACCOUNT}`
	WITHDR_BALANCE=`solana ${SOLANA_CLUSTER} balance ${NODE_WITHDRAW_AUTHORITY}`

	IS_DELINKED=`echo -e "${SOLANA_VALIDATORS}" | grep ⚠️ | if (grep ${THIS_SOLANA_ADRESS} -c)>0; then echo -e "WARNING: ${RED}THIS NODE IS DELINKED\n\rconsider to check catchup, network connection and/or messages from your datacenter${NOCOLOR}"; else >/dev/null; fi`
	
	CONCENTRATION=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.data_center_stake_percent' | awk '{printf("%.2f\n",$1)}'`
	
	MAX_CONCENTRATION=`
		if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
			echo "10.00"
		else
			echo "25.00"
		fi`
	DC_COLOR=`
		if (( $(bc<<<"scale=2;${CONCENTRATION} < ${MAX_CONCENTRATION}") )); then
		  echo "${GREEN}"
		else
		  echo "${YELLOW}"
		fi`
	
	CURRENT_DC=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.epoch_data_center.asn'`'-'`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.epoch_data_center.location'`' | '`echo "${DC_COLOR}${CONCENTRATION}"`'%'`echo "${NOCOLOR}"`' concentration'
	
	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "This Node${NODE_NAME} ${NOCOLOR}"

	echo -e "${IS_DELINKED}" | awk 'length > 5'

	#echo -e "Identity: ${THIS_SOLANA_ADRESS}"

	if (( $(bc<<<"scale=0;${IDACC_BALANCE:-0} >= 1.8") )); then
		echo -e "Identity:   ${THIS_SOLANA_ADRESS} / ${GREEN}${IDACC_BALANCE:-0} SOL${NOCOLOR}"
	else
		echo -e "Identity:   ${THIS_SOLANA_ADRESS} / ${RED}${IDACC_BALANCE:-0} SOL${NOCOLOR}"
	fi

	echo -e "VoteKey:    ${YOUR_VOTE_ACCOUNT} / ${VOTEACC_BALANCE}"
	#echo -e "VoteKey Balance: ${VOTEACC_BALANCE}"
	echo -e "Withdrawer: ${NODE_WITHDRAW_AUTHORITY} / ${WITHDR_BALANCE}"
	#echo -e "Withrawer Balance: ${WITHDR_BALANCE}"
	
	if (( $(bc<<<"scale=0;${NODE_COMMISSION:-100} <= 10.0") )); then
		echo -e "Node commission: " | tr -d '\r\n' && echo -e "${GREEN}${NODE_COMMISSION}%${NOCOLOR}"
	else
		if [[ "${CLUSTER_NAME}" != "(Mainnet)" ]]; then
			echo -e "Node commission: " | tr -d '\r\n' && echo -e "${GREEN}${NODE_COMMISSION}%${NOCOLOR}"
		else
			echo -e "Node commission: " | tr -d '\r\n' && echo -e "${RED}${NODE_COMMISSION}%${NOCOLOR}"
		fi
	fi
	
	if [[ "${SOLANA_VERSION}" == "${MAJOR_CLUSTER_VERSION_BY_POPULATION}" ]]; then
		echo -e "Solana version: " | tr -d '\r\n' && echo -e "${GREEN}${SOLANA_VERSION}${NOCOLOR} (Majority: ${MAJOR_CLUSTER_VERSION_PERCENT} stake on ${MAJOR_CLUSTER_VERSION} / ${MAJOR_CLUSTER_VERSION_POPULATION} nodes on ${MAJOR_CLUSTER_VERSION_BY_POPULATION}${NOCOLOR})"
	else
		echo -e "Solana version: " | tr -d '\r\n' && echo -e "${RED}${SOLANA_VERSION}${NOCOLOR} | Recheck discord for right version (Majority: ${MAJOR_CLUSTER_VERSION_PERCENT} stake on ${MAJOR_CLUSTER_VERSION} / ${MAJOR_CLUSTER_VERSION_POPULATION} nodes on ${MAJOR_CLUSTER_VERSION_BY_POPULATION})"
	fi
	
	echo -e "Datacenter: ${CURRENT_DC}"
}

function Node_Stake_4 () {

	if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		SOLANA_CLUSTER_local=' -um ' #' --url https://mainnet.rpcpool.com/ '
	elif [[ "${CLUSTER_NAME}" == "(TESTNET)" ]]; then
		SOLANA_CLUSTER_local=' -ut '
	else
		SOLANA_CLUSTER_local=' -ul '
	fi

	SOLANA_STAKES_THIS_NODE=`solana ${SOLANA_CLUSTER_local} stakes ${YOUR_VOTE_ACCOUNT}`

	TOTAL_ACTIVE_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | awk '{n += $1}; END{print n}' | bc`
	TOTAL_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | grep '' -c`

	ACTIVATING_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep 'Activating Stake: ' | sed 's/Activating Stake: //g' | sed 's/ SOL//g' | awk '{n += $1}; END{print n}' | bc`
	ACTIVATING_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep 'Activating Stake: ' | sed 's/Activating Stake: //g' | sed 's/ SOL//g' | grep '' -c`
	
	DEACTIVATING_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B1 -i 'deactivates' | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | awk '{n += $1}; END{print n}' | bc`
	DEACTIVATING_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B1 -i 'deactivates' | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | grep '' -c`

	NO_MOVING_STAKE=`echo "${TOTAL_ACTIVE_STAKE:-0} ${DEACTIVATING_STAKE:-0}" | awk '{print $1 - $2}' | bc`

	TOTAL_ACTIVE_STAKE_COUNT=`echo "${TOTAL_STAKE_COUNT:-0} ${ACTIVATING_STAKE_COUNT:-0}" | awk '{print $1 - $2}'`

	BOT_ACTIVE_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "mvines|mpa4abUk" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | awk '{n += $1}; END{print n}' | bc`
	BOT_ACTIVE_STAKE_CLR=`echo -e "${BOT_ACTIVE_STAKE:-0}" | awk '{if(NR=0) print 0; else print'} | awk '{ if ($1 >= 0.9) print gr$1" SOL"nc; else print rd$1" SOL"nc; fi }' gr=$GREEN rd=$RED nc=$NOCOLOR`
	BOT_ACTIVE_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "mvines|mpa4abUk" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | grep '' -c`
	
	if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		MINIMUM_SECRET_STAKE=`echo "0.5" | bc`
	else
		MINIMUM_SECRET_STAKE=0
	fi
	SECRET_ACTIVE_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "EhYXq3ANp5nAerUpbSgd7VK2RRcxK1zNuSQ755G5Mtxx" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | sed 's/ //g' | awk '{n += $1}; END{print n}' | bc`
	SECRET_ACTIVE_STAKE_CLR=`echo -e "${SECRET_ACTIVE_STAKE:-0}" | awk '{if(NR=0) print 0; else print'} | awk '{ if (($1 > 0)) print gr$1" SOL"nc; else print rd$1" SOL"nc; fi }' gr=$GREEN rd=$RED nc=$NOCOLOR`
	SECRET_ACTIVE_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "EhYXq3ANp5nAerUpbSgd7VK2RRcxK1zNuSQ755G5Mtxx" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | grep '' -c`
	SECRET_ACTIVE_TEXT=`echo -e "| Secret Fund(${SECRET_ACTIVE_STAKE_COUNT:-0}) ${SECRET_ACTIVE_STAKE_CLR} "`
	if [[ "${MINIMUM_SECRET_STAKE:-0}" == "0" ]]; then
		SECRET_ACTIVE_TEXT=""
	fi
	
	POOL_ACTIVE_TEXT="| "
	POOL_ACTIVE_STAKE_SUM=0
	POOL_ACTIVE_STAKE_COUNT_SUM=0
	STAKE_POOLS_NAMES=(MARINADE SOCEAN JPOOL EVERSOL BLAZESTAKE LIDO DAOPOOL)
	STAKE_POOLS_WTHDR=("9eG63CdHjsfhHmobHgLtESGC8GabbmRcaSpHAZrtmhco" "AzZRvyyMHBm8EHEksWxq4ozFL7JxLMydCDMGhqM6BVck" "HbJTxftxnXgpePCshA8FubsRj9MW4kfPscfuUfn44fnt" "C4NeuptywfXuyWB9A7H7g5jHVDE8L6Nj2hS53tA71KPn" "6WecYymEARvjG5ZyqkrVQ6YkhPfujNzWpSPwNKXHCbV2" "W1ZQRwUfSkDKy2oefRBUWph82Vr2zg9txWMA8RQazN5" "BbyX1GwUNsfbcoWwnkZDo8sqGmwNDzs2765RpjyQ1pQb")
	for i in ${!STAKE_POOLS_WTHDR[@]}; do
	  	POOL_ACTIVE_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "${STAKE_POOLS_WTHDR[$i]}" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | sed 's/ //g' | awk '{n += $1}; END{print n}' | bc`
		POOL_ACTIVE_STAKE_CLR=`echo -e "${POOL_ACTIVE_STAKE:-0}" | awk '{ if (($1 > 0)) print gr$1" SOL"nc; else print rd$1" SOL"nc; fi }' gr=$GREEN rd=$RED nc=$NOCOLOR`
		POOL_ACTIVE_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 -E "${STAKE_POOLS_WTHDR[$i]}" | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | grep '' -c`
		POOL_ACTIVE_TEXT_ADD=`echo -e "| ${STAKE_POOLS_NAMES[$i]}(${POOL_ACTIVE_STAKE_COUNT:-0}) ${POOL_ACTIVE_STAKE_CLR} "`
		if [[ "${POOL_ACTIVE_STAKE:-0}" == "0" ]]; then
			POOL_ACTIVE_TEXT_ADD=""
		fi
		POOL_ACTIVE_TEXT=`echo -e "${POOL_ACTIVE_TEXT:-}${POOL_ACTIVE_TEXT_ADD:-}| "`
		POOL_ACTIVE_STAKE_SUM=`echo -e "${POOL_ACTIVE_STAKE_SUM:-0}  ${POOL_ACTIVE_STAKE:-0}" | awk '{print $1 + $2}'`
		POOL_ACTIVE_STAKE_COUNT_SUM=`echo -e "${POOL_ACTIVE_STAKE_COUNT_SUM:-0}  ${POOL_ACTIVE_STAKE_COUNT:-0}" | awk '{print $1 + $2}'`
	done
	
	if [[ `echo -e "$POOL_ACTIVE_TEXT" | sed 's/ //g' | sed 's/|//g' ` == "" ]]; then
		POOL_ACTIVE_TEXT=""
	fi
	
	POOL_ACTIVE_TEXT=`echo -e ${POOL_ACTIVE_TEXT} | sed 's/| |/|/g'`

	SELF_ACTIVE_STAKE=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 'Withdraw Authority: '${NODE_WITHDRAW_AUTHORITY} | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | bc | awk '{n += $1}; END{print n}'`
	if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		MINIMUM_SELF_STAKE=100
	else
		MINIMUM_SELF_STAKE=0
	fi
	
	SELF_ACTIVE_STAKE_CLR=`echo -e "${SELF_ACTIVE_STAKE:-0}" | awk '{if(NR=0) print 0; else print'} | awk '{ if (($1 >= $MINIMUM_SELF_STAKE)) print gr$1" SOL"nc; else print rd$1" SOL"nc; fi }' gr=$GREEN rd=$RED nc=$NOCOLOR`
	SELF_ACTIVE_STAKE_COUNT=`echo -e "${SOLANA_STAKES_THIS_NODE}" | grep -B7 'Withdraw Authority: '${NODE_WITHDRAW_AUTHORITY} | grep 'Active Stake' | sed 's/Active Stake: //g' | sed 's/ SOL//g' | bc | grep '' -c`

	OTHER_ACTIVE_STAKE=`echo "${TOTAL_ACTIVE_STAKE:-0} ${BOT_ACTIVE_STAKE:-0} ${SECRET_ACTIVE_STAKE:-0} ${POOL_ACTIVE_STAKE_SUM:-0} ${SELF_ACTIVE_STAKE:-0}" | awk '{print $1 - $2 - $3 - $4 - $5}' | bc`
	OTHER_ACTIVE_STAKE_COUNT=`echo "${TOTAL_ACTIVE_STAKE_COUNT:-0} ${BOT_ACTIVE_STAKE_COUNT:-0} ${SECRET_ACTIVE_STAKE_COUNT:-0} ${POOL_ACTIVE_STAKE_COUNT_SUM:-0} ${SELF_ACTIVE_STAKE_COUNT:-0}" | awk '{print $1 - $2 - $3 - $4 - $5}'`
	
	
	CURRENT_STAKE_ACTION=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state_action'`
#| tr '-' '\n     | '
	#echo -ne '\n'
	
	echo -e "${CYAN}"
	echo -e "Current Stake ${NOCOLOR}"
	
	echo -e "${LIGHTPURPLE}Last Bot Stake Action:${NOCOLOR} In epoch ${LAST_EPOCH} ${CURRENT_STAKE_ACTION}${NOCOLOR}"
	
	echo -e "Stake Total: Active(${TOTAL_ACTIVE_STAKE_COUNT:-0}) ${TOTAL_ACTIVE_STAKE:-0} SOL | From Bot(${BOT_ACTIVE_STAKE_COUNT:-0}) ${BOT_ACTIVE_STAKE_CLR} ${SECRET_ACTIVE_TEXT:-}${POOL_ACTIVE_TEXT:-}| Self-Stake(${SELF_ACTIVE_STAKE_COUNT:-0}) ${SELF_ACTIVE_STAKE_CLR} | Other(${OTHER_ACTIVE_STAKE_COUNT:-0}) ${OTHER_ACTIVE_STAKE} SOL" | sed 's/|\( *|\)*/|/g'
	echo -e "Stake Moving: no-moving ${NO_MOVING_STAKE:-0} SOL | activating  ${ACTIVATING_STAKE:-0} SOL | deactivating ${DEACTIVATING_STAKE:-0} SOL"
	
}

function SFDP_5 () {

	KYC_API_VERCEL=`curl -s 'https://kyc-api.vercel.app/api/validators/list?offset=0&limit=15&order_by=name&order=asc&search_term='${THIS_SOLANA_ADRESS}`
	
	SFDP_FULL_STATUS=$(solana-foundation-delegation-program status ${THIS_SOLANA_ADRESS}  > /dev/null 2>&1)
	SFDP_STATUS=`echo -e "${SFDP_FULL_STATUS}" | grep 'State: ' | sed 's/State: //g'`
	
	if [[ SFDP_STATUS="" ]]; then
		SFDP_STATUS=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].state'`
	fi
	
	if [[ SFDP_FULL_STATUS="" ]]; then
		SFDP_FULL_STATUS=`echo "Testnet Key:" $(echo "${KYC_API_VERCEL}" | jq -r '.data[0].testnet_pk')
		echo "Mainnet Key:" $(echo "${KYC_API_VERCEL}" | jq -r '.data[0].mainnet_beta_pk')`
	fi
	
	TDS_GROUP=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].tds_onboarding_group'`
	
	ONBOARDING_NUMBER=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].onboarding_number'`
	ONBOARDING_WEEK=`echo -e "$ONBOARDING_NUMBER" | awk '{print ($1/25.00)}' | awk '{printf("%.1f\n",$1)}'`
	
	CURRENT_STAKE_STATE=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state'`
	CURRENT_STAKE_REASON=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state_reason'`
	
	METRICS_LAST_EPOCH_TRUE_FALSE=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics.pass'`
	METRICS_LAST_EPOCH=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics.reason'`
	
	METRICS_SUMMARY_TRUE_FALSE=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics_summary.pass'`
	METRICS_SUMMARY_RAW=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics_summary.reason'`
	COLOR_METRICS=`if [[ "${METRICS_SUMMARY_TRUE_FALSE}" == "true" ]];
			then
				if [[ $METRICS_SUMMARY_RAW == *"10/10"* ]];
				then
					echo "${GREEN}"
				else
					echo "${YELLOW}"
				fi
			else
			  echo "${RED}"
			fi`

	METRICS_SUMMARY=`echo "${COLOR_METRICS}"``echo "${METRICS_SUMMARY_RAW}"``echo "${NOCOLOR}"`
	
	TESTNET_PERFORMANCE=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].tn_calculated_stats.num_bonus_last_10'`
	
	COLOR_TESTNET_PERFORMANCE=`
		if (( $(bc<<<"scale=0;${TESTNET_PERFORMANCE} >= 8") )); then
		  echo "${GREEN}"
		elif (( $(bc<<<"scale=0;${TESTNET_PERFORMANCE} >= 5") )); then
		  echo "${YELLOW}"
		else
		  echo "${RED}"
		fi`
		
	COLOR_STAKE_STATE=`
		if [[ "${CURRENT_STAKE_STATE}" == "Bonus" ]];
		then
		  echo "${GREEN}"
		elif [[ "${CURRENT_STAKE_STATE}" == "Baseline" ]];
		then
		  echo "${YELLOW}"
		else
		  echo "${RED}"
		fi`
	
	COLOR_SFDP_STATUS=`
		if [[ "${SFDP_STATUS}" == "Rejected" ]];
		then
		  echo "${RED}"
		else
			if [[ "${SFDP_STATUS}" == "Approved" ]];
			then
			  echo "${GREEN}"
			else
			  echo "${LIGHTPURPLE}"
			fi
		fi`
	SFDP_STATUS_STRING=`echo -e "State: ${COLOR_SFDP_STATUS}${SFDP_STATUS}${NOCOLOR}"`
	SFDP=`echo -e "${SFDP_FULL_STATUS}" | grep -v "State: "`
	
	

	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "Foundation Delegation Program ${NOCOLOR}"
	echo -e "${SFDP_STATUS_STRING}"
	if [[ "${TDS_GROUP}" != "null" ]] ; then
		echo -e "TDS Group: ${TDS_GROUP}"
	fi
	if [[ "${ONBOARDING_NUMBER}" != "null" ]] ; then
		echo -e "Current Onboarding Queue Number: ${LIGHTPURPLE}${ONBOARDING_NUMBER}${NOCOLOR} | ~${ONBOARDING_WEEK} weeks"
	fi
	echo -e "${SFDP}"

	if [[ "${TESTNET_PERFORMANCE}" != "" ]] ; then
		echo -e "Current Testnet Performance: ${COLOR_TESTNET_PERFORMANCE}${TESTNET_PERFORMANCE}/10 ${NOCOLOR}"
	fi
	echo -e "Last Epoch State: ${COLOR_STAKE_STATE}${CURRENT_STAKE_STATE}: ${CURRENT_STAKE_REASON}${NOCOLOR}"
	#echo -e "Metrics-Last-Epoch-${LAST_EPOCH}: ${METRICS_LAST_EPOCH}"
	echo -e "Metrics: ${METRICS_SUMMARY}"
}

function Vote_Credits_6 () {
	
	YOUR_CREDITS=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.epochCredits'`
	#YOUR_CREDITS=`solana ${SOLANA_CLUSTER} vote-account ${YOUR_VOTE_ACCOUNT} | grep -A 4 History | grep -A 2 epoch | grep credits/slots | cut -d ' ' -f 4 | cut -d '/' -f 1 | bc`
	YOUR_CREDITS_PLACE=`solana validators ${SOLANA_CLUSTER} --sort=credits -r -n | grep ${THIS_SOLANA_ADRESS} | sed 's/⚠️/ /g' | awk '{print ($1)}' | sed 's/[[:blank:]]*$//'`
	ALL_CREDITS_PLACES=`solana validators ${SOLANA_CLUSTER} --sort=credits -r -n | grep -A 999999999 Skip | grep -B 999999999 Skip | grep -v Skip | sed 's/[()⚠️]/ /g' | tr -s ' ' | tac | egrep -m 1 . | awk {'print $1'}`
	#ALL_CLUSTER_CREDITS_LIST=`solana ${SOLANA_CLUSTER} validators | grep -A 999999999 Skip | grep -B 999999999 Skip | grep -v Skip | sed 's/(/ /g'| sed 's/)/ /g' | tr -s ' ' | sed 's/ /\n\r/g' | grep -v % | grep -i -v [a-z⚠️-] | egrep '^.{2,7}$' | grep -v -E '\.+[[:digit:]]\.+[[:digit:]]+$' | grep -v -E '^.{2,3}$'`
	#SUM_CLUSTER_CREDITS=`echo -e "${ALL_CLUSTER_CREDITS_LIST}" | awk '{n += $1}; END{print n}'`
	#COUNT_CLUSTER_VALIDATORS=`echo -e "${ALL_CLUSTER_CREDITS_LIST}" | wc -l | bc`
	#CLUSTER_CREDITS=`echo -e "$SUM_CLUSTER_CREDITS" "$COUNT_CLUSTER_VALIDATORS" | awk '{print ($1/$2)}' `
	CLUSTER_CREDITS=`solana ${SOLANA_CLUSTER} validators --output json-compact | jq --arg ID ${THIS_SOLANA_ADRESS} '.validators[]' | jq -r .epochCredits | awk '{n += $1; y += 1}; END{print n/y}'`
	
	PERCENT_CREDITS=`echo "${YOUR_CREDITS:-0} ${CLUSTER_CREDITS:-0} ${CLUSTER_CREDITS:-1}" | awk '{print 100 * ($1 - $2) / $3}' | awk '{printf("%.2f\n",$1)}'`
	
	PERCENT_SIGN=`
		if (( $(bc<<<"scale=2;${PERCENT_CREDITS} >= 0.0") ));
		then
		  echo "+"
		else
		  echo ""
		fi`
	
	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "Vote-Credits ${NOCOLOR}"

	echo -e "Average cluster credits: ${CLUSTER_CREDITS:-0} (minus grace 35%: $(bc<<<"scale=2;${CLUSTER_CREDITS:-0}*0.65"))"

	if (( $(bc<<<"scale=2;${YOUR_CREDITS:-0} >= ${CLUSTER_CREDITS:-0}*0.65"))); then
	  echo -e "${GREEN}Your credits: ${YOUR_CREDITS} (Good) | ${PERCENT_SIGN}${PERCENT_CREDITS}% from average${NOCOLOR}"
	else
	  echo -e "${RED}Your credits: ${YOUR_CREDITS} (Bad) | ${PERCENT_SIGN}${PERCENT_CREDITS}% from average${NOCOLOR}"
	fi
	echo -e "Your epoch credit rating: # ${YOUR_CREDITS_PLACE} / ${ALL_CREDITS_PLACES} "
	#("${COUNT_CLUSTER_VALIDATORS} with non-zero credits)"
	
	echo -e "Max-Possible Cluster Credits are 432000 (minus grace 35%: $(bc<<<"scale=2;432000*0.65"))"
	
	if (( $(bc<<<"scale=2;${YOUR_CREDITS:-0} >= 432000*0.65") )); then
	  echo -e "${GREEN}Your Node fulfilled the maximum plan!${NOCOLOR}"
	else
	  echo -e "Your Node not yet fulfilled the maximum plan: $(bc<<<"scale=2;432000*0.65-${YOUR_CREDITS:-0}") | ${YELLOW}$(bc<<<"scale=2;100-100*${YOUR_CREDITS:-0}/(432000*0.65)")% remains${NOCOLOR}"
	fi
	
}

function Skiprate_7 () {
	


	CLUSTER_SKIP=`echo -e "$(solana validators ${SOLANA_CLUSTER} --output json-compact | jq .averageStakeWeightedSkipRate)" | awk '{printf("%.2f\n",$1)}'`
	
	CLUSTER_SKIP_AVERAGE=`echo -e "$(solana validators ${SOLANA_CLUSTER} --output json-compact | jq .averageSkipRate)" | awk '{printf("%.2f\n",$1)}'`
	
	
	THIS_BLOCK_PRODUCTION=`solana ${SOLANA_CLUSTER} -v block-production | grep ${THIS_SOLANA_ADRESS}`

	ALL_SLOTS=`solana ${SOLANA_CLUSTER} leader-schedule | grep ${THIS_SOLANA_ADRESS} -c | awk '{if ($1==0) print 1; else print $1;}'`
	SKIPPED_COUNT=`echo -e "${THIS_BLOCK_PRODUCTION}" | grep SKIPPED -c`
	NON_SKIPPED_COUNT=`echo -e "${THIS_BLOCK_PRODUCTION}" | grep SKIPPED -v -c | awk '{ if ($1 > 0) print $1-1; else print 0; fi}'`

	SCHEDULE1=`solana ${SOLANA_CLUSTER} leader-schedule | grep ${THIS_SOLANA_ADRESS} | tr -s ' ' | cut -d' ' -f2`
	CURRENT_SLOT1=`echo -e "$EPOCH_INFO" | grep "Slot: " | cut -d ':' -f 2 | cut -d ' ' -f 2`
	COMPLETED_SLOTS1=`echo -e "${SCHEDULE1}" | awk -v cs1="${CURRENT_SLOT1:-0}" '{ if ( ! -z "$1" ) if ($1 <= cs1) { print }}' | wc -l`
	REMAINING_SLOTS1=`echo -e "${SCHEDULE1}" | awk -v cs1="${CURRENT_SLOT1:-0}" '{ if ( ! -z "$1" ) if ($1 > cs1) { print }}' | wc -l`

	YOUR_SKIPRATE=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.skipRate' | awk '{printf("%.2f\n",$1)}'`
	#YOUR_SKIPRATE=`echo -e "${THIS_BLOCK_PRODUCTION}" | sed -n -e 1p | sed 's/  */ /g' | sed '/^#\|^$\| *#/d' | cut -d ' ' -f 6 | cut -d '%' -f 1 | awk '{print $1}'`

	NEAREST_SLOTS=`echo -e "${SEE_SHEDULE_VAR}" | grep -m1 -A11 "new>" | sed -n -e 1p -e 5p -e 9p | sed 's/End: /End of epoch:/g' | sed 's/new> //g' | tr -s ' ' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'`
	LAST_BLOCK=`echo -e "${SEE_SHEDULE_VAR}" | grep "old<" | tail -n1 | sed 's/old< //g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g'`
	LAST_BLOCK_STATUS=`echo -e "${THIS_BLOCK_PRODUCTION}" | tail -n2 | tr -s ' ' | sed 's/ /\n\r/g' | sed '/^$/d' | grep -i 'skipped' -c | awk {'if ($1==0) print "DONE"; else print "SKIPPED"'}`
	COLOR_LAST_BLOCK=`
		if [[ "${LAST_BLOCK_STATUS}" == "SKIPPED" ]];
		then
		  echo "${RED}"
		else
		  echo "${GREEN}"
		fi`
		
	
	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "Skip Rate ${NOCOLOR}"

	echo -e "Average cluster skiprate: ${CLUSTER_SKIP}% (plus grace 30%: $(bc<<<"scale=2;${CLUSTER_SKIP:-0}+30")%) | AVG ${CLUSTER_SKIP_AVERAGE}%"

	if (( $(bc<<<"scale=2;${YOUR_SKIPRATE:-0} > ${CLUSTER_SKIP:-0}+30"))); then
	  echo -e "${RED}Your skiprate: ${YOUR_SKIPRATE:-0}% (Bad) - Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR}"
	elif (( $(bc<<<"scale=2;${YOUR_SKIPRATE:-0} >= ${CLUSTER_SKIP:-0}+20"))); then
	  echo -e "${YELLOW}Your skiprate: ${YOUR_SKIPRATE:-0}% (Good) - Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR}"
	else
	  echo -e "${GREEN}Your skiprate: ${YOUR_SKIPRATE:-0}% (Good) - Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR}"
	fi

	if (("${COMPLETED_SLOTS1:-0}" != '1' && "${ALL_SLOTS:-0}" != '1')); then

		echo "Your Slots ${COMPLETED_SLOTS1:-0}/${ALL_SLOTS:-0} (${REMAINING_SLOTS1:-0} remaining)"


		#min-skip
		if (( $(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1} <= ${CLUSTER_SKIP:-0}+30") )); then
			echo -e "Your Min-Possible Skiprate is ${GREEN}$(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1}")%${NOCOLOR} (if all remaining slots will be done)"
		else
			echo -e "Your Min-Possible Skiprate is ${RED}$(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1}")%${NOCOLOR} (if all remaining slots will be done)"
		fi

		#max-skip
		if (( $(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1} <= ${CLUSTER_SKIP:-0}+30") )); then
			echo -e "Your Max-Possible Skiprate is ${GREEN}$(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1}")%${NOCOLOR} (if all remaining slots will be skipped)"
		else
			echo -e "Your Max-Possible Skiprate is ${RED}$(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1}")%${NOCOLOR} (if all remaining slots will be skipped)"
		fi
		
		echo -e "${CYAN}"
		echo -e "Block Production ${NOCOLOR}"

		if (( $(bc<<<"scale=2;${COMPLETED_SLOTS1:-0} > 0"))); then
			echo -e "Last Block: ${COLOR_LAST_BLOCK}${LAST_BLOCK} ${LAST_BLOCK_STATUS}${NOCOLOR}"
		else
			echo -e "This node did not produce any blocks yet"
		fi

		if (( $(bc<<<"scale=2;${REMAINING_SLOTS1:-0} > 0"))); then
			echo -e "Nearest Slots (4 blocks each):"
			echo -e "${GREEN}${NEAREST_SLOTS}${NOCOLOR}"
		else
			echo -e "This node will not have new blocks in this epoch"
		fi
		
	else
		echo -e "${LIGHTPURPLE}This node don't have blocks in this epoch${NOCOLOR}"
	fi
}

function Last_Rewards_8 () {

	LAST_REWARDS_RAW=$(solana -um vote-account --with-rewards --num-rewards-epochs 5 ${YOUR_VOTE_ACCOUNT} 2>&1)
	
	LAST_REWARDS=`echo -e "${LAST_REWARDS_RAW}" | grep -A10 'Reward Slot' | sed 's/Reward Slot/Reward_Slot/g' | awk '{print $1"\t"$2"\t"$3}'`

	#echo -ne '\n'
	echo -e "${CYAN}"
	echo -e "Last Rewards ${NOCOLOR}"
	echo -e "${LAST_REWARDS:-${LIGHTPURPLE}No rewards yet ${NOCOLOR}}"
	
	#_work_done=1
}


function Only_Important ()
{
	OPTIMISTIC_ARR[1]=`Optimistic_Slot_Now`
	
	EPOCH_NUMBER=`echo "$EPOCH_INFO" | grep 'Epoch: '`
	END_OF_EPOCH=`echo -e "${SEE_SHEDULE_VAR}" | tail -n1 | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | sed 's/End: /End of epoch:/g' | tr -s ' '`
	EPOCH_REMAINS=`echo "$EPOCH_INFO" | grep 'Epoch Completed Time' | sed -n '/.*(/s///p' | sed 's/)//g' 2> /dev/null`
	
	echo -e ""
	echo -e "Solana Price: "`solana_price`
	
	echo -e "${CYAN}$EPOCH_NUMBER | $END_OF_EPOCH$SERVER_TIME_ZONE| $EPOCH_REMAINS ${NOCOLOR}"

	KYC_API_VERCEL=`curl -s 'https://kyc-api.vercel.app/api/validators/list?offset=0&limit=15&order_by=name&order=asc&search_term='${THIS_SOLANA_ADRESS}`
	SFDP_STATUS=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].state'`
	COLOR_SFDP_STATUS=`
		if [[ "${SFDP_STATUS}" == "Rejected" ]];
		then
		  echo "${RED}"
		else
			if [[ "${SFDP_STATUS}" == "Approved" ]];
			then
			  echo "${GREEN}"
			else
			  echo "${LIGHTPURPLE}"
			fi
		fi`
	SFDP_STATUS_STRING=`echo -e " : ${COLOR_SFDP_STATUS}${SFDP_STATUS}${NOCOLOR}"`
	
	THIS_SOLANA_VALIDATOR_INFO=`solana ${SOLANA_CLUSTER} validator-info get | awk '$0 ~ sadddddr {do_print=1} do_print==1 {print} NF==0 {do_print=0}' sadddddr=$THIS_SOLANA_ADRESS`
	
	SOLANA_VALIDATORS=`solana ${SOLANA_CLUSTER} validators`
	
	NODE_NAME=`echo -e "${THIS_SOLANA_VALIDATOR_INFO}" | grep 'Name: ' | sed 's/Name//g' | tr -s ' '`
	
	echo -e "${BLUE}This Node${NODE_NAME} ${CLUSTER_NAME} ${NOCOLOR}${SFDP_STATUS_STRING}"
	
	IS_DELINKED=`echo -e "${SOLANA_VALIDATORS}" | grep ⚠️ | if (grep ${THIS_SOLANA_ADRESS} -c)>0; then echo -e "WARNING: ${RED}THIS NODE IS DELINKED\n\rconsider to check catchup, network connection and/or messages from your datacenter${NOCOLOR}"; else >/dev/null; fi`
	
	echo -e "${IS_DELINKED}" | awk 'length > 5'

	NODE_WITHDRAW_AUTHORITY=`solana ${SOLANA_CLUSTER} vote-account ${YOUR_VOTE_ACCOUNT} | grep 'Withdraw' | awk '{print $NF}'`
	IDACC_BALANCE=`solana ${SOLANA_CLUSTER} balance ${THIS_SOLANA_ADRESS} | sed 's/ SOL//g' `
	VOTEACC_BALANCE=`solana ${SOLANA_CLUSTER} balance ${YOUR_VOTE_ACCOUNT}`
	WITHDR_BALANCE=`solana ${SOLANA_CLUSTER} balance ${NODE_WITHDRAW_AUTHORITY}`
	
	if (( $(bc<<<"scale=0;${IDACC_BALANCE:-0} >= 1.8") )); then
		echo -e "Identity:   ${THIS_SOLANA_ADRESS} | ${GREEN}${IDACC_BALANCE:-0} SOL${NOCOLOR}"
	else
		echo -e "Identity:   ${THIS_SOLANA_ADRESS} | ${RED}${IDACC_BALANCE:-0} SOL${NOCOLOR}"
	fi
	echo -e "VoteKey:    ${YOUR_VOTE_ACCOUNT} | ${VOTEACC_BALANCE}"
	echo -e "Withdrawer: ${NODE_WITHDRAW_AUTHORITY} | ${WITHDR_BALANCE}"
	
	
	SOLANA_VERSION=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.version'`
	
	MAJOR_CLUSTER_VERSION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k6 -nr | sed 1q | awk '{print $1}'`
	#MAJOR_CLUSTER_VERSION_PERCENT=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k6 -nr | sed 1q | awk '{print $6}'`
	
	MAJOR_CLUSTER_VERSION_BY_POPULATION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k3 -nr | sed 1q | awk '{print $1}'`
	#MAJOR_CLUSTER_VERSION_POPULATION=`echo -e "${SOLANA_VALIDATORS}" | grep -A99 "Stake By Version:" | sed 's/[()]/ /g' | tail -n +2 | sort -k3 -nr | sed 1q | awk '{print $3}'`
	
	if [[ "${SOLANA_VERSION}" == "${MAJOR_CLUSTER_VERSION_BY_POPULATION}" ]]; then
		echo -e "Solana version: " | tr -d '\r\n' && echo -e "${GREEN}${SOLANA_VERSION}${NOCOLOR} (Majority ${MAJOR_CLUSTER_VERSION_BY_POPULATION}${NOCOLOR})"
	else
		echo -e "Solana version: " | tr -d '\r\n' && echo -e "${RED}${SOLANA_VERSION}${NOCOLOR} (Majority ${MAJOR_CLUSTER_VERSION_BY_POPULATION}${NOCOLOR})"
	fi
	
OPTIMISTIC_ARR[3]=`Optimistic_Slot_Now 5`
	
	
	
	ONBOARDING_NUMBER=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].onboarding_number'`
	ONBOARDING_WEEK=`echo -e "$ONBOARDING_NUMBER" | awk '{print ($1/25.00)}' | awk '{printf("%.1f\n",$1)}'`
	
	if [[ "${ONBOARDING_NUMBER}" != "null" ]] ; then
		echo -e "Current Onboarding Queue Number: ${LIGHTPURPLE}${ONBOARDING_NUMBER}${NOCOLOR} | ~${ONBOARDING_WEEK} weeks"
	fi
	
	YOUR_CREDITS=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.epochCredits'`
	
	CLUSTER_CREDITS=`solana ${SOLANA_CLUSTER} validators --output json-compact | jq --arg ID ${THIS_SOLANA_ADRESS} '.validators[]' | jq -r .epochCredits | awk '{n += $1; y += 1}; END{print n/y}'`
	
	PERCENT_CREDITS=`echo "${YOUR_CREDITS:-0} ${CLUSTER_CREDITS:-0} ${CLUSTER_CREDITS:-1}" | awk '{print 100 * ($1 - $2) / $3}' | awk '{printf("%.2f\n",$1)}'`
	
	PERCENT_SIGN=`
		if (( $(bc<<<"scale=2;${PERCENT_CREDITS} >= 0.0") ));
		then
		  echo "+"
		else
		  echo ""
		fi`

	VOTE_PLAN=`
	if (( $(bc<<<"scale=2;${YOUR_CREDITS:-0} >= 432000*0.65") )); then
	  echo -e "${GREEN} | Maximum plan credits!${NOCOLOR}"
	else
	  echo -e "${YELLOW} | $(bc<<<"scale=2;100-100*${YOUR_CREDITS:-0}/(432000*0.65)")% remaining${NOCOLOR}"
	fi`
	
	if (( $(bc<<<"scale=2;${YOUR_CREDITS:-0} >= ${CLUSTER_CREDITS:-0}*0.65"))); then
	  echo -e "${GREEN}Your credits: ${YOUR_CREDITS} (Good) | ${PERCENT_SIGN}${PERCENT_CREDITS}% from average${NOCOLOR}${VOTE_PLAN}"
	else
	  echo -e "${RED}Your credits: ${YOUR_CREDITS} (Bad) | ${PERCENT_SIGN}${PERCENT_CREDITS}% from average${NOCOLOR}${VOTE_PLAN}"
	fi
	
OPTIMISTIC_ARR[4]=`Optimistic_Slot_Now`
	
	CLUSTER_SKIP=`echo -e "$(solana validators ${SOLANA_CLUSTER} --output json-compact | jq .averageStakeWeightedSkipRate)" | awk '{printf("%.2f\n",$1)}'`
	
	CLUSTER_SKIP_AVERAGE=`echo -e "$(solana validators ${SOLANA_CLUSTER} --output json-compact | jq .averageSkipRate)" | awk '{printf("%.2f\n",$1)}'`
	
	
	THIS_BLOCK_PRODUCTION=`solana ${SOLANA_CLUSTER} -v block-production | grep ${THIS_SOLANA_ADRESS}`

	ALL_SLOTS=`solana ${SOLANA_CLUSTER} leader-schedule | grep ${THIS_SOLANA_ADRESS} -c | awk '{if ($1==0) print 1; else print $1;}'`
	SKIPPED_COUNT=`echo -e "${THIS_BLOCK_PRODUCTION}" | grep SKIPPED -c`
	NON_SKIPPED_COUNT=`echo -e "${THIS_BLOCK_PRODUCTION}" | grep SKIPPED -v -c | awk '{ if ($1 > 0) print $1-1; else print 0; fi}'`
	
	SCHEDULE1=`solana ${SOLANA_CLUSTER} leader-schedule | grep ${THIS_SOLANA_ADRESS} | tr -s ' ' | cut -d' ' -f2`
	CURRENT_SLOT1=`echo -e "$EPOCH_INFO" | grep "Slot: " | cut -d ':' -f 2 | cut -d ' ' -f 2`
	COMPLETED_SLOTS1=`echo -e "${SCHEDULE1}" | awk -v cs1="${CURRENT_SLOT1:-0}" '{ if ( ! -z "$1" ) if ($1 <= cs1) { print }}' | wc -l`
	REMAINING_SLOTS1=`echo -e "${SCHEDULE1}" | awk -v cs1="${CURRENT_SLOT1:-0}" '{ if ( ! -z "$1" ) if ($1 > cs1) { print }}' | wc -l`

	YOUR_SKIPRATE=`echo -e "${THIS_VALIDATOR_JSON}" | jq -r '.skipRate' | awk '{printf("%.2f\n",$1)}'`
	
	if (("${COMPLETED_SLOTS1:-0}" != '1' && "${ALL_SLOTS:-0}" != '1')); then
		
		MIN_POS_SKIP=`if (( $(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1} <= ${CLUSTER_SKIP:-0}+30") )); then
			echo -e "${GREEN}min: $(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1}")%${NOCOLOR}"
		else
			echo -e "${RED}min: $(bc<<<"scale=2;${SKIPPED_COUNT:-0}*100/${ALL_SLOTS:-1}")%${NOCOLOR}"
		fi`
		
		MAX_POS_SKIP=`if (( $(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1} <= ${CLUSTER_SKIP:-0}+30") )); then
			echo -e "${GREEN}max: $(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1}")%${NOCOLOR}"
		else
			echo -e "${RED}max: $(bc<<<"scale=2;(${ALL_SLOTS:-0}-${NON_SKIPPED_COUNT:-0})*100/${ALL_SLOTS:-1}")%${NOCOLOR}"
		fi`
		
		COLOR_REMAINING_SLOTS=`if (( $(bc<<<"scale=0;${REMAINING_SLOTS1:-0} == 0") )); then
			echo -e "${GREEN}"
		else
			echo -e "${YELLOW}"
		fi`
		
		SHORT_SKIP_INFO=`echo "${MIN_POS_SKIP} | ${MAX_POS_SKIP} | cluster ${CLUSTER_SKIP}%->$(bc<<<"scale=2;${CLUSTER_SKIP:-0}+30")% grace | ${COLOR_REMAINING_SLOTS}${REMAINING_SLOTS1:-0} remaining${NOCOLOR}"`

	else
		SHORT_SKIP_INFO=`echo -e "${LIGHTPURPLE}This node don't have blocks in this epoch${NOCOLOR} | cluster ${CLUSTER_SKIP}%-> $(bc<<<"scale=2;${CLUSTER_SKIP:-0}+30")% grace"`
	fi
	
	
	if (( $(bc<<<"scale=2;${YOUR_SKIPRATE:-0} > ${CLUSTER_SKIP:-0}+30"))); then
	  echo -e "${RED}Your skiprate: ${YOUR_SKIPRATE:-0}% (Bad) | Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR} | ${SHORT_SKIP_INFO}"
	elif (( $(bc<<<"scale=2;${YOUR_SKIPRATE:-0} >= ${CLUSTER_SKIP:-0}+20"))); then
	  echo -e "${YELLOW}Your skiprate: ${YOUR_SKIPRATE:-0}% (Good) | Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR} | ${SHORT_SKIP_INFO}"
	else
	  echo -e "${GREEN}Your skiprate: ${YOUR_SKIPRATE:-0}% (Good) | Done: ${NON_SKIPPED_COUNT:-0}, Skipped: ${SKIPPED_COUNT:-0}${NOCOLOR} | ${SHORT_SKIP_INFO}"
	fi
	
	if (( $(bc<<<"scale=2;${COMPLETED_SLOTS1:-0} > 0"))); then
		LAST_BLOCK_TIME=`echo -e "${SEE_SHEDULE_VAR}" | grep "old<" | tail -n1 | sed 's/old< //g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | awk '{print $2" "$3}'`
		LAST_BLOCK_STATUS=`echo -e "${THIS_BLOCK_PRODUCTION}" | tail -n2 | tr -s ' ' | sed 's/ /\n\r/g' | sed '/^$/d' | grep -i 'skipped' -c | awk {'if ($1==0) print "DONE"; else print "SKIPPED"'}`
		COLOR_LAST_BLOCK=`
			if [[ "${LAST_BLOCK_STATUS}" == "SKIPPED" ]];
			then
			  echo "${RED}"
			else
			  echo "${GREEN}"
			fi`
		LAST_BLOCK_INFO="${COLOR_LAST_BLOCK}${LAST_BLOCK_TIME} ${LAST_BLOCK_STATUS}${NOCOLOR} |"
	else
		LAST_BLOCK_INFO=""
	fi

	if (( $(bc<<<"scale=2;${REMAINING_SLOTS1:-0} > 0"))); then
		
		NEXT_SLOT=`echo -e "${SEE_SHEDULE_VAR}" | grep -m1 -A11 "new>" | grep -v "End" | sed -n -e 1p | sed 's/new> //g' | tr -s ' ' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | awk '{print $2" "$3}'`
		NEXT_SLOT_2=`echo -e "${SEE_SHEDULE_VAR}" | grep -m1 -A11 "new>" | grep -v "End" | sed -n -e 5p | sed 's/new> //g' | tr -s ' ' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | awk '{print $2" "$3}'`
		NEXT_SLOT_3=`echo -e "${SEE_SHEDULE_VAR}" | grep -m1 -A11 "new>" | grep -v "End" | sed -n -e 9p | sed 's/new> //g' | tr -s ' ' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | awk '{print $2" "$3}'`
		
		NEXT_SLOT_INFO="${NOCOLOR}next  ${NEXT_SLOT}  ${NEXT_SLOT_2:-}  ${NEXT_SLOT_3:-}${NOCOLOR}"
	else
		NEXT_SLOT_INFO="${GREEN}This node will not have new blocks in this epoch${NOCOLOR}"
	fi
	
	
	echo -e "Block Production: ${LAST_BLOCK_INFO} ${NEXT_SLOT_INFO} ${NOCOLOR}"
	
	
	TESTNET_PERFORMANCE=`echo "${KYC_API_VERCEL}" | jq -r '.data[0].tn_calculated_stats.num_bonus_last_10'`
	COLOR_TESTNET_PERFORMANCE=`
		if (( $(bc<<<"scale=0;${TESTNET_PERFORMANCE:-0} >= 8") )); then
		  echo "${GREEN}"
		elif (( $(bc<<<"scale=0;${TESTNET_PERFORMANCE:-0} >= 5") )); then
		  echo "${YELLOW}"
		else
		  echo "${RED}"
		fi`
		
	if [[ "${TESTNET_PERFORMANCE}" != "" ]] ; then
		echo -e "Current Testnet Performance: ${COLOR_TESTNET_PERFORMANCE}${TESTNET_PERFORMANCE}/10 ${NOCOLOR}"
	fi
	
	
	METRICS_SUMMARY_TRUE_FALSE=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics_summary.pass'`
	METRICS_SUMMARY_RAW=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.self_reported_metrics_summary.reason'`
	COLOR_METRICS=`if [[ "${METRICS_SUMMARY_TRUE_FALSE}" == "true" ]];
			then
				if [[ $METRICS_SUMMARY_RAW == *"10/10"* ]];
				then
					echo "${GREEN}"
				else
					echo "${YELLOW}"
				fi
			else
			  echo "${RED}"
			fi`
	METRICS_SUMMARY=`echo "${COLOR_METRICS}"``echo "${METRICS_SUMMARY_RAW}"``echo "${NOCOLOR}"`
	
	echo -e "Metrics: ${METRICS_SUMMARY}"

	
OPTIMISTIC_ARR[6]=`Optimistic_Slot_Now 5`
	
	GL_COLOR_OPT_SLOT=`echo "${RED}"`
	GL_TEXT_OPT_SLOT=`echo "${RED}Optimistic Slot Outdated!${NOCOLOR}"`
	first_elem=`echo "${OPTIMISTIC_ARR[0]}" | awk '{print $1}'`
	last_elem=`echo "${OPTIMISTIC_ARR[-1]}" | awk '{print $1}'`
	
	for ix in ${!OPTIMISTIC_ARR[*]}
	do
		this_elem=`echo "${OPTIMISTIC_ARR[$ix]}" | awk '{print $1}'`
		if [[ "${this_elem}" != "null" ]];
		then
			if [[ "${this_elem}" != "${first_elem}" ]];
			then
				GL_COLOR_OPT_SLOT=`echo "${GREEN}"`
				GL_TEXT_OPT_SLOT=`echo "${GREEN}Optimistic Slot OK!${NOCOLOR}"`
			fi
		fi
	done
	echo -e "Optimistic Slots: ${GL_COLOR_OPT_SLOT}${first_elem}${NOCOLOR}-${GL_COLOR_OPT_SLOT}${last_elem}${NOCOLOR} | ${GL_TEXT_OPT_SLOT}"
	
	if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
		LAST_REWARDS_RAW=$(solana -um vote-account --with-rewards --num-rewards-epochs 1 ${YOUR_VOTE_ACCOUNT} 2>&1)
		LAST_REWARDS=`echo -e "${LAST_REWARDS_RAW}" | grep -m1 -A1 "Reward Slot" | grep -v "Reward" | sed -n -e 1p | awk '{print "Epoch "$1" - "$3}'`

		echo -e "Last Reward: ${LAST_REWARDS:-${LIGHTPURPLE}Cannot see rewards now ${NOCOLOR}}"
	fi
	
	CURRENT_STAKE_STATE=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state'`
	CURRENT_STAKE_REASON=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state_reason'`
	COLOR_STAKE_STATE=`
		if [[ "${CURRENT_STAKE_STATE}" == "Bonus" ]];
		then
		  echo "${GREEN}"
		elif [[ "${CURRENT_STAKE_STATE}" == "Baseline" ]];
		then
		  echo "${YELLOW}"
		else
		  echo "${RED}"
		fi`
	CURRENT_STAKE_ACTION=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.state_action'`
	echo -e "Last Epoch State: ${COLOR_STAKE_STATE}${CURRENT_STAKE_STATE}: ${CURRENT_STAKE_REASON}${NOCOLOR}"
	echo -e "Last Bot Stake Action: In epoch ${LAST_EPOCH} ${CURRENT_STAKE_ACTION}${NOCOLOR}"
	
	Node_Stake_4 | grep -A2 "Stake Total: Active"
	
	CONCENTRATION=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.data_center_stake_percent' | awk '{printf("%.2f\n",$1)}'`
	
	MAX_CONCENTRATION=`
		if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
			echo "10.00"
		else
			echo "25.00"
		fi`
	DC_COLOR=`
		if (( $(bc<<<"scale=2;${CONCENTRATION} < ${MAX_CONCENTRATION}") )); then
		  echo "${GREEN}"
		else
		  echo "${YELLOW}"
		fi`
	
	CURRENT_DC=`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.epoch_data_center.asn'`'-'`echo "${KYC_API_VERCEL_2}" | jq -r '.stats.epoch_data_center.location'`' | '`echo "${DC_COLOR}${CONCENTRATION}"`'%'`echo "${NOCOLOR}"`' concentration'
	
	echo -e "Datacenter: ${CURRENT_DC}"
}


if [[ "${FLAG_ONLY_IMPORTANT}" == "false" ]]; then

	Time_Now_1
echo -e "${GREEN}Solana Price: ${NOCOLOR}"`solana_price`

	Epoch_Progress_2
	#SOLANA_CLUSTER=$(rotateKnownRPC "${SOLANA_CLUSTER}")
	#SOLANA_CLUSTER=$(rotateKnownRPC "${SOLANA_CLUSTER}")
OPTIMISTIC_ARR[5]=`Optimistic_Slot_Now`
	This_Node_3
	Node_Stake_4
OPTIMISTIC_ARR[6]=`Optimistic_Slot_Now`
	SFDP_5
OPTIMISTIC_ARR[7]=`Optimistic_Slot_Now`
	Vote_Credits_6
	Skiprate_7
OPTIMISTIC_ARR[8]=`Optimistic_Slot_Now`
	Optimistic_Slot_Summary
	if [[ ${GRAFANA_HOST_NAME} != "null" ]]; then
		echo -e "${CYAN}"
		echo -e "Hardware Info: ${NOCOLOR}"
		echo -e `Graphana_hardware_info 102`
		#echo -e `Graphana_hardware_info 73`
		echo -e `Graphana_hardware_info 108`
		echo -e `Graphana_hardware_info 118`
		echo -e `Graphana_hardware_info 111`
	fi
	if [[ "${CLUSTER_NAME}" == "(Mainnet)" ]]; then
	Last_Rewards_8
	fi

	else
	
	Time_Now_1
	
	#SOLANA_CLUSTER=$(rotateKnownRPC "${SOLANA_CLUSTER}")
	#SOLANA_CLUSTER=$(rotateKnownRPC "${SOLANA_CLUSTER}")
	
	Only_Important
	if [[ ${GRAFANA_HOST_NAME} != "null" ]]; then
		echo -e `Graphana_hardware_info 102`" | "`Graphana_hardware_info 108`" | "`Graphana_hardware_info 118`" | "`Graphana_hardware_info 111`
	fi
	

fi

echo -e "${NOCOLOR}"

popd > /dev/null || exit 1