#!/bin/bash
#
# Title:      PGBlitz (Reference Title File)
# Author(s):  Admin9705
# URL:        https://pgblitz.com - http://github.pgblitz.com
# GNU:        General Public License v3.0
################################################################################
source /opt/plexguide/menu/functions/functions.sh

updateprime() {
  abc="/var/plexguide"
  mkdir -p ${abc}
  chmod 0775 ${abc}
  chown 1000:1000 ${abc}

  variable ${abc}/pgfork.project "UPDATE ME"
  variable ${abc}/pgfork.version "changeme"
  variable ${abc}/tld.program "portainer"
  variable /opt/appdata/plexguide/plextoken ""
  variable ${abc}/server.ht ""
  variable ${abc}/server.email "NOT-SET"
  variable ${abc}/server.domain "NOT-SET"
  variable ${abc}/pg.number "New-Install"
  variable ${abc}/emergency.log ""
  variable ${abc}/pgbox.running ""
  pgnumber=$(cat /var/plexguide/pg.number)

  hostname -I | awk '{print $1}' >${abc}/server.ip
  file="${abc}/server.hd.path"
  if [ ! -e "$file" ]; then echo "/mnt" >${abc}/server.hd.path; fi

  file="${abc}/new.install"
  if [ ! -e "$file" ]; then newinstall; fi

versioncheck=$(cat /etc/*-release | grep "Ubuntu" | grep -E '19')
  if [ "$versioncheck" == "19" ]; then
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔ Argggggg ......  System Warning! 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Supported: UBUNTU 16.xx - 18.10 ~ LTS/SERVER and Debian 9.* / 10

This server may not be supported due to having the incorrect OS detected!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  exit 1
  else
    echo "18"  >${abc}/os.version.check; 
  fi

ospgversion=$(cat /etc/*-release | grep Debian | grep -E '9|10')
  if [ "$ospgversion" != "" ]; then
    echo "debian" >${abc}/os.version
  else 
    echo "ubuntu" >${abc}/os.version; 
  fi

  echo "3" >${abc}/pg.mergerfsinstall
  echo "52" >${abc}/pg.pythonstart
  echo "12" >${abc}/pg.aptupdate
  echo "150" >${abc}/pg.preinstall
  echo "24" >${abc}/pg.folders
  echo "16" >${abc}/pg.dockerinstall
  echo "15" >${abc}/pg.server
  echo "1" >${abc}/pg.serverid
  echo "33" >${abc}/pg.dependency
  echo "11" >${abc}/pg.docstart
  echo "2" >${abc}/pg.motd
  echo "115" >${abc}/pg.alias
  echo "3" >${abc}/pg.dep
  echo "3" >${abc}/pg.cleaner
  echo "3" >${abc}/pg.gcloud
  echo "12" >${abc}/pg.hetzner
  echo "1" >${abc}/pg.amazonaws
  echo "8.4" >${abc}/pg.verionid
  echo "1" >${abc}/pg.installer
  echo "7" >${abc}/pg.prune
  echo "21" >${abc}/pg.mountcheck
  echo "11" >${abc}/pg.watchtower
}

pginstall() {
  updateprime
  bash /opt/plexguide/menu/pggce/gcechecker.sh
  core pythonstart
  core aptupdate
  core alias
  core folders
  core dependency
  core mergerfsinstall
  core dockerinstall
  core docstart

  touch ${abc}/install.roles
  rolenumber=3
  # Roles Ensure that PG Replicates and has once if missing; important for startup, cron and etc
  if [[ $(cat /var/plexguide/install.roles) != "$rolenumber" ]]; then
    rm -rf /opt/{coreapps,communityapps,pgshield} 

    pgcore
    pgcommunity
    pgshield
    echo "$rolenumber" >${abc}/install.roles
  fi
  rcloneinstall
  portainer
  core motd &>/dev/null &
  core hetzner &>/dev/null &
  core gcloud
  core cleaner &>/dev/null &
  core serverid
  core prune
  customcontainers &>/dev/null &
  pgedition
  core mountcheck
  emergency
  pgdeploy
}

core() {
  touch ${abc}/pg."${1}".stored
  start=$(cat /var/plexguide/pg."${1}")
  stored=$(cat /var/plexguide/pg."${1}".stored)
  if [ "$start" != "$stored" ]; then
    $1
    cat ${abc}/pg."${1}" >${abc}/pg."${1}".stored
  fi
}

############################################################ INSTALLER FUNCTIONS
alias() {
  ansible-playbook /opt/plexguide/menu/alias/alias.yml
}

templatespart2() {
  ansible-playbook /opt/plexguide/menu/alias/alias.yml >/dev/null 2>&1
  #ansible-playbook /opt/plexguide/menu/prune/main.yml >/dev/null 2>&1
  ansible-playbook /opt/plexguide/menu/pg.yml --tags journal >/dev/null 2>&1
  #ansible-playbook /opt/plexguide/menu/motd/motd.yml >/dev/null 2>&1
}

aptupdate() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags update
}

customcontainers() {
  mkdir -p /opt/{coreapps,communityapps/apps,pgshield}
  touch /opt/appdata/plexguide/rclone.conf
  rclone --config /opt/appdata/plexguide/rclone.conf copy /opt/mycontainers/ /opt/communityapps/apps
}

cleaner() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags autodelete,clean,journal &>/dev/null &
}

dependency() {
  ospgversion=$(cat /var/plexguide/os.version)
  if [ "$ospgversion" == "debian" ]; then
    ansible-playbook /opt/plexguide/menu/dependency/dependencydeb.yml
  else
    ansible-playbook /opt/plexguide/menu/dependency/dependency.yml
  fi
}

docstart() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags docstart
}

emergency() {
  bash /opt/plexguide/menu/functions/emergency.sh
}

folders() {
  ansible-playbook /opt/plexguide/menu/installer/folders.yml
}

prune() {
  ansible-playbook /opt/plexguide/menu/prune/main.yml
}

hetzner() {
  version="$(curl -s https://api.github.com/repos/hetznercloud/cli/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
  wget -P /tmp "https://github.com/hetznercloud/cli/releases/download/$version/hcloud-linux-amd64-$version.tar.gz"
  tar -xvf "/tmp/hcloud-linux-amd64-$version.tar.gz" -C /tmp
  mv "/tmp/hcloud-linux-amd64-$version/bin/hcloud" /bin/
  rm -rf /tmp/hcloud-linux-amd64-$version.tar.gz
  rm -rf /tmp/hcloud-linux-amd64-$version
}

gcloud() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags gcloud_sdk
}

mergerfsupdate() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags mergerfsupdate
}

mergerfsinstall() {
  ansible-playbook /opt/plexguide/menu/pg.yml --tags mergerfsinstall
}

rcloneinstall() {
# ansible-playbook /opt/plexguide/menu/pg.yml --tags rcloneinstall
rcversion="$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
rcstored="$(rclone --version | awk '{print $2}' | tail -n 3 | head -n 1 )"

if [[ "$rcversion" == "$rcstored" ]]; then
  echo "✅ rclone latest stable version check "
  clear
elif [[ "$rcversion" != "$rcstored" ]]; then
  ansible-playbook /opt/plexguide/menu/pg.yml --tags rcloneinstall
  bash /opt/plexguide/menu/pgui/templates/check.sh
  clear
  tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
↘️  rclone updated to version $rcstored
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 3s
fi
}

motd() {
  ansible-playbook /opt/plexguide/menu/motd/motd.yml
}

mountcheck() {
  ansible-playbook /opt/plexguide/menu/pgui/mcdeploy.yml
}

newinstall() {
  rm -rf ${abc}/pg.exit 1>/dev/null 2>&1
  file="${abc}/new.install"
  if [ ! -e "$file" ]; then
    touch ${abc}/pg.number && echo off >/tmp/program_source
    bash /opt/plexguide/menu/version/file.sh
    file="${abc}/new.install"
    if [ ! -e "$file" ]; then exit; fi
  fi
}

pgdeploy() {
  touch ${abc}/pg.edition
  bash /opt/plexguide/menu/start/start.sh
}

pgedition() {
  file="${abc}/path.check"
  if [ ! -e "$file" ]; then touch ${abc}/path.check && bash /opt/plexguide/menu/dlpath/dlpath.sh; fi
  # FOR PG-BLITZ
  file="${abc}/project.deployed"
  if [ ! -e "$file" ]; then echo "no" >${abc}/project.deployed; fi
  file="${abc}/project.keycount"
  if [ ! -e "$file" ]; then echo "0" >${abc}/project.keycount; fi
  file="${abc}/server.id"
  if [ ! -e "$file" ]; then echo "[NOT-SET]" -rf >${abc}/rm; fi
}

portainer() {
  dstatus=$(docker ps --format '{{.Names}}' | grep "portainer")
  if [ "$dstatus" != "portainer" ]; then
    ansible-playbook /opt/coreapps/apps/portainer.yml &>/dev/null &
  fi
}

# Roles Ensure that PG Replicates and has once if missing; important for startup, cron and etc
pgcore() { if [ ! -e "/opt/coreapps/place.holder" ]; then ansible-playbook /opt/plexguide/menu/pgbox/boxcore.yml; fi; }
pgcommunity() { if [ ! -e "/opt/communityapps/place.holder" ]; then ansible-playbook /opt/plexguide/menu/pgbox/boxcommunity.yml; fi; }
pgshield() { if [ ! -e "/opt/pgshield/place.holder" ]; then
     echo 'pgshield' >/var/plexguide/pgcloner.rolename
     echo 'PTS-Shield' >${abc}/pgcloner.roleproper
     echo 'PTS-Shield' >${abc}/pgcloner.projectname
     echo 'master' >${abc}/pgcloner.projectversion
     echo 'pgshield.sh' >${abc}/pgcloner.startlink
     ansible-playbook "/opt/plexguide/menu/pgcloner/corev2/primary.yml"
fi; }

pythonstart() {
    bash /opt/plexguide/menu/roles/pythonstart/pyansible.sh >/dev/null 2>&1
}

dockerinstall() {
    ansible-playbook /opt/plexguide/menu/pg.yml --tags docker
}

serverid() {
  tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
↘️   Establishing Server ID               💬  Use One Word & Keep it Simple
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -p '🌏  TYPE Server ID | Press [ENTER]: ' typed </dev/tty

  if [ "$typed" == "" ]; then
    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  WARNING! - The Server ID Cannot Be Blank!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 1
    serverid
  else
    tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️  PASS: Server ID $typed Established
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo "$typed" >${abc}/server.id
    sleep 1
  fi
}
