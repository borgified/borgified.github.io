---
layout: post
title:  "adding a nginx reverse proxy in front wordpress containers to host multiple sites"
date:   2020-07-25 15:22:37 -0700
categories: 
---

# given
two wordpress sites using official stock [wordpress](https://hub.docker.com/_/wordpress) docker images running with suggested `docker-compose.yml`

# want
add an nginx reverse proxy in front of both sites in order to make it possible to host both from the same ip.
```
outside world -> nginx reverse proxy -> site_a.mydomain.com
                                     -> site_b.mydomain.com
```

# howto
general reverse proxy set up instructions taken from [here](https://www.scaleway.com/en/docs/how-to-configure-nginx-reverse-proxy/#:~:text=A%20Nginx%20HTTPS%20reverse%20proxy%20is%20an%20intermediary%20proxy%20service,response%20back%20to%20the%20client.)

1. since we have two wordpress sites, they both cant occupy the same local port 80 so let's make `site_a` use port 8000 and `site_b` use port 9000. the mysyql service only communicates with the wp service so it doesn't need a local port to map to. (modify the docker-compose.yml on both sites)

2. install nginx, modify configs `/etc/nginx/conf.d/reverse-proxy.conf`
```
server {
        server_name site_a.mydomain.com;
        listen 80;
        listen [::]:80;

        access_log /var/log/nginx/reverse-access-site_a.log;
        error_log /var/log/nginx/reverse-error-site_a.log;

        location / {
                    proxy_pass http://127.0.0.1:8000;
                    # proxy_set_header Forwarded $proxy_add_forwarded;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header Host site_a.mydomain.com;
        }
}

server {
        server_name site_b.mydomain.com;
        listen 80;
        listen [::]:80;

        access_log /var/log/nginx/reverse-access-site_b.log;
        error_log /var/log/nginx/reverse-error-site_b.log;

        location / {
                    proxy_pass http://127.0.0.1:9000;
                    # proxy_set_header Forwarded $proxy_add_forwarded;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header Host site_b.mydomain.com;
        }
}
```

# issues
in the nginx logs:
```
2020/07/09 02:00:12 [crit] 38150#0: *5 connect() to 127.0.0.1:8000 failed (13: Permission denied) while connecting to upstream, client: ::1, server: , request: "GET / HTTP/1.1", upstream: "http ://127.0.0.1:8000/", host: "localhost"
```
fix: `setsebool -P httpd_can_network_connect 1`
