#!/bin/bash

declare -i duration=1
declare hasUrl=""
declare endpoint

usage() {
    cat <<END
    polling.sh [-i] [-h] endpoint
    
    Report the health status of the endpoint
    -i: include Uri for the format
    -h: help
END
}

while getopts "ih" opt; do 
  case $opt in 
    i)
      hasUrl=true
      ;;
    h) 
      usage
      exit 0
      ;;
    \?)
     echo "Unknown option: -${OPTARG}" >&2
     exit 1
     ;;
  esac
done

shift $((OPTIND -1))

if [[ $1 ]]; then
  endpoint=$1
else
  echo "Please specify the endpoint."
  usage
  exit 1 
fi 


healthcheck() {
    declare url=$1
    result=$(curl -i $url 2>/dev/null | grep HTTP/1.1)
    echo $result
}

i=0
while [[ $i -le 10 ]]; do
   let i+=1
   #echo $i
   result=`healthcheck $endpoint` 
   declare status
   if [[ -z $result ]]; then 
      status="N/A"
   else
      status=${result:9:3}
   fi
   if [[ $status == "N/A" ]]; then
      echo $status
      sleep $duration 
   elif [[ $status -eq 200 ]]; then
      exit 0
   elif [[ $i -le 10 ]]; then
      echo $status
      sleep $duration
   else
      exit 1
   fi
done
