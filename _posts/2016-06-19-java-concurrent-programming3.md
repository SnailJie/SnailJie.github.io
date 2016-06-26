---
layout: blog
title:  "Java Concurrent Programming3: Thread Safe  "
date:   2016-06-19 14:00:00
categories: concurrent
permalink: /java-concurrent programming
author: Jaren
duoshuoid: Jaren2016061901
excerpt: Java并发编程系列3:java多线程Thread线程同步与互斥、锁机制
---

* Table of contents
{:toc}





## 三、Thread安全
 线程安全不是指数据本身或者数据传输中的安全，而主要是指在高并发多线程的访问过程中，多线程对数据本身的读写所造成的数据不一致、脏数据等情况的避免。

### 1. Java内存模型JMM与多线程

在Java里，JLS定义了Java的统一的内存管理模型JMM（Java Memory Model）。JMM规定JVM中有**主内存（Main Memory）**以及**工作内存（Work Memory）**。**主内存**就是我们所说的堆内存，存放类的实例、静态数据等，由多线程共享。**工作内存**是各个线程自己的“小金库”，存放自己从主内存拷贝过来的变量以及局部变量。既然是小金库，那么就只能自己访问，其他线程无法访问。如果线程之间要相互通信，就只能用主内存中的共享变量进行通信。

 ![JMM]({{ site.baseurl }}/assets/blog/JMM.png)
 
既然存在这样的内存模型，那么在具体的多线程读写中，会发生什么问题呢？

* 可见性问题

	因为在线程对变量进行读写时，首先从主内存中将数据复制到自己的工作内存中，在自己的工作内存中进行写操作后，在刷新回主内存。由于主内存是共享的，工作内存是私有的，因此在这二者之间就存在着隔离，就会导致其他线程的读写不一致。
	
	为了解决可见性问题，保证happen-before语义,有很多种方法，比如用volatile，可保证可见性以及阻止局部重排序。以及通过锁机制保证可见性、原子操作等等。

* 时序问题

	我们知道当线程需要一个变量时，先从主内存中获取一个变量，复制到工作内存中进行读写。当这个线程再次需要用到这个变量时，可以从主内存中复制新的过来，或者直接使用工作内存中的变量。假如多个线程同时需要读写这个变量，那这个过程就会存在时序问题。
	
在多线程的编写中，我们需要保证线程安全，即每次多线程执行结束后操作的结果都是一样的。因此需要用到Java中的同步互斥机制来确保线程安全。

### 2. synchronized

synchronized是保证线程同步的关键字。通过使用这个关键字，可以使得被标记的代码在任何时候最多允许一个线程执行这段代码。

一般有两种用法：

~~~
法一：

public synchronized void method(){
	…………
}

法二：

public int method(){
	synchronized(this){
		…………
	}
}
~~~

这两种方法都能进行控制。当然各有优缺点。由于法一是直接对整个方法进行同步，在进入方法时需要再分配资源，性能会低于法二。

对于法二，语法为synchronized (object){……}。其中object可以是任意其他对象、this。可以用

~~~
private byte[] lock = new byte [1];
public void method() {
	synchronized (lock){
	……
	}
}
~~~

这种方式比较常用，能减少对锁的新建、释放所需要的资源，提高性能。但是需要**注意**的是，在一个class中，所有需要同步的方法都用这个lock对象，这样才能保证线程安全。

>当一个线程访问一个object的一个synchronized同步块时，它将获得整个对象的所有加了同步的方法锁，也就是说即使它没有访问这个对象里其他的同步块，但是其他线程也无法访问那些没被访问的同步块。换句话说，就是对这个对象“包场”了。

### 3. Lock and ReentrantLock

synchronized关键字提供了隐式锁机制来保证线程同步。当然，java中提供显示锁Lock，可手动进行锁的请求与释放。与synchronized相比，显示锁可操作性更强，功能更强。

> Lock相对于synchronized，区别在于Lock是对代码块进行加锁，而synchronized是对对象进行操作，保证对象的互斥。

这里对几种常用锁进行对比

#### ReentrantLock

这个锁是在工作中用量很大的。主要的好处是更具有伸缩性，当很多线程竞争相同锁时，能够提供相对synchronized更高的吞吐量。主要的缺点就是需要手动释放锁。当然这个是无法避免的。

~~~
private final ReentrantLock lock = new ReentrantLock();
public void method() {
	lock.lock();
	try{
	……
	}finally{
		lock.unlock();
	}
}
~~~

#### ReadWriteLock and ReentrantReadWriteLock

ReadWriteLock接口，主要用在对于读操作比较多，写操作比较少的情况。相对于ReentrantLock对读写都需要进行互斥保证，ReadWriteLock对读写进行了优化。

* 多线程可同时读
* 单线程写
* 有读是不能写，有写时不能读



 ReentrantReadWriteLock是其实现类，实现读锁、写锁的分离使用，能适用更复杂的应用场景
 
~~~
 private ReentrantReadWriteLock rwLock = new ReentrantReadWriteLock();    //创建锁对象
 private Lock readLock = rwLock.readLock();
 private Lock writeLock = rwLock.writeLock();
    
 public void write(){
        writeLock.lock();
        ……
        writeLock.unlock();
    }
  public int read(){
        readLock.lock();
        ……
        readLock.unlock();
    }
~~~

#### StampedLock

StampedLock主要是为了实现悲观锁和乐观锁机制。一般利用StampedLock是为了用作开发线程安全组件的内部工具，吞吐量相对于Lock有很大的改进。但是这个锁有点小复杂，我还对这个还不是很熟，就不细讲了。在一般的应用场景中更主要是运用ReentrantLock系列就足够了。


### 4. volatile修饰变量

volatile关键字的作用是告诉编译器，这个被修饰的变量是容易变化的，因此不对这个变量使用缓存等优化机制。每次使用时直接从主存中进行读取。

可以看出volatile提供内存可见性，没有提供原子性。主要可以用在一个变量会有多个线程读，一个线程写的场景下。

### 5.原子操作atomic

在高并发的环境下非常适合用原子操作。原子操作即是一个操作要么完全执行，要么完全不执行。在Java中提高了多种原子类可供使用，如AtomicInteger\AtomicLong\AtomicBoolean\AtomicReference等等，基本各类的操作大同小异，提供读、写、赋值、自增、自减等等操作。

原子操作的实现原理为CPU的CAS（比较交换），由于不是我们的关注重点，也就不说了，只需要知道怎么用就行

>point: 在并发多线程编程中，运用同步锁机制的主要是用于单例模式（Singleton）。在编写时，不仅要考虑线程安全，同时也要尽量提高并发性能。

