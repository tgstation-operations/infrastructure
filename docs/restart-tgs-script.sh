#!/usr/bin/env bash

systemd_output=$(systemctl status tgstation-server | grep Server.Host.Console.dll | tr -d ' ' | cut -d'/' -f1)
pgrep_output=$(pgrep -f Server.Host.Console.dll)
if [[ "$systemd_output" != "$pgrep_output" ]]; then
  echo "Failed to capture PID."
  exit 1
fi

kill -9 $pgrep_output
echo "Waiting for process to die..."
read -P $pgrep_output

echo "Process has exited."
echo "Restart TGS via WebPanel. (Administration > Restart Server)"
read -P"Press ENTER when done. (Ctrl-C to keep TGS dead)"
if [[ "$?" == 1 ]]; then
  echo "TGS will not be restarted."
  exit 0
fi
systemctl start tgstation-server
