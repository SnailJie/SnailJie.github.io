---
layout: blog
title: "GWT Development"
date: 2016-08-04 19:00:00
categories: java
permalink: /java-memory-monitor
author: Jaren
duoshuoid: Jaren2016080401
excerpt: Google Web Toolkit, include development and quick debugging
---

* Table of contents
{:toc}


Objective: 

GWT(Google Web Toolkit) is a web develop tool that can be used to develop Ajax web project by JAVA. 

This blog's description is based on [Teiid web console](https://github.com/teiid/teiid-web-console), which is developed by GWT. So you can download teiid web console to debugging or extension.

## Development


GWT is oriented to JAVA developer. You can develop Ajax web project like JSwing. But as for my experience, like coin has two side, GWT is not perfect. 

Although Java developer can quick develop a web sit by GWT, but because all of web related files are auto generate by GWT, if you want to make some small modifies, it can be not convenient as web development by HTML,JS,etc.

## Debug

### configure

 Modify *\*.gwt.xml* for Super Dev Mode.

~~~~
<module rename-to="app">
        <add-linker name="xsiframe"/> 
</module>
~~~~

### Compile 

~~~~
$ cd ${project}
$ mvn -Pdev clean install 
$ cd app
$ mvn package -Peapdev
~~~~

### Deploy

Find the generated package, and deploy it to server  

~~~
$ cd ${teiid-web-console)/app/target
$ cp teiid-console-app-***-resources.jar $TeiidServer_HOME/modules/system/layers/dv/org/jboss/as/console/main/
$ vi $TeiidServer_HOME/modules/system/layers/dv/org/jboss/as/console/main/module.xml        //deploy to server
~~~

Modify the value of  resource-root to teiid-console-app-***-resources.jar

### Run

* GWT Code Server
~~~~
    $ cd cd ${teiid-web-console)/app
    $ mvn gwt:run-codeserver -Peapdev  
~~~~

>The server is ready when you can see *[INFO] The code server is ready at http://127.0.0.1:9876/* in terminal.

* Teiid Server

`./bin/standalone.sh`

### Debug

* open your **Chrome** browser and go to http://localhost:9876/
* drag and drop *Dev Mode On* button to your bookmarks panel
* login to http://localhost:9990/console/
* click "Dev Mode On" on bookmark
* click "Compile" button
* open developer debugger (in Chrome CTRL + Shift + I)
* go to Sources tab
* CTRL + P to search for a file you want to debug
* set a breakpoint

 
  











	
 