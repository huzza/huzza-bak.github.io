# Run MapReduce job in Spring-boot

### 1. First idea - just add hadoop* related jars as pom dependencies, add `hadoop classpath` into classpath of runtime

There are two advantages to do in this way: 
* It will make the spring boot application jar huge, if we package hadoop jars into the application jar. 
* The application jar will be independent of *Hadoop* system. Once the Hadoop upgrade. It only needs to update some configuration path for the application.

In maven build, the dependencies could be by scope(see [Maven Scope](https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#Dependency_Scope)). For this case, `provided` could be used, since those jars will be provided as runtime. Like:

```xml
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>2.7.3</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>2.7.3</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-mapreduce-client-common</artifactId>
            <version>2.7.3</version>
            <scope>provided</scope>
        </dependency>
```

But the issue is when using `provided` scope, the `spring-boot-maven-plugin` would report error and can't build final jar. The alternation way is to remove `provided` scope, but add exclusions in `spring-boot-maven-plugin`. Like:

```xml
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <excludeGroupIds>org.apache.hadoop</excludeGroupIds>
            </configuration>
        </plugin>
```

Then the jar is build successfully and hadoop related jars are not included. 

When start to deploy and launch the application jar, the original idea is to do like this way:
```bash
HDP_CLASSPATH=$(hadoop classpath)
java -cp .:${HDP_CLASSPATH} -jar applicaiton.jar
```
But the bad new is - when launching java application using `java -jar applicaiton.jar` the `-cp` could not be used.... after reading spring-boot document, some says it is possible to use [loader.path](https://docs.spring.io/spring-boot/docs/current/reference/html/executable-jar.html) to add extra jars.
I tried that way. It doesn't work form me :(, but we found there is another way to start spring-boot application `org.springframework.boot.loader.JarLauncher`. Use JarLauncher, we can use traditional way to start spring-boot application jar. Below is the command to run:

```bash
HDP_CLASSPATH=$(hadoop classpath)
java -cp .:applicaiton.jar:${HDP_CLASSPATH} org.springframework.boot.loader.JarLauncher
``` 

We hope it works, but it doesn't. JarLauncher will try to initialize `spring-*` stuffs in jar. And there are some web related jars existing in `hadoop classpath`. That will cause program initialization fail ... and it's hard to find out which jars in `hadoop classpath` cause that error.

