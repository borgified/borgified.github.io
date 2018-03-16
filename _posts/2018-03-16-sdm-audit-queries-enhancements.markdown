---
layout: post
title:  "sdm audit queries enhancements"
date:   2018-03-15 23:50:56 -08:00
categories:  sdm
---

When your database is slow, you typically might want to find out WHICH queries are taking a long time to finish followed by WHO are running those queries.

`sdm audit queries -f` gets us 90% of the way there with entries detailing WHO is running WHAT and for HOW LONG. What we lack is a way to order these entries to be able to find the top 5 slowest queries in the past 15 minutes. Fortunately, this can be done with [jq](https://stedolan.github.io/jq/).

First, let's determine how far back we need to look. Keep in mind that the further back you look, the longer it'll take sdm to return the results (there are more entries to go through). To keep things running quickly, let's arbitrarily consider only the past 15 minutes. We do this with the `sdm audit queries --from` command. The logs coming from the sdm proxy are in UTC and the timestamp is in a specific format so we'll have to account for it this way:

```
TS=$(TZ=UTC gdate --date='15 minutes ago' -Iseconds)
```

(gdate is a command available on my mbp, linux users should use `date`)

now our command looks like this:
```
sdm audit queries -j --from $TS
```

To do the sorting and picking out the top 5, we'll need to use jq:
```
sdm audit queries -j --from $TS | jq -s -c 'sort_by(.durationMs)  | .[-5:]' | jq '.[]'
```

Remember how the sdm logs are in UTC? Here's a trick to convert those timezones to your local timezone:
```
awk '/"timestamp":/ { sub(/,/,"",$2); cmd="gdate --date "; cmd $2 | getline mydate; close(cmd $2); printf("  \"timestamp\": \"%s\",\n", mydate); next } 1'
```

In a script, this is what it might look like when you put everything together:
```
#!/bin/bash
set -e

TS=$(TZ=UTC gdate --date='15 minutes ago' -Iseconds)

function convert_tz() {
  awk '/"timestamp":/ { sub(/,/,"",$2); cmd="gdate --date "; cmd $2 | getline mydate; close(cmd $2); printf("  \"timestamp\": \"%s\",\n", mydate); next } 1'
}

sdm audit queries -j --from $TS | jq -s -c 'sort_by(.durationMs) | .[-5:]' | jq '.[]' | convert_tz
```


Bonus:

How about if you already know which query is hurting your database server but you just need to find out who is running it? Let's search by query instead:

```
#!/bin/bash
set -e

TS=$(TZ=UTC gdate --date='15 minutes ago' -Iseconds)

function convert_tz() {
  awk '/"timestamp":/ { sub(/,/,"",$2); cmd="gdate --date "; cmd $2 | getline mydate; close(cmd $2); printf("  \"timestamp\": \"%s\",\n", mydate); next } 1'
}

jqCmd=( sdm audit queries -j --from $TS \| jq "'select(.query|tostring|contains(\""$1"\"))'" )
echo "${jqCmd[@]}"
eval "${jqCmd[@]} | convert_tz"
```

This one can be helpful if your slow query contains some uncommon string that makes it easily identifiable. This will dump out all entries of queries matching that string including WHO is running it. Again, I'm doing timezone conversion with the `convert_tz` function, which may be omitted that if it's not needed.

some output:
```
$ ./a.sh activity_detail
sdm audit queries -j --from 2018-03-16T23:04:25+00:00 | jq 'select(.query|tostring|contains("activity_detail"))'
{
  "timestamp": "Fri Mar 16 16:09:43 PDT 2018",
  "datasourceID": 36,
  "datasourceName": "dsn (myuser@dbserver)",
  "userID": 600,
  "userName": "borgified",
  "durationMs": 335,
  "query": "SHOW COLUMNS FROM `mydatabase`.`activity_detail`",
  "hash": "2c7f0ead7a10c8cf987d667d77996aadfa61b316"
}
```
