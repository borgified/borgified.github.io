---
layout: post
title:  "Testing iptables consistency"
date:   2018-03-15 23:50:56 -08:00
categories:  security
---

Testing whether the rules in /etc/sysconfig/iptables match what's currently running (iptables -L) has always been a problem that we knew how to solve but just did not want to go through the steps to do it because testing involves trying the rules out on a separate system (unless you want to risk locking yourself out of your own server due to some bad rules?) Anyway, we aren't here to cowboy in production and now thanks to docker, there's a way to get all this done without complicated orchestration.

The general strategy is as follows:

1. download /etc/sysconfig/iptables (call it `iptables_file`)
2. run /sbin/iptables-save and save the output to a file (call it `iptables_mem`)
3. spin up a docker container with iptables installed
4. load `/sbin/iptables-restore < iptables_mem` and dump it back out: `/sbin/iptables-save > iptables_mem_out`
5. load `/sbin/iptables-restore < iptables_file` and dump it back out: `/sbin/iptables-save > iptables_file_out`
6. `diff iptables_mem_out iptables_file_out`

Here's my Dockerfile

```
FROM centos:6
RUN yum -y install iptables; yum clean all
COPY iptables_file /
COPY iptables_mem /
```

You can see that the intention is to build a new docker container for every system you are testing. Fortunately, this is very quick as the only changes are the two input files (iptables_file and iptables_mem)

To drive the rest of the automation outlined in steps 1-6, we employ a simple bash script:

```
#!/bin/bash

# requires docker installed

# example: ./consistent_iptables.sh myserver.com

# this script will test whether the iptables resident in memory is consistent with the iptables defined in /etc/sysconfig/iptables
# it does this by downloading both items and testing them locally in a docker container

# if you get sudo: sorry, you must have a tty to run sudo
# that means you have to go to the server you are testing and add "Defaults !requiretty" to the end of /etc/sudoers.d/extra_settings

# ignore these:
# FATAL: Could not load /lib/modules/4.9.60-linuxkit-aufs/modules.dep: No such file or directory

set -e

if [ $# -eq 0 ]; then
  echo "provide hostname to test, eg: $0 myserver.com
  exit 1
fi

HOST=$1

rm -f iptables_mem iptables_mem_out iptables_file iptables_file_out

ssh $HOST sudo /sbin/iptables-save > iptables_mem
ssh $HOST sudo cat /etc/sysconfig/iptables > iptables_file

docker build -q . -t centos6_with_iptables
docker run --cap-add=NET_ADMIN --cap-add=NET_RAW centos6_with_iptables /bin/bash -c "iptables-restore < iptables_file; iptables-save" > iptables_file_out
docker run --cap-add=NET_ADMIN --cap-add=NET_RAW centos6_with_iptables /bin/bash -c "iptables-restore < iptables_mem; iptables-save" > iptables_mem_out
echo
echo "comparing: diff iptables_mem_out iptables_file_out (no output means they are same)"
diff -I'^#' iptables_mem_out iptables_file_out
```

Obviously you need docker already installed locally. Also, it's assumed that you are able to ssh to the server passwordlessly (via public/priv ssh keys). The only real obstacle to make this work was realizing that I needed to include the --cap-add flags in my docker run commands. These are necessary to be able to interact with the network stack (ie. run iptables), otherwise you get errors like "you dont have permission to do that" even though you are root.

You can run the above script and give it the server you are testing as argument: `./consistent_iptables.sh myserver.com`
Leave the Dockerfile in the same directory as the script so it can run the docker build command properly. Happy auditing!
