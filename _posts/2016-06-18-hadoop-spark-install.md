---
layout: blog
title:  "Hadoop and Spark Installation  "
date:   2016-06-23 20:00:00
categories: Big Data
permalink: /java-concurrent programming
author: Jaren
duoshuoid: Jaren2016062301
excerpt: Hadoop 2.x and Spark 1.6.1 installation guide
---

* Table of contents
{:toc}




##	Downloading and installing Hadoop 


### Installing Hadoop 2.x to Red Hat Linux

This section including step by step procedures for installing `Hadoop 2.6.4` to Fedora 23, and configuring a Single Node Setup.

#### Step.1 Prerequisites

~~~~
$ uname -a
Linux localhost 4.2.3-300.fc23.x86_64 #1 SMP Mon Oct 5 15:42:54 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux


$ java -version
java version "1.7.0_60"
Java(TM) SE Runtime Environment (build 1.7.0_60-b19)
Java HotSpot(TM) 64-Bit Server VM (build 24.60-b09, mixed mode)
~~~~

####Step.2 Download and Install

~~~~
$ wget http://apache.fayea.com/hadoop/common/hadoop-2.6.4/hadoop-2.6.4.tar.gz
$ tar -xvf hadoop-2.6.4.tar.gz
$ cd hadoop-2.6.4
~~~~


Edit `/etc/profile`, root user is needed.


~~~~
#set hadoop
export JAVA_LIBRARY_PATH=/home/renjie/work/hadoop/lib/native
export HADOOP_HOME=/home/userName/hadoop-2.6.4
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
~~~~

After edit

~~~~
source /etc/profile
~~~~


#### Step.3 Configure

Edit `etc/hadoop/hadoop-env.sh`, comment out JAVA_HOME, make sure it point to a valid Java Home:

~~~~
export JAVA_HOME=/usr/java/jdk1.7.0_60
~~~~

NOTE: Java 1.6 or higher is needed.

Edit `etc/hadoop/core-site.xml`, add the following properties in :

  
~~~~
<property>
     <name>hadoop.tmp.dir</name>
      <value>file:/home/userName/hadoop-2.6.4/tmp</value>
</property>
<property>
     <name>fs.defaultFS</name>
     <value>hdfs://localhost:9000</value>
</property>
<property>
    <name>hadoop.proxyuser.userName.hosts</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.userName.groups</name>
    <value>*</value>
</property>
~~~~

NOTE: the property’s value should match to your’s setting.

Edit `etc/hadoop/hdfs-site.xml`, add the following property in:

~~~~
<property>
     <name>dfs.replication</name>
     <value>1</value>
</property>
<property>
     <name>dfs.namenode.name.dir</name>
     <value>file:/home/userName/hadoop-2.6.4/tmp/dfs/name</value>
</property>
<property>
     <name>dfs.datanode.data.dir</name>
     <value>file:/home/userName/hadoop-2.6.4/tmp/dfs/data</value>
</property>
~~~~

Format a new distributed-filesystem via execute

~~~~
hadoop-2.6.4/bin/hadoop namenode -format
~~~~

#### Step.4 Start

Start all hadoop services via execute

~~~~
$ ./sbin/start-all.sh
~~~~

