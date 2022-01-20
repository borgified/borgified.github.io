Python can be pretty annoying on Macs where there may be different versions lying
around, installed in different directories. When you pip install something, you
should make sure they end up in the correct directory.

When you mixing in Ansible on top of this, figuring out where things ought to be can
be a bigger challenge so here are some tips to figure all that out as it relates to
installing (enabling) the hashi_vault plugin.

First, the error message (when you try to run the playbook):
```
ASK [Gathering Facts] *************************************************************************************************************************************************************************************
fatal: [serverIP]: FAILED! => {
    "failed": true,
    "msg": "An unhandled exception occurred while running the lookup plugin 'hashi_vault'. Error was a <class 'ansible.errors.AnsibleError'>, original message: Please pip install hvac to use this module"
}
```

Google tells you to run `pip install hvac` but this is insufficient. You have to install
it to the right place and to do that, you first have to `activate` the right python.
How to figure out which python to activate?

This is how you can figure out which python ansible is actually using:
`ansible -m debug -a 'var=ansible_playbook_python' localhost`

For me, it returns this:
```
[WARNING]: No inventory was parsed, only implicit localhost is available
localhost | SUCCESS => {
    "ansible_playbook_python": "/usr/local/Cellar/ansible/5.1.0/libexec/bin/python3.10"
}
```

Now that you know which python it is, you can source the activate script:
`source /usr/local/Cellar/ansible/5.1.0/libexec/bin/activate`

And finally, you can install hvac: `pip install hvac`


Then if you try running the playbook again, you may get some errors about python crashing.
Apparently, setting this env var will fix:
`export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES`


source: https://github.com/ansible/ansible/issues/28050
