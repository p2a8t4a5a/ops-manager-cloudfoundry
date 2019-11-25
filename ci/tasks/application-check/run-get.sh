#!/usr/local/bin/dumb-init /bin/bash
set -eo pipefail
[[ ${DEBUG:-} = true ]] && set -x
base=$PWD
app_name="app-ruby-sample"
. "$base/ops-manager-cloudfoundry/ci/tasks/helpers/cf-helper.sh"

cf login -a $CF_APP_URL -u $CF_APP_USER -p $CF_APP_PASSWORD --skip-ssl-validation -o system -s system
check_app_started $app_name
host=$(echo $(cf apps | grep $app_name | awk '{print $6}'))
url="http://${host}/service/mongo/test3"
result=$(echo $(curl -X GET ${url}))
if [ "${result}" = '{"data":"sometest130"}' ]; then
    echo "Application is working"
    echo "Cleaning data.."
    curl -X DELETE ${url}
else
    echo "GET ${url} finished with result: ${result}"
    echo "FAILED. Application doesn't work"
    exit 1
fi
cf logout
