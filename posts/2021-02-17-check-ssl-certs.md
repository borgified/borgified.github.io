---
layout: post
title:  ""
date:   2021-02-17 13:37:01 -0800
categories: dns ssl certificates
---
when your ssl certs are all over the place and you don't what's where, you'll just have to start checking everything. start from known variables like DNS entries and if you can get a list of A and CNAME records, then you can target each one and attempt to download the ssl cert and reveal its details.

the script below is meant to go into a jenkins job. $RECORDS is a multi-string parameter where you can copy/paste the A and CNAME records. these usually end with a dot which is why the sed is used there to remove that dot.
the inner for loop cycles over suspected ports where https might be served.
i test with curl first before fetching cert with openssl s_client to see if that port even responds. `curl -k` is needed in case the certificate has expired so we can "ignore" that for now and let it progress to fetch the expired cert details.

```
#!/bin/bash
set -uo pipefail
set +e
PATH=$PATH:/usr/local/bin
MYIP=$(curl -s ifconfig.co)
echo "$RECORDS" > a
for i in `cat a | awk '{print $1}' | sed -e s/\.$//`; do
  echo $i
  IP=$(host ${i} | awk '{print $4}')
  if [ "$MYIP" == "$IP" ]; then
    echo "unable to check myself (im at $MYIP and i cant check $IP)"
  else
    for j in 443 8443; do
      timeout 2 curl -s -k https://${i}:${j} > /dev/null && echo ":${j}" && ( timeout 2 openssl s_client -servername ${i} -connect ${i}:${j} -showcerts | awk '/-----BEGIN CERTIFICATE-----/{a=1};a;/-----END CERTIFICATE-----/{exit}' | openssl x509 -noout -subject -issuer -fingerprint -sha256 -enddate) 2> /dev/null
    done
  fi
  echo "====================="
done
exit 0
```

the output can be transposed to a csv format with this: (assuming output is saved to file "z")

```
cat z | sed -e 's/^/"/' | sed -e $'s/$/"/' | tr -s '\n' ',' | sed -e $'s/,"=====================",/\\\n/g'
```
