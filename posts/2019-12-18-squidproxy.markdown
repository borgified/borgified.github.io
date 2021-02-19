---
layout: post
title:  "adding squidproxy to speed up a nodejs app"
date:   2019-12-18 22:29:06 -0800
categories: squid, proxy, nodejs
---
A friend asked me for help to speed up their nodejs app. I don't know nodejs but the way the issue was described to me was that their application had two parts: a frontend and a backend. The backend would make API calls to a Jira server in response to some action from the frontend. They already had a caching layer implemented but from what I understand, it did not cache enough? so their app was slow because waiting for big Jira queries to return took forever.

My suggestion was to rip out their caching implementation and replace it with squid proxy. Here's the PoC.

First we try to create a simple backend server, which I took to be a simple webserver that responded to some endpoint, like /test. After some quick googling, I ended up with this:
```
// backend.js
var express = require("express");
var app = express();
app.listen(3000, () => {
 console.log("Server running on port 3000");
});

app.get("/test", (req, res, next) => {
  console.log(req);
  res.json(["Tony","Lisa","Michael","Ginger","Food"]);
});
```

You'll need to run `npm i express` to install the library first, then you can run:
```
node backend.js
```

And you can test it working with this:
```
curl http://localhost:3000/test
```

At this point, I wasn't sure how the frontend should go, but I figured if I could replicate my curl command in nodejs then that would be good enough. So this is what I came up with:

```
// frontend.js
var request = require('request');

request({
  'url':'http://127.0.0.1:3000/test',
  'method': "GET",
},function (error, response, body) {
  if (!error && response.statusCode == 200) {
    console.log(body);
  }
})
```

So to exercise what we have so far, we should install the request library: `npm i request` and then we can run: `node frontend.js`

This should return you:
```
$ node frontend.js
["Tony","Lisa","Michael","Ginger","Food"]
```

and the terminal running the backend (`node backend`) would show this:
```
IncomingMessage {
  _readableState:
   ReadableState {
     objectMode: false,
     highWaterMark: 16384,
     buffer: BufferList { head: null, tail: null, length: 0 },
     length: 0,
     pipes: null,
     pipesCount: 0,
     flowing: null,
     ended: false,
...
```

The output from the backend is just a bunch of metadata and it's not super useful for our purposes, it's just there to let you know that the backend was hit by a request from the frontend (it'll be useful later when we add the squid proxy and it DOES NOT get hit)

Now that we have the frontend.js and backend.js working, it's time to add the proxy.
```
apt-get -y install squid3
```

Ubuntu already will have started it after installation, you can confirm with:
```
systemctl status squid
```

Let's test to see if our proxy works:
```
curl -x http://localhost:3128 -L http://google.com
```

and watch the logs: `/var/log/squid/access.log`

```
1576738542.148     37 127.0.0.1 TCP_MISS/301 641 GET http://google.com/ - HIER_DIRECT/172.217.6.46 text/html
1576738542.221     73 127.0.0.1 TCP_MISS/200 13745 GET http://www.google.com/ - HIER_DIRECT/172.217.6.68 text/html
```

It's a cache miss (TCP_MISS) but we expected that because it's the first time the proxy sees google.com.
Let's run it again: `curl -x http://localhost:3128 -L http://google.com` and now the logs show:
```
1576738592.239      0 127.0.0.1 TCP_MEM_HIT/301 648 GET http://google.com/ - HIER_NONE/- text/html
1576738592.295     55 127.0.0.1 TCP_MISS/200 13719 GET http://www.google.com/ - HIER_DIRECT/172.217.6.68 text/html
```

Now there's a TCP_MEM_HIT, which is great!

Time to tell the frontend.js about our proxy: (you only have to add one line)

```
var request = require('request');

request({
  'url':'http://127.0.0.1:3000/test',
  'method': "GET",
  'proxy':'http://127.0.0.1:3128'
},function (error, response, body) {
  if (!error && response.statusCode == 200) {
    console.log(body);
  }
})
```

With the proxy in place, let's try it out:
```
node frontend.js
node frontend.js
node frontend.js
```
/var/log/squid/access.log:
```
1576738955.788      3 127.0.0.1 TCP_MISS/200 336 GET http://127.0.0.1:3000/test - HIER_DIRECT/127.0.0.1 application/json
1576738984.546      3 127.0.0.1 TCP_MISS/200 337 GET http://127.0.0.1:3000/test - HIER_DIRECT/127.0.0.1 application/json
1576738985.841      3 127.0.0.1 TCP_MISS/200 337 GET http://127.0.0.1:3000/test - HIER_DIRECT/127.0.0.1 application/json
```

Hmmm, looks like it's not caching. Some googling later, it turns out that we have to configure our squid proxy to tell it what to cache. This is determined by the `refresh_pattern` lines. The last of them:
```
refresh_pattern .               0       20%     4320
```
is supposed to be a catch-all and the 0 means that it'll keep it for 0 seconds. So let's change that to 120 seconds instead:
```
refresh_pattern .               120       20%     4320
```

Gotta restart squid after changing /etc/squid/squid.conf, so, `systemctl restart squid`
Now test again and look at `/var/log/squid/access.log`:
```
1576739281.593      3 127.0.0.1 TCP_MISS/200 337 GET http://127.0.0.1:3000/test - HIER_DIRECT/127.0.0.1 application/json
1576739282.400      0 127.0.0.1 TCP_MEM_HIT/200 343 GET http://127.0.0.1:3000/test - HIER_NONE/- application/json
1576739283.103      0 127.0.0.1 TCP_MEM_HIT/200 343 GET http://127.0.0.1:3000/test - HIER_NONE/- application/json
```

Nice! It worked!

Let's make one more change to `squid.conf` to make sure it caches on disk rather than in memory (since the default is to to use memory)

Just look for the commented line:
```
cache_dir ufs /var/spool/squid 100 16 256
```
and uncomment it and restart squid.


Run your test again and you can see that it definitely cached it in a file:
```
# grep -R Lisa /var/spool/squid
Binary file /var/spool/squid/00/00/00000000 matches

# strings /var/spool/squid/00/00/00000000
http://localhost:3000/test
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: application/json; charset=utf-8
Content-Length: 41
ETag: W/"29-T6TkiEWx9apCITpsvZ8h5e/za3k"
Date: Thu, 19 Dec 2019 06:25:15 GMT
Connection: keep-alive
["Tony","Lisa","Michael","Ginger","Food"]
```
