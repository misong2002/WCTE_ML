#!/bin/bash
hn=$(hostname -s)
url=$(jupyter notebook list | grep -m1 -Po "(?<=${hn}:)[0-9]+")
pattern="http://${hn}:([0-9]+)[^ ]*"
echo "Checking for running jupyter..."
if [[ $(jupyter notebook list) =~ $pattern ]]; then
  url=${BASH_REMATCH[0]}
  port=${BASH_REMATCH[1]}
  echo ""
  echo ""
  echo "== Instructions to connect to jupyter running on Narval =="
  echo ""
  echo "Jupyter is running on ${hn}:${port}."
  echo ""
  echo "Create an ssh tunnel to Cedar from your local computer with the command:"
  echo "  ssh -N -L 8999:${hn}:${port} ${USER}@narval.computecanada.ca"
  echo "add the -f option to run in the tunnel in the background, but don't forget to kill that background process when you've finished with it."
  echo ""
  echo "Then connect to this url on your local computer:"
  echo "  ${url/${hn}:${port}/localhost:8999}"
  echo "If port 8999 is already in use on your local computer, try changing this port in both the ssh command and the URL (but not the remote port in the ssh command)."
  echo ""
else
  echo "Jupyter is not yet running on $hn"
  exit 1
fi
