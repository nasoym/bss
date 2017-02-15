#!/usr/bin/env bash

set -f -o pipefail

source lib/logger
source lib/http_helpers
source lib/parse_request
source lib/find_handler_file

: ${ROUTES_PATH:="$(dirname $0)/handlers"}
: ${DEFAULT_ROUTE_HANDLER:="${ROUTES_PATH}/default"}

parse_request
log "request: ${SOCAT_PEERADDR}:${SOCAT_PEERPORT} ${request_method} ${request_uri}"
find_handler_file $request_path

if [[ -n "$request_matching_route_file" ]];then
  # RESPONSE_CONTENT="$(echo "$request_content" | $request_matching_route_file "${COMMAND_ARGUMENTS[@]}" $(urldecode ${request_subpath//\// }))"
  RESPONSE_CONTENT="$(echo "$request_content" | $request_matching_route_file $(urldecode ${request_subpath//\// }))"
  if [[ $? -eq 1 ]];then
    echo_response_status_line 500 "Internal Server Error"
    echo_response_default_headers
    echo -e "\r"
    exit 0
  fi
  if [[ "$RESPONSE_CONTENT" =~ ^HTTP\/[0-9]+\.[0-9]+\ [0-9]+ ]];then
    echo "${RESPONSE_CONTENT}"
  else
    echo_response_status_line  
    echo_response_default_headers
    echo -e "Content-Type: text/html\r"
    echo -e "Content-Length: ${#RESPONSE_CONTENT}\r"
    echo -e "\r"
    echo "${RESPONSE_CONTENT}"
  fi
else
  echo_response_status_line 404 "Not Found"
  echo_response_default_headers
  echo -e "\r"
fi



# printenv | grep -i "request" >&2
# printenv | grep -i "socat" >&2
# printenv >&2

# echo "foobar"

