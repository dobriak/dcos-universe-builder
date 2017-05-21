#!/bin/bash
set -e

function quit (){
  rm ${ANSWERS}
  echo ${1}
  exit ${2}
}

if ! rpm -qa | grep dialog; then
  sudo yum install -y dialog
fi

ANSWERS=${HOME}/selected_frameworks
MAKEFILE=${HOME}/universe/docker/local-universe/Makefile
frameworks=""
selected=""

touch ${ANSWERS}
if ! rpm -qa | grep dialog; then
  quit "Please install dialog: sudo yum install -y dialog" 1
fi

# Out of the box?
if grep '\-\-selected' ${MAKEFILE}; then
  is_oob=true
elif grep '\-\-include=' ${MAKEFILE}; then
  is_oob=false
else
  quit "Malformed Makefile, missing --selected or --include" 1
fi

pushd ${HOME}/universe/repo/packages
  if ${is_oob}; then
    selected=$(grep '"selected": true' * -r | cut -d'/' -f2 | sort -u | xargs)
  else
    selected=$(cat ${MAKEFILE} | grep "\-\-include=" | cut -d'"' -f2 | sed "s/,/ /g")
  fi

  if [ -z "${selected}" ]; then
    quit "Could not find selected frameworks" 1
  fi

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

if ! dialog --defaultno --yesno "Proceed with creating local Universe?" 8 50; then
  quit "Done" 0
fi

clear

echo "Compiling local universe"
sed -i 's/ /,/g' ${ANSWERS}
my_answers=$(cat ${ANSWERS})

if ${is_oob}; then
  sed -i "s/--selected/--include=\"${my_answers}\"/" ${MAKEFILE}
else
  sed -i "/--include/ s/=\"[^\"][^\"]*\"/=\"${my_answers}\"/" ${MAKEFILE}
fi

pushd ${HOME}/universe/docker/local-universe
  sudo make local-universe
  echo "Your local Universe is in $(pwd)"
  ls -lh *.tar.gz
popd

quit "Done" 0