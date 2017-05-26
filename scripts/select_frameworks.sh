#!/bin/bash
#set -e

function quit (){
  rm ${ANSWERS}
  echo ${1}
  exit ${2}
}

if ! rpm -qa | grep dialog; then
  sudo yum install -y dialog
fi

RUNAS=${USER}
WEBPORT=9999
ANSWERS=$(mktemp /tmp/select_frameworks.XXXXXX)
MAKEFILE=${HOME}/universe/docker/local-universe/Makefile
frameworks=""
selected=""

skip_questions=false
if [ "${1}" == "-y" ]; then
  skip_questions=true
fi



touch ${ANSWERS}
if ! rpm -qa | grep dialog; then
  quit "Please install dialog: sudo yum install -y dialog" 1
fi

# Is our Makefile fresh out of the box?
if grep '\-\-selected' ${MAKEFILE}; then
  is_oob=true
elif grep '\-\-include=' ${MAKEFILE}; then
  is_oob=false
else
  quit "Malformed Makefile, missing --selected or --include" 1
fi

pushd ${HOME}/universe/repo/packages
  # Get a list of selected or listed framework packages
  if ${is_oob}; then
    selected=$(grep '"selected": true' * -r | cut -d'/' -f2 | sort -u | xargs)
  else
    selected=$(cat ${MAKEFILE} | grep "\-\-include=" | cut -d'"' -f2 | sed "s/,/ /g")
  fi

  if [ -z "${selected}" ]; then
    quit "Could not find selected frameworks" 1
  fi

  # Traverse all directories and extract all package names
  for f in $(find . -maxdepth 2 -mindepth 2 -type d -exec echo {} \; | cut -d '/' -f3); do
    on_off="off"
    if [[ " ${selected} " == *" ${f} "* ]]; then
      on_off="on"
    fi
    frameworks="${frameworks} ${f} ${f} ${on_off}"
  done
popd

dialog --visit-items --no-tags --checklist "Choose Universe Framworks:" 20 40 18 ${frameworks} 2>${ANSWERS}

if [ ! -s ${ANSWERS} ]; then
  quit "No frameworks selected" 0
fi

if ! ${skip_questions}; then
  if ! dialog --defaultno --yesno "Proceed with creating local Universe? This may take long time and consume large amount of disk space." 8 50; then
      quit "Done" 0
  fi
fi

clear

echo "Compiling local universe"
sed -i 's/ /,/g' ${ANSWERS}
my_answers=$(cat ${ANSWERS})

# Manipulate the Makefile
if ${is_oob}; then
  sed -i "s/--selected/--include=\"${my_answers}\"/" ${MAKEFILE}
else
  sed -i "/--include/ s/=\"[^\"][^\"]*\"/=\"${my_answers}\"/" ${MAKEFILE}
fi

pushd ${HOME}/universe/docker/local-universe
  sudo make local-universe
  sudo chown ${RUNAS}:${RUNAS} local-universe.tar.gz
  ls -lh *.tar.gz
  echo "Calculating SHA256"
  sha256sum local-universe.tar.gz > local-universe.tar.gz.sha256

  if ! ${skip_questions}; then
    if ! dialog --defaultno --yesno "Start a web server on port ${WEBPORT} ?" 8 50; then
      clear
      quit "Done. Your local Universe is in $(pwd)/local-universe.tar.gz" 0
    fi
  fi

  web_process=$(sudo su -c "netstat -nltp" | grep ${WEBPORT})
  if [ -z "${web_process}" ]; then
    nohup python3 -m http.server ${WEBPORT} &
  else
    if echo ${web_process} | grep python3; then
      echo "Web server already running."
    else
      quit "Port ${WEBPORT} is in use." 1   
    fi
  fi
popd

clear
quit "Done.You can access your local universe's tarball at http://<your-box-ip>:${WEBPORT}/local-universe.tar.gz" 0