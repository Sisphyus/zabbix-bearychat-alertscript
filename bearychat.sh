#!/bin/bash

# BearyChat zabbix web-hook URL
url='CHANGEME'		# example: https://hook.bearychat.com/XXX/zabbix/XXXXXXXXXXXXXXXXXXXXXXX

## Values received by this script:
# To = $1 (Slack channel or user to send the message to, specified in the Zabbix web interface; "@username" or "#channel")
# Subject = $2 (usually either PROBLEM or RECOVERY)
# Message = $3 (whatever message the Zabbix action sends, preferably something like "Zabbix server is unreachable for 5 minutes - Zabbix server (127.0.0.1)")

# Get the Slack channel or user ($1) and Zabbix subject ($2 - hopefully either PROBLEM or RECOVERY)
to="$1"
subject="$2"

# Change message emoji depending on the subject - smile (RECOVERY), frowning (PROBLEM), or ghost (for everything else)
recoversub='^RECOVER(Y|ED)?$'
if [[ "$subject" =~ ${recoversub} ]]; then
	emoji=':smile:'
elif [ "$subject" == 'PROBLEM' ]; then
	emoji=':frowning:'
else
	emoji=':ghost:'
fi

# The message that we want to send to Slack is the "subject" value ($2 / $subject - that we got earlier)
#  followed by the message that Zabbix actually sent us ($3)
message="${subject}: $3"

# Build our JSON payload and send it as a POST request to the BearyChat incoming web-hook URL
payload="payload={\"channel\": \"${to//\"/\\\"}\", \"text\": \"${emoji} ${message//\"/\\\"}\"}"
curl -m 5 --data-urlencode "${payload}" $url -A 'zabbix-bearychat-alertscript / https://github.com/ericoc/zabbix-bearychat-alertscript'
