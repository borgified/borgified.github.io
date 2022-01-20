In the previous post, we talked about getting the hashi_vault ansible plugin installed.
Now we focus on figuring out how to use it.

First we figure it out with curl:

Assuming we have a kv (v2) engine set up under /hello and a secret called mysecret underneath,
then the curl to fetch the secret would look like this:
```
curl --header "X-Vault-Token: xxxx" https://vault.url/v1/hello/data/mysecret
```

If you are able to retrieve your secret this way, then you are ready to do it in ansible:

```
---
- hosts: localhost
  collections:
    - community.general
  tasks:
    - debug:
        msg: "{{ lookup('hashi_vault', 'secret=hello/data/mysecret token=xxxx url=https://vault.url') }}"
```
