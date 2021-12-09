jenkins plugin upgrade goes bad, jenkins hangs on startup... how to revert?

you could restore from backup or... just reinstall old plugin version.

these instructions are taken from this article:
https://chuanchuanlaw.com/jenkins-how-to-manually-upgrade-jenkins-plugin-to-specific-versions/

but i'll reproduce it here because i've found them to be super useful and i would be sad if i didnt
save a backup copy here in case the original site were to go offline.


- Older versions of plugins can be found here: https://updates.jenkins.io/download/plugins/
- The plugins are in .hpi file extensions
- Download the version you want and put it on the Jenkins server
- Plugins are stored in `$JENKINS_HOME/plugins`
- Backup – you might want to backup the current version of the plugins before upgrading. Each plugin has a directory and a .jpi file.
- Place the .hpi file in `$JENKINS_HOME/plugins`
- Restart Jenkins.

- A directory with the plugin name and a .jpi file will be created upon restart
- Check if the plugin with the correct version appears on Jenkins website Manage Jenkins->Plugin Manager
- If not, check the log on the server in /var/log/jenkins
- Log is usually called jenkins.log
- Log will show the plugin installation failure as SEVERE
- Usually this is due to version dependencies of other plugins as named in the log.

```
For eg:

SEVERE: Failed Loading plugin sauce-ondemand
java.io.IOException: Dependency workflow-job (1.15), workflow-cps (1.15), workflow-basic-steps (1.15), workflow-step-api (1.15) doesn’t exist
```

- Download and install the missing dependencies plugin via the same method as above
- Upon successful installation, you will see the plugin with the right version appearing in Manage Jenkins->Plugin Manager



Full credit to CHUAN CHUAN LAW for making his notes available at his blog: https://chuanchuanlaw.com/
