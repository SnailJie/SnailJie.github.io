---
layout: blog
title:  "BlockingQueue"
date:   2016-06-26 14:00:00
categories: concurrent
permalink: /java-concurrent-programming5
author: Jaren
duoshuoid: Jaren2016061901
excerpt: Java多线程之间通过线程阀进行交互，总结一下阻塞队列BlockingQueue，同时介绍几种同步计数器
---

* Table of contents
{:toc}





## 一、线程阀
 线程阀是线程之间相互制约和交互的机制.阻塞队列BlockingQueue的主要应用场景为生产者\消费者场景中。当队列为空时，消费者线程需要等待队列为非空。当队列满时，生产者线程需要等待队列可用。
 BlockingQueue为一个接口，有多种不同的类实现了该接口，提供具有各种特性的阻塞队列。
 
  ![JMM]({{ site.baseurl }}/assets/blog/BlockQueue.png)
 
### 1. ArrayBlockingQueue

ArrayVlockingQueue的实现是基于数组的，因此提供的是有界阻塞队列。在队列中进行FIFO排序，按照先生产的先放入先消费。

对元素是FIFO，但是对于等待的生产者或者消费者则提供可选公平性，可以构造FIFO线程访问。同时也会降低吞吐量。

**Demo**

~~~
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;

public class test{
    public static void main(String[] args) throws Exception {
        //建立ArrayBlockingQueue等待队列
    	final BlockingQueue<String> bg = new ArrayBlockingQueue<String>(16);
    	for(int i=0;i<4;i++)
    	{
    		new Thread(new Runnable() {
				
				public void run() {
					// TODO Auto-generated method stub
					while(true)
					{
						try{
							String log = (String) bg.take();
							parseLog(log);
						}
						catch (Exception e) {
							// TODO: handle exception
						}
					}
				}
			}).start();
    	}
    	//放入元素，供消费者消费
    	for(int i=0;i<16;i++)
    	{
    		String log=(i+1)+ "--->";
    		bg.put(log);
    	}
    }
    
    public static void parseLog(String log)
    {
    	System.out.println(log+System.currentTimeMillis());
    	try {
			Thread.sleep(1000);
		} catch (Exception e) {
			// TODO: handle exception
		}
    }
}
~~~

### 2. LinkedBlockingQueue

LinkedBlockingQueue是基于链表的阻塞队列。与基于数组的一个比较大的区别，是这种的并发性能更高，对生产者和消费者分别采用独立的锁来控制数据同步，而基于数组的则是生产者和消费者都是同一个锁。也就是说在高并发环境下，生产者和消费者可以并行操作队列中的数据。当然，也遵循当队列满时，生产者会被阻塞。

LinkedBlockingQueue在构建时也需要指定缓存容量。否则当生产者速度快于消费者时，会耗尽内存。

Demo和ArrayBlockingQueue一样，只是换一下LinkedBlockingQueue。

~~~
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.LinkedBlockingQueue;

public class test{
    public static void main(String[] args) throws Exception {
        //建立ArrayBlockingQueue等待队列
    	final BlockingQueue<String> bg = new LinkedBlockingQueue<String>(16);
    	for(int i=0;i<4;i++)
    	{
    		new Thread(new Runnable() {
				
				public void run() {
					// TODO Auto-generated method stub
					while(true)
					{
						try{
							String log = (String) bg.take();
							parseLog(log);
						}
						catch (Exception e) {
							// TODO: handle exception
						}
					}
				}
			}).start();
    	}
    	
    	for(int i=0;i<16;i++)
    	{
    		String log=(i+1)+ "--->";
    		bg.put(log);
    	}
    }
    
    public static void parseLog(String log)
    {
    	System.out.println(log+System.currentTimeMillis());
    	try {
			Thread.sleep(1000);
		} catch (Exception e) {
			// TODO: handle exception
		}
    }
}
~~~


### 3.PriorityBlockingQueue

优先级阻塞队列，支持优先级排序。在构建对象时需要传入优先级对象。需要注意的是，PriorityBlockingQueue**不能指定缓存容量**，同时也不对生产者进行阻塞。也就是说生产者的速度不能快于消费者。

### 4.DelayQueue
延时队列，提供延时获取元素机制，基于优先级队列实现。DelayQueue的主要应用场景为可以进行定时任务调度，同时可以进行缓存系统的时效设定。放入队列中的元素必须实现Delayed接口和Comparable接口，在创建放入队列中的元素的时候就需要指定改元素放入多久后可以被消费。因此元素需要自己实现特殊的元素类。

**Demo**

~~~
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Delayed;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

