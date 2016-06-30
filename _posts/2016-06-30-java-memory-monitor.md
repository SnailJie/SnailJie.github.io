---
layout: blog
title: "Java内存模型以及线程监控"
date: 2016-06-30 19:00:00
categories: concurrent
permalink: /java-memory-monitor
author: Jaren
duoshuoid: Jaren2016063001
excerpt: 当Java多线程运行时，可通过几种工具对Java线程的执行以及状态进行监控，从而帮助优化程序
---

* Table of contents
{:toc}


## 线程池代码监控
 
 在对于线程的监控，可以通过代码编写的方法调用来取得线程的运行信息。
 
### 线程池监控
 
对于线程池的监控，JDK提供了一系列方法可以调用。需要自定义**继承ThreadPoolExecutor**类，实现**beforeExecute**,**afterExecute**,**terminated**方法，分别对任务执行前、任务执行后、线程池关闭前进行操作。在这几个方法中，我们就可以调用线程池的方法来输出线程池的情况。



* taskCount: 线程池需要执行的任务数量
* completedTaskCount: 线程池在运行过程中已完成的任务数量
* largestPoolSize: 线程池的创建过的最大线程数量
* getPoolSize : 线程池的线程数量
* getActiveCount: 获取活动的线程数

可以通过调用上面的各种属性来获取线程池的状态。

### Fork/Join监控

ForkJoin的监控不用继承，直接调用方法获取线程信息。如getPoolSize()[返回worker的数量],getParallelism()[返回池的并行的级别],getActiveThreadCount()[当前执行任务的线程数量]……等等。具体可以在网上查询提供了哪些方法。

 
## Java内存

在我们对线程进行监控，评估线程状态的时候，我们需要对JVM的内存结构进行了解，这样才能知道线程运行时到底是什么状态，对系统影响多大。

#### Java内存结构

![Memory]({{ site.baseurl }}/assets/blog/Memory.png)

从上图可以看到，JVM内存主要由程序计数器、JVM栈、本地方法栈、共享堆、方法区组成。

多线程共享部分：

* 共享堆

目的是存放对象实例，由所有线程共享，是内存中最大的一块，几乎所有的对象都在堆中分配实例内存。在堆的存储时，不需要连续存储空间，只需要逻辑连续就行。当堆的空间被用完时，会抛出OutOfMemoryError。

* 方法区

存储已经被虚拟机加载的类的信息、常量、静态变量、编译后的代码、class文件等。方法区也叫非堆（Non-Heap），在Sun HotSpot虚拟机中，将这块叫Permanent Generation永久区。


单线程私有部分：

* 程序计数器

每个线程的一块很小内存空间，用于存储自己的代码执行到哪个地方。在线程各个状态切换过程中能够保留程序执行状态。

* JVM栈

线程内部虚拟机栈，在线程创建时创建，用于存放局部变量、操作数栈、方法出口信息等。

* 本地方法栈

于JVM栈类似，区别是JVM栈是执行java服务，本地方法栈时为虚拟机调用操作系统本地方法服务的。有的虚拟机如Sun HotSpot直接将二者结合。

>Notice:总的来说，分布根据不同的JVM分法不同，但基本可以将内存分为两块：堆和栈。共享堆和私有栈。栈的生命周期和线程一致，GC主要操作的是堆部分。

#### GC

Java垃圾回收机制是Java的一个特色。在进行垃圾回收过程中，将空间划分为Young Generation, Old Generation, Permanent Generation。Permanent Generation（永久代）是方法区，一般这块不参与GC。GC主要是回收Young Generation和 Old Generation部分。


![GC]({{ site.baseurl }}/assets/blog/Memory.png)

* Young Generation:  年轻代主要存放新产生的对象，分为三个部分，主要为了生命周期短的对象尽量在年轻代

	* eden
	
	刚开始创建的对象放入该区域。当eden空间不足时，需要进行一次**MinorGC**，将对象拷贝至survior
	
	* survior（2）
	
	当survior满时，将对象拷贝至old区

* Old Generation : 存放生命周期较长对象，如缓存对象

当此部分满时，发生**MajorGC**进行回收，速度比MinorGC慢十倍以上。

除此之外，还有**FullGC**，对整个堆进行GC，速度更慢。基本主要是MajorGC。


因此我们可以看到，在发生内存溢出的时候，主要就存在三类溢出：堆溢出、栈溢出、方法区溢出。我们可以通过设置JVM参数对这三个的大小进行修改。如-Xms\-Xmx\-Xss……等等

同时，存在几种不同的JVM回收机制

* 串行收集器： 单线程收集，效率较高
* 并行收集器： 对年轻代并行回收，一般用于多线程机器
* 并发收集器： 保证GC对系统影响很小，用于实时要求较高的应用

## 可视化工具监控

###  状态监控

通过可视化工具监控，可以对线程的运行情况了解更直观。一般在安装java是，JDK会自带两种工具。

~~~
$ ./$JAVA_HOME/bin/jconsole    JConsole工具
$ ./$JAVA_HOME/bin/jmc         Java Mission Control
~~~

除此之外VisualVM、Eclipse等都可以进行监控。当然也能进行远程JVM监控，需要配置远程jmx。

### 压力测试

通过工具进行压力测试，可以评估多线程的运行情况。

* Badboy+JMeter

二者可以结合进行测试。Badboy可用于录制操作过程，生成Jmeter脚步，然后导入JMeter进行分析

* MultithreadedTC

这是一个Java库，需要编写代码。主要是用于解决多线程运行中的并发不确定问题，控制线程的不同运行顺序。











	
 