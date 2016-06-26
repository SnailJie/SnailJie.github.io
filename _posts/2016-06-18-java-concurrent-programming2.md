---
layout: blog
title:  "Java Concurrent Programming2: Thread "
date:   2016-06-18 17:00:00
categories: concurrent
permalink: /java-concurrent-programming2
author: Jaren
duoshuoid: Jaren2016061802
excerpt: Java并发编程系列2:java多线程Thread的实现方法、中断机制、生命周期、守护进程等
---

* Table of contents
{:toc}



上一部分我们学习了一些关于java并发编程的基础知识，这部分我们先学习一下Java多线程的重要知识－Thread

###	二、初识Thread
 本部分主要介绍Java Thread基础知识

##### 1. 线程的实现方法

 在进行java多线程编写时，我们知道是通过java中的Thread进行实现的。那在实现Thread时，有哪几种方法可以实现Thread呢？

* 继承Thread父类
   
~~~
   public class myThread extends Thread{
   	public void run(){    //覆盖run方法
   		super.run();
   	}
   }
~~~
   
   启动
   
~~~
    myThread thread = new myThread();
    thread.start();
~~~
   
* 实现Runnable接口

~~~
public class myThread implements Runnable{
        public void run() {   //实现run方法
            //业务逻辑
        }
    }
~~~
	
   启动
   
~~~
    myThread thread = new myThread();
    new Thread(thread).start();   // 这里的调用方式不同
~~~


* 实现Callable接口
	
~~~
public class myThread implements Callable<String>{
        public void call() {
            //业务逻辑
        }
    }
~~~
    
  启动
   
~~~
	myThread thread = new myThread();
    FutureTask<String> feature = new FutureTask<String>(thread);
    new Thread(feature).start(); // 这里的调用方式不同
~~~

至于应该选择哪种实现方式，各个方式都有自己的优缺点。比如采用直接继承的方式虽然会比较方便一点，但是我们知道java不支持多继承的，如果采用继承接口的方式实现的话就能避免无法多重继承的尴尬。
 
>point: 三种实现方式各有优缺点，但是主要还是用第二种

#### 2. 线程一些特性

* 在一个Java多线程的代码中，当代码运行时，main方法本身就会开启一个线程作为主线程。其他在主线程中开启的子线程会在主线程执行开始之后开始执行。但是在结束时，主线程结束了，子线程不一定结束，可能还在继续运行。
* 线程在建立之后，会有一个***优先级***属性。在CPU调度时，优先级高的更容易被CPU运行。新建的子进程的优先级和父进程一致，在没有指定时，默认优先级为5（0-10） 

#### 3. 线程生命周期

其实说到生命周期，已经被人说滥了。不过生命周期确实是很重要需要了解的。这里我们也需要再复习一下。
如下图所示：

![Thread Life Cycle]({{ site.baseurl }}/assets/blog/ThreadLife.png)

线程共有上图中五种生命周期：new、runnable、running、blocked、dead

* new

	当new一个Thread的时候，就新建了一个线程对象， 该线程进入新建状态，分配了内存空间，但是还没有被启动。此时还不是alive。

* runnable

	当调用start()方法时，启动了线程，进入就绪状态，此时具备运行条件，排队等待被CPU执行。此时就进入了alive状态。

* running

	调用了run()方法，线程正式开始执行。如果没其他情况（等待IO，被更高级中断……），线程会运行至结束

* blocked

	由于某些原因，需要暂停该线程，如等待IO，sleep等

* dead

	线程执行完毕或者被杀死
	
在线程的运行中，可以被其他进程或者自身中断。Thread提供两种中断机制。

* Thread.stop()

	这种方法太野蛮，强制停止线程，不安全，一般不用

* Thread.interrpt()机制

	通过线程自身，或者其他线程，可以通过interrupt()方法设置线程的中断信号，线程通过查看自己的线程中断信号是否为true，根据自己的业务逻辑进行响应处理
	
	
	
#### 4. 守护线程

Java的守护线程我觉得还是很有用的。首先看看守护线程是什么。守护线程就是在后台运行的线程。普通线程结束后，守护线程自动结束。一般main线程为守护线程，以及GC、数据库连接池等，都做成守护线程。

守护线程的实现非常简单，和普通线程的区别就是在start线程前，执行方法调用setDaemon()。That's it。是不是超级简单。

守护线程就像备胎一样，JRE（女神）根本不会管守护线程有没有，在不在，只要前台线程执行结束，就算执行完毕了。

#### 5.线程组

ThreadGroup() 线程组，运行以组的方式管理线程，对一个组进行控制。一个线程组里可以包含子线程和子线程组。最顶级是system线程组。一般在system线程组下的main线程组下面新建线程组。main方法所在的线程就在main线程组。

线程组和线程池还是有区别的。线程组的目的是为了方便对线程进行管理，线程池的作用是对线程的生命周期进行管理，达到线程重用的目的。

#### 6.线程副本ThreadLocal

线程副本是每个线程都有的独立变量副本。每个线程可以维护自己的副本，不会对其他线程造成影响（其实对这个我还不是特别理解。意思就等于线程副本是线程自己的独立本地私有变量，其他线程无法操作吗？大家对这个有知道的麻烦解惑一下）

线程副本具备在多个线程之间访问隔离，这也就是说具有很好的并发访问性质。因此在某些场景下比synchronize同步机制更加简单、安全

#### 7.线程异常处理

Java线程提供了一个很好的机制，就是在线程中发生的异常，不能抛到线程外面去处理，只能内部先解决。我们知道，异常有checked异常和unchecked异常。

* checked

	处理这类异常直接用try/catch就行

* unchecked

	这类异常需要自定义实现UncaughtexceptionHandler接口自定义处理，然后将其注册到线程上。当发生unchecked异常时就能进行处理。
	实现步骤
	
	* 1.自定义类UnchaughExceptionHandler，在里面实现自己的处理逻辑
	
	* 2.和普通线程一样进行定义
	
	* 3.在执行线程前，进行Handler注册，将其绑定到这个线程
	
	
	
~~~
public class myExceptionHandler implements Thread.UncaughtExceptionHandler{ //自定义处理逻辑
    
    @Override
    public void uncaughtException(Thread t, Throwable e) {
        
    }
}
    
    public class myThread implements Runnable{
        @Override
        public void run() {
            //具体逻辑
        }
    }
    
    public static void  main(String[] args)
    {
        myThread mythread = new myThread();
        Thread thread = new Thread(mythread);
        thread.setUncaughtExceptionHandler(new myExceptionHandler());   //注册handler
        thread.start();
    }
~~~	 