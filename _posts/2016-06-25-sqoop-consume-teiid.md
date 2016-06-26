---
layout: blog
title: "Sqoop Consume Teiid  "
date: 2016-06-25 10:00:00
categories: bigdata
permalink: /sqoop-consume-teiid
author: Jaren
duoshuoid: Jaren2016062501
excerpt: Sqoop installation and import VDB from Teiid to HDFS
---

* Table of contents
{:toc}




## Downloading and installing Sqoop 
Sqoop can import/export data from Database, like mysql, sql server, etc. 

### Installing Sqoop
 Acturally, the installation is quite easy.

#### Step.1 Download

You can get Sqoop from http://sqoop.apache.org. Compatible Sqoop version is needed to match you Hadoop version.

 
~~~~
$ wget http://apache.fayea.com/sqoop/1.4.6/sqoop-1.4.6.bin__hadoop-2.0.4-alpha.tar.gz
$ tar -xvf sqoop-1.4.6.bin__hadoop-2.0.4-alpha.tar.gz
~~~~


####Step.2  Configure

Just set environment variable, that's all.

Edit `/etc/profile`, root user is needed.


~~~~
export SQOOP_HOME=/home/userName/sqoop-1.4.6.bin__hadoop-2.0.4-alpha
export PATH = $SQOOP_HOME/bin:$PATH
~~~~

After edit

~~~~
$ source /etc/profile
~~~~

## Sqoop consume Teiid


This quickstart demonstrates how to import data from teiid to HDFS by Sqoop.

*  VDB:   Portfolio 


### System requirements

* Java 1.7+
* [Teiid Server](https://github.com/teiid/teiid-quickstarts/blob/master/README.adoc#_downloading_and_installing_teiid)
* [Hadoop](http://snail.ren/java-concurrent%20programming)
* Sqoop

> NOTE: This example relies upon the vdb-datafederation example and that it needs to be deployed prior to running this example. Therefore, read the vdb-datafederation's [README.md](https://github.com/teiid/teiid-quickstarts/blob/master/vdb-datafederation/README.adoc) and follow its directions before continuing.

 
 


### Sqoop Demonstrations	

#### 1. Copy teiid-jdbc to $SQOOP_HOME/lib

You need download Teiid JDBC Driver from http://teiid.jboss.org/downloads/ and copy it to $SQOOP_HOME/lib

~~~~
cp teiid-9.0.0.Final-jdbc.jar $SQOOP_HOME/lib
~~~~


#### 2. Import data to HDFS

~~~~
$ sqoop import --connect jdbc:teiid:Portfolio@mm://127.0.0.1:31000 --driver org.teiid.jdbc.TeiidDriver --username odataUser --password password1! --table product 
~~~~

#### 3. Check HDFS

Now, you can verify that whether the data from VDB is imported to HDFS.

* Verify HDFS

~~~~
$ hadoop dfs -ls /user/username/product
~~~~

* Verify Data

~~~~
$ hadoop dfs -get /user/username/product ./result
$ cat result/part-m-*
~~~~

 

 