public class test{

	
    public static void main(String[] args) throws Exception {
        //建立ArrayBlockingQueue等待队列
    	final DelayQueue<Student> bq = new DelayQueue<Student>();
    	for(int i=0;i<5;i++)
    	{
    		Student student  = new Student("jaren", Math.round(Math.random()*10+i));
    		bq.put(student);
    	}
    	System.out.println("bq.peek()" + bq.peek().getname()); 
    	
    	 
    }
    
    
}


public class Student implements Delayed{

	private String name;
	private long submittime;
	
	public String getname()
	{
		return this.name;
	}
	
	public Student(String name,long submittime)
	{
		this.name=name;
		this.submittime=submittime;
	}
	public int compareTo(Delayed arg0) {
		// TODO Auto-generated method stub
		Student that=(Student)arg0;
		return submittime>that.submittime?1:0;
	}

	public long getDelay(TimeUnit arg0) {
		// TODO Auto-generated method stub
		return 100;
	}
	
}
~~~


### 5.SynchronousQueue

同步队列SynchronousQueue，不存储元素。SynchronousQueue的作用就相当于一个传球者，只是把一个元素中转一下。其实可以把SynchronousQueue相像成容量为1的阻塞队列。当生产者生产了数据后，直接转给消费者，本身不存储元素。

SynchronousQueue提供两种使用模式，一种公平模式一种非公平模式。公平模式是对生产者和消费者进行FIFO进行阻塞，非公平模式为LIFO。

**Demo**

~~~
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Delayed;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.Semaphore;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.TimeUnit;

public class test{

	public static void main(String[] args) throws Exception {
		
		System.out.println("begin"+ (System.currentTimeMillis()/1000));
		
        // 定义SynchronousQueue
    	final SynchronousQueue<String> sq = new SynchronousQueue<String>();
    	//定义数量为1的信号量，用作互斥锁
    	final Semaphore sem = new Semaphore(1);
    	
    	for(int i=0;i<10;i++)
    	{
    		 new Thread(new Runnable() {
				
				public void run() {
					// TODO Auto-generated method stub
					try {
						sem.acquire();
						String input = sq.take();
						String output = TestDo.dosome(input);
						System.out.println("Consumer: "+Thread.currentThread().getName()+":"+output);
						sem.release();
					} catch (Exception e) {
						// TODO: handle exception
					}
				}
			}).start();
    	}
    	
    	for(int i = 0;i<10;i++)
    	{
    		String input = i+"";
    		try {
				sq.put(input);
			} catch (Exception e) {
				// TODO: handle exception
			}
    	}
    	 
    }
    
}
	class TestDo{
		public static String dosome(String input)
		{
			try {
				Thread.sleep(1000);
			} catch (Exception e) {
				// TODO: handle exception
			}
			String output = input+":"+(System.currentTimeMillis()/1000);
			return output;
		}
	}
~~~

可以看出，是生产一个消费一个。

### 6.LinkedBlockingDeque

LinkedBlockingDeque是一个双向阻塞链表队列，可以分别操作队头和队尾的元素。因此在多线程情况下竞争就会减少一半。操作上和LinkedBlockingQueue类似。

### 7.LinkedTransferQueue

LinkedTransferQueue是基于链表的无界传输阻塞队列。LinkedTransferQueue是TransferQueue的实现类。TransferQueue是继承BlockingQueue。LinkedTransferQueue混合了很多高级特性，主要的思想是采用双重数据结构(dual data structures),即每个方法的操作步骤都为：保留，完成。当消费者发现队列为空，产生一个为空的元素放入队列进行占位。当生产者生产时，发现有为空的元素，则对其进行补充，消费者就能取出。

## 二、同步计数器

同步计数器的主要作用在于可以对多线程的工作流程进行控制，可以控制多个线程之间的合作。比如实现几个合作线程都运行结束后再执行下一个步骤。

### 1.CountDownLatch

CountDownLatch作为同步辅助类，在完成一组正在其他线程中执行的操作前，允许一个或者多个线程等待。内部有一个计数器，当计数器为0时进行下一阶段执行。典型的应用场景为多线程下载资源，都下载结束后才算完整下载下来资源。或者多线程上传资源。

### 2.Semaphore


Semaphore为信号量机制，维护一个许可集合，是一个排队机制，允许集合范围数量内的线程访问。使用场景一般为排队场景、资源有限的房间等等，用于线程池、连接池等等方面。

### CyclicBarrier


CyclicBarrier是一个比较实用的辅助类，允许一组线程相互等待，直到到达一个公共点，然后所有的这些线程才继续往下执行。然后可以再一起到一个点，再一起继续往下执行。一般使用场景比如说，我们需要统计全国的某个数据，可以利用多个线程去统计每个省的，每个省里面可以用多个线程统计各个市的。

