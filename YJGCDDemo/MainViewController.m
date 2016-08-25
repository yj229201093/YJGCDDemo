//
//  MainViewController.m
//  YJGCDDemo
//
//  Created by GongHui_YJ on 16/8/23.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "MainViewController.h"
#import "SynchronousSerialViewController.h"
#import "SynchronousConcurrencyViewController.h"
#import "AsynSerialViewController.h"
#import "AsynConcurrencyViewController.h"
#import "CommonMethodsViewController.h"


/**
    demo注释
    SynchronousSerialViewController： 同步串行队列
    SynchronousConcurrencyViewController： 同步并发队列
    AsynSerialViewController：异步串行队列
    AsynConcurrencyViewController： 异步并发队列
    CommonMethodsViewController：常用的方法讲解

    GCD(Grand Central Dispacth) 
    一、简介
        是基于C语言开发的一套多线程开发机制，也是目前苹果官方推荐的多线程开发方法，用起来也最简单，只是它基于C语言开发，并不像NSOperation是面向对象的开发，而是完全面向过程的。如果使用GCD，完全由系统管理线程，我们不需要编写线程代码。只需定义想要执行的任务，然后添加到适当的调度队列（dispatch_queue）.GCD会负责创建线程和调度你的任务，系统会直接提供线程管理。

    二、任务和队列
        GCD中有两个核心概念
            （1）任务：执行什么操作
            （2）队列：用来存放任务
        GCD的使用就两个步骤
            （1）定制任务
            （2）确定想做的事情
        将任务添加到队列中，GCD会自动将队列中的任务取出，放到对应的线程中执行
        提示：任务的取出遵循队列的FIFO原则：先进先出，后进后出
        
    三、执行任务
        1、GCD中有2个用来执行任务的函数
            说明：把右边的参数（任务）提交给左边的参数（队列）进行执行
            （1）用同步的方式执行任务 dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
                参数说明：
                queue：队列
                block：任务
            （2）用异步的方式执行任务 dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

        2、同步和异步的区别
            同步：在当前线程中执行 
            异步：在另一条线程中执行

    四、队列
        1、GCD的队列可以分为2大类型
            （1）并发队列（Concurrent Dispatch Queue）：可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）并发功能只有在异步（dispatch_async）函数才有效

            （2）串行队列（Serial Dispatch Queue）：让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）

        2、补充说明
            有4个术语比较容易混淆：同步、异步、并发、串行（在博客 多线程编程（-）----概念 也提到了）
            同步和异步决定了要不要开启新的线程
                同步：在当前线程中执行任务，不具备开启新线程的能力
                异步：在新的线程中执行任务，具备开启新线程的能力
            并发和串行决定了任务的执行方式
                并发：多个任务并发执行
                串行：一个任务执行完毕后，再执行下一个任务

    三、(同步/异步)串行队列和(同步/异步)并发队列开启线程的总结 （代码示例）
        说明:(1)同步函数不具备开启线程的能力，无论是什么队列都不会开启线程；异步函数具备开启线程的能力，开启几条线程有队列决定（串行队列只会开启一条新的线程，并发队列会开启多条线程）
            (2) MRC下凡是函数中，各种函数名中带有create\copy\new\retain等字眼，都需要在不需要使用这个数据的时候进行release
                ARC下GCD的数据类型不需要再作release
                CF(core Foundation)的数据在ARC环境下还是需要release
            (3) 异步函数具备开线程的能力，但不一定会开线程

        1、异步并发队列（同时开启N个线程）
            // [self asynchronousConcurrent];
        2、异步串行队列（会开启线程，但是只开启一个线程）
            // [self asynchronousSerial]
        3、同步并发队列（不会开启新的线程，并发队列失去并发的功能）
            // [self synchronousConcurrent]
        4、同步串行队列（不会开启新的线程）
            // [self synchronousSerial]

    四、常用方法 在CommonMethodsViewCotroller类
        1、后台运行
        2、主线程执行
        3、一次性执行
        4、延迟2秒执行
        5、执行某个代码片段N次
        6、队列组的使用
        7、dispatch_barrier_async

    五、代码示例 在CommonMethodsViewCotroller类
        下载两张照片完后，合并照片。


    五、线程间通信
        从子线程回到主线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 执行耗时的异步操作
            dispatch_async(dispatch_get_main_queue(), ^{
                //回到主线程，执行UI刷新操作
            });
        });

    六、Operation和GCD的对比
        优点: 不需要关心线程管理，数据同步的问题；
        区别: 1、性能：GCD更接近底层，而NSOperation则更高级抽象，所以GCD在追求性能的底层操作来说，是速度最快的。
              2、从异步操作之间的事务性，顺序行，依赖关系。GCD需要自己写更多的代码来实现，而NSOperationQueue已经内建了这些支持
              3、如果异步操作的国学更多的被交互和UI呈现出来，NSOperationQueue会是一个更好的选择。底层代码中，任务之间不太互相依赖，而需要更高的并发能力，GCD则更有优势



    七、总结
        学了两天，对gcd有一些的了解，能在项目中使用多线程，不过这边也要避免很多死锁的问题，后期有时间再整理出来。四天左右把iOS多线程的几种方法都整理了下，写了demo。也算对自己的一个小小总结。
        总结两点：
        1、线程运行方式
            dispatch_async 异步执行
            dispatch_sync 同步执行
            dispatch_delay 延迟执行
        2、处理任务对象
            dispatch_get_main_queue 主线程队列（UI线程队列）
            dispatch_get_global_queue 并发线程队列
            串行队列


 */


