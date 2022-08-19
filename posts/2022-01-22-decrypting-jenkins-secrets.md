some xml files in $JENKINS_HOME contain encrypted passwords, if you need to decrypt then do this:

go to jenkins script console:

```
println(hudson.util.Secret.fromString("{XXX=}").getPlainText())
```

where {XXX=} is your encrypted password. This will print the plain password.


source: https://devops.stackexchange.com/questions/2191/how-to-decrypt-jenkins-passwords-from-credentials-xml
