---
layout: post
title:  "Learning Consul and Autopilot pattern"
date:   2017-12-21 23:50:56-08:00
categories: consul autopilot
---

Tried Consul before, getting it running in a handful of AWS instances. But what I really wanted to do was to get it running on my laptop... maybe in a couple of Docker containers. Also wanted to learn autopilot. The terminology is a little confusing... still not sure the difference between ContainerPilot and Autopilot but they are definitely related. Seems like ContainerPilot is some helper agent that runs inside the container for the specific purpose of making it easier to communicate within the Triton ecosystem. I'm only playing on my laptop for now, so I won't need that at the moment.

All the heavy lifting already done: https://github.com/autopilotpattern/consul

git clone https://github.com/autopilotpattern/consul

Read the readme a few times, it's easy to miss but there's a hint about how to run it locally.

After a few tries with the ordering of arguments, this worked:

```docker-compose -f local-compose.yml up```

It comes up and the log suggests it's trying to look for other consul servers and keeps spamming this over and over:

```
consul_1  | 2017-12-22T08:04:22.211017624Z     2017/12/22 08:04:22 [ERR] agent: failed to sync changes: No cluster leader
consul_1  | 2017-12-22T08:04:24.935820859Z     2017-12-22 08:04:24 containerpilot: No peers in raft
consul_1  | 2017-12-22T08:04:24.968092389Z     2017/12/22 08:04:24 [INFO] agent: (LAN) joining: [consul]
consul_1  | 2017-12-22T08:04:24.971486223Z     2017/12/22 08:04:24 [INFO] agent: (LAN) joined: 1 Err: <nil>
consul_1  | 2017-12-22T08:04:24.972290759Z Successfully joined cluster by contacting 1 nodes.
consul_1  | 2017-12-22T08:04:30.043010739Z     2017/12/22 08:04:30 [ERR] agent: Coordinate update error: No cluster leader
consul_1  | 2017-12-22T08:04:32.15633869Z     2017/12/22 08:04:32 [ERR] agent: failed to sync changes: No cluster leader
consul_1  | 2017-12-22T08:04:34.921874517Z     2017-12-22 08:04:34 containerpilot: No peers in raft
consul_1  | 2017-12-22T08:04:34.95462677Z     2017/12/22 08:04:34 [INFO] agent: (LAN) joining: [consul]
consul_1  | 2017-12-22T08:04:34.956292474Z     2017/12/22 08:04:34 [INFO] agent: (LAN) joined: 1 Err: <nil>
consul_1  | 2017-12-22T08:04:34.957329632Z Successfully joined cluster by contacting 1 nodes.
```

Ah no problem I'll just scale consul=3 and it should work.

First Control-C to get out and bring it down nicely to remove any vestigial networking.

```
$ docker-compose -f local-compose.yml down
Stopping consul_consul_1 ... done
Removing consul_consul_1 ... done
Removing network consul_default
```

This worked:

```docker-compose -f local-compose.yml up --scale consul=3```

All 3 consul containers come up, they start finding each other and fully happy and ready to go.
