#!/bin/bash
page=1
json_response=$(curl -s -X GET 'https://api.github.com/repos/datamove/linux-git2/pulls?state=all&page='$page'&per_page=100' | jq -c '.')
while [[ $json_response != "[]" ]]
do
 json_response_s[page-1]=$json_response
 json_response=$(curl -s -X GET 'https://api.github.com/repos/datamove/linux-git2/pulls?state=all&page='$page'&per_page=100' | jq -c '.')
 page=$((page + 1))
done

counter=0
for r in "${json_response_s[@]}"
do
 counter=$((`echo $r | jq '.[].user.login' | grep -o $1 | wc -l`+counter))
done
echo "PULLS" $counter

users_request_s=$(echo "${json_response_s[@]}" | jq -s '.[] | .[] | select(.user.login=="'$1'") | .number')
arr="[";for item in ${users_request_s}; do arr+=$item;arr+=","; done; arr=${arr::-1};arr+="]";
earliest=$(echo $arr|jq 'sort|.[0]')
echo "EARLIEST" ${earliest}

status=$(echo "${json_response_s[@]}" | jq -s '.[] | .[] | select(.user.login=="'$1'" and .number=='${earliest}') | .merged_at')
test -z $status 
echo "MERGED" "$?"
