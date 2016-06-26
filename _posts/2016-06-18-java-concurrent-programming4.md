---
layout: blog
title:  "Safe Collection  "
date:   2016-06-20 23:00:00
categories: concurrent
permalink: /java-concurrent-programming4
author: Jaren
duoshuoid: Jaren2016062001
excerpt: java线程安全的容器类
---

* Table of contents
{:toc}





## 四、线程安全的容器类
Java编码中，我们经常需要用到容器来编程。在并发环境下，Java提供一些已有容器能够支持并发。

### 1.Map
![Map]({{ site.baseurl }}/assets/blog/Collection-map.png)
 
 
在Map类中，提供两种线程安全容器。
 
* java.util.Hashtable

Hashtable和HashMap类似，都是散列表，存储键值对映射。主要区别在于Hashtable是线程安全的。当我们查看Hashtable源码的时候，可以看到Hashtable的方法都是通过synchronized来进行方法层次的同步，以达到线程安全的作用。

* java.util.concurrent.ConcurrentHashMap

ConcurrentHashMap是性能更好的散列表。在兼顾线程安全的同时，相对于Hashtable，在效率上有很大的提高。我们可以猜想，Hashtable的线程安全实现是对方法进行synchronized，很明显可以通过其他并发方式，如ReentrantLock进行优化。而ConcurrentHashMap正是采用了ReentrantLock。运用锁分离技术，即在代码块上加锁，而不是方法上加。同时ConcurrentHashMap的一个特色是允许多个修改并发操作。这就有意思了，我们知道一般写都是互斥的，为什么这个还能多个同时写呢？那是因为ConcurrentHashMap采用了内部使用段机制，将ConcurrentHashMap分成了很多小段。只要不在一个小段上写就可以并发写。

### 2. Collection

![Collection]({{ site.baseurl }}/assets/blog/Collection-collection.png)

Collection部分主要是运用的CopyOnWrite机制，即写时复制机制。从字面上就能理解什么意思，就是当我们往一个容器里添加元素的时候，先对这个容器进行一次复制，对副本进行写操作。写操作结束后，将原容器的引用指向新副本容器，就完成了写的刷新。

从它的实现原理，我们可以看出这种机制是存在缺点的。

 1.内存占用：毫无疑问，每次写时需要首先复制一遍原容器，假如复制了很多，或者本身原容器就比较大，那么肯定会占用很多内存。可以采用压缩容器中的元素来防止内存消耗过大。

 2.数据一致性问题：当我们在副本中进行写操组时，只能在最终结束后使数据同步，不能实时同步

可以看到，这种机制适用于**读操作多，写操作少**的应用场景。

* java.util.concurrent.CopyOnWriteArrayList

	Collection类的线程安全容器主要都是利用的ReentrantLock实现的线程安全，CopyOnWriteArrayList也不例外。在并发写的时候，需要获取lock。读的时候不需要进行lock

* java.util.concurrent.CopyOnWriteArraySet

	CopyOnWriteArraySet的实现就是基于CopyOnWriteArrayList实现的，采用的装饰器进行实现。二者的区别和List和Set的区别一样。

* Vector

	一般我们都不用Vector了，不过它确实也是线程安全的。相对于其他容器，能够提供随机访问功能。


### 3.StringBuffer和StringBuilder

我们知道，String在进行+操作的时候，原生的String会重新新建一个String对象来完成字符串拼接，明显这种操作多了的话会加重服务器负担。因此我们需要的时候就会用StringBuffer和StringBuilder。这二者有什么区别呢？

**StringBuffer**是线程安全的，StringBuilder不是。从StringBuffer的源码可以看到，它采用的是对方法进行synchronized实现的同步。但是加了同步机制，肯定会对性能有一定影响。

> 高并发情况下，对数据安全有需求，则用StringBuffer，否则用StringBuilder

