---
layout: blog
title: "Thread Pool"
date: 2016-06-26 11:00:00
categories: se
permalink: /Thread-Pool
author: Jaren
duoshuoid: Jaren2016062701
excerpt: Thread Pool线程池在互联网项目中运用广泛，可以管理线程，提高程序效率，减少创建和销毁线程的消耗
---

* Table of contents
{:toc}


## Thread Pool线程池

在Java程序运行中，不管是什么对象，在对其的创建、管理、JVM的跟踪、销毁等等都会占用资源。在高并发的情况下，会利用多线程技术，并行多个线程。因此对于多线程的管理，重复使用，可以减少资源的消耗。

利用线程池提高处理器的吞吐量，减少处理器闲置时间，因此可以降低资源消耗，提高响应速度，防止服务器过载，因此在应用中广泛使用。

Java线程池的实现是通过java.util.concurrent.Executors。Executors是工厂类，用于创建各类型的线程池。

![Executor]({{ site.baseurl }}/assets/blog/Executor.png)

* Executor:

在Java的线程池实现中，以Executor为顶级接口，对其进行继承和扩展，是线程的执行工具

* ExecutorService

线程池的主要接口

* AbstracExecutorService

ExecutorService的实现类，实现了ExecutorService的所有方法

* ThreadPoolExector

继承至AbstracExecutorService，是ExecutorService的默认实现。一般是通过这个类来进行线程池的选择，以及自定义线程池，都是通过继承这个类来进行扩展、修改

### 已有线程池类型

如上所示，Java提供了几种现有的线程池实现，Executors继承ThreadPoolExector

* newSingleThreadExecutor单线程线程池

这个线程池里面只有一个线程，相当于串行执行。这我就不了解它存在的价值了……运行时，放入该线程池的线程会依次执行。

* newCachedThreadPool缓存池大小伸缩调节线程池

缓存池大小可根据需要伸缩调节。当调用execute时，如果有可用线程，则直接调用，否则创建一个新的线程，并且移除60s内未被使用的线程。

**Demo**

~~~
public static void main(String[] args) throws Exception {
		ExecutorService executor = Executors.newCachedThreadPool();
		for (int i = 0; i < 20; i++) {
			final int no = i;
			Runnable runnable = new Runnable() {

				public void run() {
					// TODO Auto-generated method stub
					try {
						Thread.sleep(1000L);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			};
			executor.execute(runnable);

		}

		System.out.println("Thread Main End");

	}
~~~



* newFixedThreadPool固定线程数线程池

用于创建固定线程数的线程池，可用线程数固定。当后续任务无可用线程时，将在一个无界共享队列中等候。

**Demo**

~~~
public static void main(String[] args) throws Exception {
		ExecutorService executor = Executors.newFixedThreadPool(5);
		for (int i = 0; i < 20; i++) {
			final int no = i;
			Runnable runnable = new Runnable() {

				public void run() {
					// TODO Auto-generated method stub
					try {
						Thread.sleep(1000L);
					} catch (InterruptedException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			};
			executor.execute(runnable);

		}

		System.out.println("Thread Main End");

	}
~~~

### 自定义线程池

上面说到，自定义线程池需要继承ThreadPoolExecutor，对其进行扩展。上图中可以看到ThreadPoolExecutor的几个参数。自定义线程池就是对上面那几个参数进行修改、自定义。各个参数作用如下

* int corePoolSize: 线程池大小。当没有任务时就预创建corePoolSize个线程。当任务数大于corePoolSize时，后续任务会放入缓存队列中
* int maximunPoolSize: 线程池最大线程数。线程池最大的创建线程数。超过corePoolSize，小于maximunPoolSize的线程会被释放。
* long keepAliveTime: 线程没有任务执行时最长保持多久时间终止。当线程数超过corePoolSize时，这个参数起作用。
* TimeUnit unit: keepAliveTime的时间单位
* BlockingQueue workQueue:阻塞队列，用于缓存等待执行的任务
* ThreadFactory threadFactory:线程工厂，用于创建线程。
* RejectedExecutionHandler handler:当拒绝任务时的策略

很想写个Demo，但是很晚了，改天吧