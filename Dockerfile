FROM base

env   DEBIAN_FRONTEND noninteractive

# REPOS
run    apt-get install -y software-properties-common
run    add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
run    add-apt-repository -y ppa:chris-lea/node.js
run    apt-get --yes update
run    apt-get --yes upgrade --force-yes

#SHIMS
run    dpkg-divert --local --rename --add /sbin/initctl
run    ln -s /bin/true /sbin/initctl

# TOOLS
run    apt-get install -y -q curl git wget 

## NODE
run    apt-get install -y -q nodejs npm
env   DEBIAN_FRONTEND dialog

## County required
run    apt-get --yes install redis-server --force-yes

## Setup Bot
run    cd /opt; git clone https://github.com/ubuntu-si/ircbot.git bot --depth 1
run    cd /opt/bot ; npm install
run    npm install -g foreman

WORKDIR /opt/bot
CMD ["/usr/bin/nf", "start"]