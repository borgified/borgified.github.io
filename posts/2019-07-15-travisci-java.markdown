---
layout: post
title:  "installing java in travis ci"
date:   2019-07-15 20:37:03 +0000
categories: travisci, android
---

The xenial worker in Travis CI comes preinstalled with openjdk8,10,11 according to the [doc](https://docs.travis-ci.com/user/reference/xenial/#jvm-clojure-groovy-java-scala-support), however, if you are doing android development and are trying to trying to use sdkmanager eg. (`yes | sdkmanager --licenses`), you'll be met with this error message:
```
Exception in thread "main" java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
	at com.android.repository.api.SchemaModule$SchemaModuleVersion.<init>(SchemaModule.java:156)
	at com.android.repository.api.SchemaModule.<init>(SchemaModule.java:75)
	at com.android.sdklib.repository.AndroidSdkHandler.<clinit>(AndroidSdkHandler.java:81)
	at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:73)
	at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:48)
Caused by: java.lang.ClassNotFoundException: javax.xml.bind.annotation.XmlSchema
	at java.base/jdk.internal.loader.BuiltinClassLoader.loadClass(BuiltinClassLoader.java:583)
	at java.base/jdk.internal.loader.ClassLoaders$AppClassLoader.loadClass(ClassLoaders.java:178)
	at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:521)
	... 5 more
```
everywhere you can google, it'll tell you that you're using the wrong java version and that you need to downgrade to java 8.


In practice, simply doing a `apt-get -y install openjdk-8-jdk` won't fix it since 1. openjdk-8-jdk is already installed and more importantly, 2. the PATH environment variable includes /usr/local/lib/jvm (where Travis has custom installed openjdk10 and openjdk11) ahead of /usr/lib/jvm (where apt-get normally installs java) so you'll keep getting java11.

My solution was to `rm -rf /usr/local/lib/jvm` and uninstall any existing java installations and just reinstall what you need. You'll also need to define `JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64` for proper sdkmanager operation.


solution:

(.travis.yml snippet)

```
env:
  global:
  - JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
install:
   - sudo apt-get -y remove default-jdk default-jre default-jdk-headless default-jre-headless ca-certificates-java openjdk-8-jdk openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless
   - sudo rm -rf /usr/local/lib/jvm
   - sudo apt-get -y update && sudo apt-get -y install openjdk-8-jdk java-common
   - java -version
```