@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

- (void)loadImage:(int)index{

}

/**
 *  同步串行队列
 */
- (void)synchronousSerial{
    NSLog(@"用同步函数往串行队列中添加任务");
    NSLog(@"主线程111----- %@", [NSThread currentThread]);

    // 1、创建串行队列 // DISPATCH_QUEUE_SERIAL 串行队列 也可以为NULL NULL时 默认是 串行队列； DISPATCH_QUEUE_CONCURRENT 并发队列
    dispatch_queue_t queue = dispatch_queue_create("syncSerial", DISPATCH_QUEUE_SERIAL);

    // 2、添加任务到队列中执行
    dispatch_sync(queue, ^{
        // 此块代码没有任何意义，只是为了体现同步串行队列的效果， 只能执行完了 才能执行面下的，
        for (int i = 0; i < 30000; i++) {
            //
            NSLog(@"%i", i);
        }
        NSLog(@"下载图片1 ---- %@", [NSThread currentThread]);
        [self loadImage:1];
    });

    dispatch_sync(queue, ^{
        for (int i = 0; i < 30000; i++) {
            //
            NSLog(@"%i", i);
        }
        NSLog(@"下载图片2 -- %@", [NSThread currentThread]);
        [self loadImage:2];
    });

    dispatch_sync(queue, ^{
        for (int i = 0; i < 30000; i++) {
            //
            NSLog(@"%i", i);
        }
        NSLog(@"下载图片3 -- %@", [NSThread currentThread]);
        [self loadImage:3];
    });

    NSLog(@"主线程222----- %@", [NSThread currentThread]);


    // 打印结果就是同步按顺序执行。 每个任务按顺序执行，不开启线程
    /**
     2016-08-24 10:52:55.049 YJGCDDemo[43413:2986818] 用同步函数往串行队列中添加任务
     2016-08-24 10:52:55.049 YJGCDDemo[43413:2986818] 主线程111----- <NSThread: 0x7fd5dbc00dd0>{number = 1, name = main}
     2016-08-24 10:52:55.050 YJGCDDemo[43413:2986818] 下载图片1 ---- <NSThread: 0x7fd5dbc00dd0>{number = 1, name = main}
     2016-08-24 10:52:55.580 YJGCDDemo[43413:2986818] 下载图片2 -- <NSThread: 0x7fd5dbc00dd0>{number = 1, name = main}
     2016-08-24 10:52:55.616 YJGCDDemo[43413:2986818] 下载图片3 -- <NSThread: 0x7fd5dbc00dd0>{number = 1, name = main}
     2016-08-24 10:52:55.644 YJGCDDemo[43413:2986818] 主线程222----- <NSThread: 0x7fd5dbc00dd0>{number = 1, name = main}

     */
}

