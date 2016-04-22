#!/bin/bash

test -f ./cronedit.conf && source ./cronedit.conf

REPOS_DIR=${REPOS_DIR:-./repos}
test ! -d ${REPOS_DIR} && mkdir -p ${REPOS_DIR}

check_current() {
  if [ -f ${REPOS_DIR}/current -a "`bash -c "diff ${REPOS_DIR}/current <(crontab -l)"`" = "" ]; then
    return
  fi
  latest_crontab=`date +%Y%m%d%H%M%S`
  crontab -l >${REPOS_DIR}/${latest_crontab}
  ln -sf ${latest_crontab} ${REPOS_DIR}/current
}

check_current

cp ${REPOS_DIR}/current ${REPOS_DIR}/.new

vi ${REPOS_DIR}/.new

diff ${REPOS_DIR}/current ${REPOS_DIR}/.new

# no change?
# ~~~
if [ "`bash -c "diff ${REPOS_DIR}/current ${REPOS_DIR}/.new"`" = "" ]; then
  echo -e "cron\e[31medit\e[m: no changes made to crontab"
  rm ${REPOS_DIR}/.new
  exit 0
fi

# replace?
# ~~~
echo -n "relace? [y/N] > "
read input
if [ "${input}" != "y" ]; then
  echo -e "cron\e[31medit\e[m: no changes made to crontab"
  rm ${REPOS_DIR}/.new
  exit 0
fi

crontab < ${REPOS_DIR}/.new
if [ $? -ne 0 ]; then
  rm ${REPOS_DIR}/.new
  exit 1
fi

# success
# ~~~
echo -e "cron\e[31medit\e[m: installing new crontab"
rm ${REPOS_DIR}/.new
check_current

exit 0