NOTE: there are 5 java processes which represent 5 services be started: `NameNode`, `SecondaryNameNode`, `DataNode`, `JobTracker`, `TaskTracker`. Execute `jps -l' to check the java processes:

~~~~
$ jps -l
4056 org.apache.hadoop.hdfs.server.namenode.NameNode
4271 org.apache.hadoop.hdfs.server.datanode.DataNode
4483 org.apache.hadoop.hdfs.server.namenode.SecondaryNameNode
4568 org.apache.hadoop.mapred.JobTracker
4796 org.apache.hadoop.mapred.TaskTracker
~~~~

NOTE: `NameNode`, `JobTracker`, `TaskTracker` has relevant Web Consoles for View and Monitor the serivces. Web Access URLs for Services:

~~~~
http://localhost:50030/   for the Jobtracker
http://localhost:50070/   for the Namenode
http://localhost:50060/   for the Tasktracker
~~~~

#### Step.5 Stop

Stop all hadoop services via execute

~~~~
# ./sbin/stop-all.sh
~~~~



## Downloading and installing Apache Hive

This section including step by step procedures for installing Apache Hive and set up HiveServer2.
 
**Step.1 Prerequisites**

Hadoop is the prerequisite, refer to above steps to install and start Hadoop.

**Step.2 Install**

~~~~
$ tar -xvf apache-hive-1.2.1-bin.tar.gz
$ cd apache-hive-1.2.1-bin
~~~~

**Step.3 Configure**

Create a `hive-env.sh` under `conf`

~~~~
$ cd conf/
$ cp hive-env.sh.template hive-env.sh
$ vim hive-env.sh
~~~~

comment out HADOOP_HOME and make sure point to a valid Hadoop home, for example:

~~~~
HADOOP_HOME=/home/kylin/server/hadoop-1.2.1
~~~~

Navigate to Hadoop Home, create '/tmp' and '/user/hive/warehouse' and chmod g+w in HDFS before running Hive:

~~~~
$ ./bin/hadoop fs -mkdir /tmp
$ ./bin/hadoop fs -mkdir /user/hive/warehouse
$ ./bin/hadoop fs -chmod g+w /tmp
$ ./bin/hadoop fs -chmod g+w /user/hive/warehouse
$ ./bin/hadoop fs -chmod 777 /tmp/hive
~~~~

NOTE: Restart Hadoop services is needed, this for avoid `java.io.IOException: Filesystem closed` in DFSClient check Open.

Create a `hive-site.xml` file under conf folder

~~~~
$ cd apache-hive-1.2.1-bin/conf/
$ touch hive-site.xml
~~~~

Edit the `hive-site.xml`, add the following content:

~~~~
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>hive.server2.thrift.min.worker.threads</name>
        <value>5</value>
    </property>
    <property>
        <name>hive.server2.thrift.max.worker.threads</name>
        <value>500</value>
    </property>
    <property>
        <name>hive.server2.thrift.port</name>
        <value>10000</value>
    </property>
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>0.0.0.0</value>
    </property>
</configuration>
~~~~

NOTE: there are other Optional properties, more refer to https://cwiki.apache.org/confluence/display/Hive/Setting+Up+HiveServer2[Setting+Up+HiveServer2]

**Step.4 Start HiveServer2**

~~~~
$ ./bin/hiveserver2
~~~~


 
## Downloading and installing Apache Spark

This section including step by step procedures for installing Apache Spark in Single Node. You can install Spark from source or Pre-build package. In this section, we use **Spark 1.6.1 Pre-built for Hadoop 2.6**. 

Spark runs on Java 7+, Python 2.6+ and R 3.1+. For the Scala API, Spark 1.6.1 uses Scala 2.10. You will need to use a compatible Scala version (2.10.x).

 
**Step.1 Install Scala**

1) Download Scala 

~~~~
$ wget http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz
$ tar -zxvf scala-2.11.8.tgz
~~~~


2)Configure 

Edit `/etc/profile`, root user is needed.

~~~~
export SCALA_HOME=/home/userName/scala-2.11.8
export PATH=$PATH:$SCALA_HOME/bin
~~~~

After edit

~~~~
source /etc/profile
~~~~


**Step.2 Install Spark**

You will need to use a compatible Spark version to match Hadoop in your system.   

1) Download Spark

You can download Spark from http://spark.apache.org/downloads.html.

~~~~
$ tar -xvf spark-1.6.1-bin-hadoop2.6.tgz
$ cd spark-1.6.1-bin-hadoop2.6
~~~~

2) Configure

* Edit `/etc/profile`, root user is needed.

~~~~
#set SPARK
export SPARK_HOME=/home/username/spark-1.6.1-bin-hadoop2.6
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
~~~~

After edit

~~~~
source /etc/profile
~~~~

* Copy conf/spark-env.sh.template to conf/spark-env.sh, edit the `spark-env.sh`, add the following content:

~~~~
export JAVA_HOME=/usr/local/java
export SCALA_HOME=/home/userName/scala-2.11.8
export SPARK_MASTER_IP=127.0.0.1
export SPARK_LOCAL_IP=127.0.0.1
export SPARK_WORKER_MEMORY=2000m
export HADOOP_CONF_DIR=/home/userName/hadoop-2.6.4/etc/hadoop
export SPARK_WORKER_CORES=1
export SPARK_WORKER_INSTANCES=1
~~~~


* Copy conf/slaves.template to conf/slaves, edit the `slaves`, add the following content:

~~~~
localhost
~~~~


**Step.3 Start Spark**

~~~~
$ cd $SPARK_HOME
$ ./sbin/start-all.sh 
~~~~
 

