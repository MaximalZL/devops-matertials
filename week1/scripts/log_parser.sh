#!/usr/bin/env bash

set -u

log_file=""
if [[ -f /var/log/syslog ]]; then
    log_file="/var/log/syslog"
elif [[ -f /var/log/messages ]]; then
    log_file="/var/log/messages"
else
    echo "Log file not found: /var/log/syslog or /var/log/messages" >&2
    exit 1
fi

output_file="errors_$(date +%F).log"
current_year="$(date +%Y)"
now_epoch="$(date +%s)"
cutoff_epoch="$(date -d '10 minutes ago' +%s)"

awk -v year="$current_year" -v now_epoch="$now_epoch" -v cutoff_epoch="$cutoff_epoch" '
BEGIN {
    months["Jan"] = 1
    months["Feb"] = 2
    months["Mar"] = 3
    months["Apr"] = 4
    months["May"] = 5
    months["Jun"] = 6
    months["Jul"] = 7
    months["Aug"] = 8
    months["Sep"] = 9
    months["Oct"] = 10
    months["Nov"] = 11
    months["Dec"] = 12
}
{
    month_name = $1
    day = $2 + 0
    split($3, time_parts, ":")

    if (!(month_name in months) || length(time_parts) != 3) {
        next
    }

    month_num = months[month_name]
    line_epoch = mktime(sprintf("%d %02d %02d %02d %02d %02d", year, month_num, day, time_parts[1], time_parts[2], time_parts[3]))

    if (line_epoch > now_epoch + 60) {
        line_epoch = mktime(sprintf("%d %02d %02d %02d %02d %02d", year - 1, month_num, day, time_parts[1], time_parts[2], time_parts[3]))
    }

    if (line_epoch >= cutoff_epoch && tolower($0) ~ /(error|fail|critical)/) {
        print
    }
}
' "$log_file" > "$output_file"

attempt=1
while [[ $attempt -le 3 ]]; do
    if curl --silent --show-error --fail \
        -X POST \
        -F "file=@${output_file}" \
        -F "filename=${output_file}" \
        https://httpbin.org/post > /dev/null; then
        echo "Found lines saved to ${output_file}"
        echo "File content sent successfully to https://httpbin.org/post"
        exit 0
    fi

    if [[ $attempt -lt 3 ]]; then
        echo "No internet connection or request failed. Retry in 10 seconds... (attempt ${attempt}/3)" >&2
        sleep 10
    else
        echo "No internet connection or request failed after 3 attempts." >&2
        exit 1
    fi

    attempt=$((attempt + 1))
done