/**
 *  同步并发队列
 */
- (void)synchronousConcurrent{
        NSLog(@"用同步函数往并发队列中添加任务");
        NSLog(@"主线程1111 ---- %@", [NSThread currentThread]);
    
        // 1.创建并发队列
        // 方式一 一般都使用这种方式获取
    //    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
        // 方式二 和创建串行队列一样
        dispatch_queue_t queue = dispatch_queue_create("syncConcurrentncy", DISPATCH_QUEUE_CONCURRENT);
    
        // 2.加添任务到队列
        dispatch_sync(queue, ^{
            NSLog(@"下载图片1 ---- %@", [NSThread currentThread]);
            [self loadImage:1];
        });
    
        dispatch_sync(queue, ^{
            NSLog(@"下载图片2 ---- %@", [NSThread currentThread]);
            [self loadImage:2];
        });
    
        dispatch_sync(queue, ^{
            NSLog(@"下载图片3 ---- %@", [NSThread currentThread]);
            [self loadImage:3];
        });
    
        NSLog(@"主线程2222 ---- %@", [NSThread currentThread]);


    // 打印结果 和同步串行队列一样 这边并发队列效果失效，不会开启线程。
    /**
     2016-08-24 11:20:44.153 YJGCDDemo[43913:3002870] 用同步函数往并发队列中添加任务
     2016-08-24 11:20:44.154 YJGCDDemo[43913:3002870] 主线程1111 ---- <NSThread: 0x7f8742604eb0>{number = 1, name = main}
     2016-08-24 11:20:44.154 YJGCDDemo[43913:3002870] 下载图片1 ---- <NSThread: 0x7f8742604eb0>{number = 1, name = main}
     2016-08-24 11:20:44.433 YJGCDDemo[43913:3002870] 下载图片2 ---- <NSThread: 0x7f8742604eb0>{number = 1, name = main}
     2016-08-24 11:20:44.475 YJGCDDemo[43913:3002870] 下载图片3 ---- <NSThread: 0x7f8742604eb0>{number = 1, name = main}
     2016-08-24 11:20:44.508 YJGCDDemo[43913:3002870] 主线程2222 ---- <NSThread: 0x7f8742604eb0>{number = 1, name = main}

     */
}


/**
 *  异步串行队列
 */
- (void)asynchronousSerial{

    NSLog(@"用异步函数往串行队列中添加任务");
    NSLog(@"主线程1111 ---- %@", [NSThread currentThread]);

    //1. 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("asynSerial", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSLog(@"下载图片1 --- %@", [NSThread currentThread]);
        [self loadImage:1];
    });


    dispatch_async(queue, ^{
        NSLog(@"下载图片2 --- %@", [NSThread currentThread]);
        [self loadImage:2];
    });

    dispatch_async(queue, ^{
        NSLog(@"下载图片3 --- %@", [NSThread currentThread]);
        [self loadImage:3];
    });

    NSLog(@"主线程2222 ---- %@", [NSThread currentThread]);


    // 打印结果：异步串行队列，会开启一个线程，顺序执行。 看运行结果也可以看出，图片是一张下载完在下载下一张的。
    /**
     2016-08-24 12:39:14.195 YJGCDDemo[942:16507] 用异步函数往串行队列中添加任务
     2016-08-24 12:39:14.196 YJGCDDemo[942:16507] 主线程1111 ---- <NSThread: 0x7f8ed1f05f90>{number = 1, name = main}
     2016-08-24 12:39:14.196 YJGCDDemo[942:16507] 主线程2222 ---- <NSThread: 0x7f8ed1f05f90>{number = 1, name = main}
     2016-08-24 12:39:14.196 YJGCDDemo[942:16622] 下载图片1 --- <NSThread: 0x7f8ed1c43c00>{number = 2, name = (null)}
     2016-08-24 12:39:14.261 YJGCDDemo[942:16622] 下载图片2 --- <NSThread: 0x7f8ed1c43c00>{number = 2, name = (null)}
     2016-08-24 12:39:14.303 YJGCDDemo[942:16622] 下载图片3 --- <NSThread: 0x7f8ed1c43c00>{number = 2, name = (null)}

     */
}

