#!/bin/bash
# ssh_report.sh - Daily SSH security summary from the auth log.
# Run with sudo. Scheduled via cron to run daily.

LOG=/var/log/auth.log

echo "=== SSH Security Report: $(hostname) - $(date) ==="
echo

echo "Failed password attempts: $(grep -v 'sudo:' "$LOG" | grep -c 'Failed password')"
echo "Invalid-user attempts:    $(grep -v 'sudo:' "$LOG" | grep -c 'Invalid user')"
echo

echo "--- Top source IPs (failed logins) ---"
grep -v 'sudo:' "$LOG" | grep -E 'Failed password|Invalid user' \
  | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' \
  | sort | uniq -c | sort -rn | head -5
echo

echo "--- Recent successful logins ---"
grep -v 'sudo:' "$LOG" | grep 'Accepted' | tail -10
echo

echo "--- fail2ban status ---"
fail2ban-client status sshd 2>/dev/null | grep -E 'Currently banned|Total banned|Banned IP' \
  || echo "fail2ban not running or not reachable"