/**
 *  异步并发队列
 */
- (void)asynchronousConcurrent{
    NSLog(@"异步函数往并发队列中添加任务");
    NSLog(@"主线程1111 ---- %@", [NSThread currentThread]);

    // 1、创建并发队列
    // 方法一 和创建串行队列一样
    //    dispatch_queue_t queue = dispatch_queue_create("asynConcurrent", DISPATCH_QUEUE_CONCURRENT);
    // 方法二 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 2、添加任务到队列
    dispatch_async(queue, ^{
        NSLog(@"下载图片1 ------ %@", [NSThread currentThread]);
        [self loadImage:1];
    });

    dispatch_async(queue, ^{
        NSLog(@"下载图片2------ %@", [NSThread currentThread]);
        [self loadImage:2];
    });

    dispatch_async(queue, ^{
        NSLog(@"下载图片3 ------ %@", [NSThread currentThread]);
        [self loadImage:3];
    });

    NSLog(@"主线程2222 ---- %@", [NSThread currentThread]);


    // 打印结果 开启多个线程，并发执行。没有先后顺序（有的话也是刚好巧合而已） 可以看number 可以看做线程值
    /**
     第一次执行
     2016-08-24 12:53:24.026 YJGCDDemo[1220:24092] 异步函数往并发队列中添加任务
     2016-08-24 12:53:24.027 YJGCDDemo[1220:24092] 主线程1111 ---- <NSThread: 0x7f81bae04b90>{number = 1, name = main}
     2016-08-24 12:53:24.027 YJGCDDemo[1220:24092] 主线程2222 ---- <NSThread: 0x7f81bae04b90>{number = 1, name = main}
     2016-08-24 12:53:24.027 YJGCDDemo[1220:24126] 下载图片1 ------ <NSThread: 0x7f81baf25e90>{number = 2, name = (null)}
     2016-08-24 12:53:24.027 YJGCDDemo[1220:24128] 下载图片2------ <NSThread: 0x7f81bacc5fe0>{number = 3, name = (null)}
     2016-08-24 12:53:24.027 YJGCDDemo[1220:24127] 下载图片3 ------ <NSThread: 0x7f81baf81ac0>{number = 4, name = (null)}

     第二次执行
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24092] 异步函数往并发队列中添加任务
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24092] 主线程1111 ---- <NSThread: 0x7f81bae04b90>{number = 1, name = main}
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24092] 主线程2222 ---- <NSThread: 0x7f81bae04b90>{number = 1, name = main}
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24126] 下载图片2------ <NSThread: 0x7f81baf25e90>{number = 2, name = (null)}
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24260] 下载图片3 ------ <NSThread: 0x7f81baf7f660>{number = 7, name = (null)}
     2016-08-24 12:53:32.427 YJGCDDemo[1220:24153] 下载图片1 ------ <NSThread: 0x7f81baf81ac0>{number = 6, name = (null)}
     
     */
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"同步串行队列";
            break;
        case 1:
            cell.textLabel.text = @"同步并发队列";
            break;
        case 2:
            cell.textLabel.text = @"异步串行队列";
            break;
        case 3:
            cell.textLabel.text = @"异步并发队列";
            break;
        case 4:
            cell.textLabel.text = @"常用方法";
            break;

        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    switch (indexPath.row) {
        case 0:
        {
            SynchronousSerialViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SynchronousSerialViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            SynchronousConcurrencyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SynchronousConcurrencyViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }            break;
        case 2:
        {
            AsynSerialViewController *vc = [[AsynSerialViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            AsynConcurrencyViewController *vc = [[AsynConcurrencyViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            CommonMethodsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CommonMethodsViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
