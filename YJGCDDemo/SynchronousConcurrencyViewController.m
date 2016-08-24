//
//  SynchronousConcurrencyViewController.m
//  YJGCDDemo
//
//  Created by GongHui_YJ on 16/8/23.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "SynchronousConcurrencyViewController.h"


@interface SynchronousConcurrencyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOnew;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewThree;
@end

@implementation SynchronousConcurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"同步并发队列";
}

/**
 *  刷新UI
 *
 *  @param data data
 */
- (void)updateImage:(NSData *)data index:(int)index{
    UIImage *image = [UIImage imageWithData:data];
    if (index == 1)
    {
        self.imageViewOnew.image = image;
    }
    else if (index == 2)
    {
        self.imageViewTwo.image = image;
    }
    else
    {
        self.imageViewThree.image = image;
    }

}

/**
 *  数据请求
 *
 *  @return
 */
- (NSData *)requestData{
    NSURL *url = [NSURL URLWithString:@"http://img1.3lian.com/2015/w7/90/d/5.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data;
}

/**
 *  加载图片
 *
 *  @param index
 */
- (void)loadImage:(int)index{
    NSData *data = [self requestData];

    // 回到主线程
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self updateImage:data index:index];
//        NSLog(@"回到主线程 ---- %@", [NSThread currentThread]);
    });


}

- (IBAction)download:(id)sender {

    [self asynchronousConcurrent];
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
    //    NSLog(@"用同步函数往并发队列中添加任务");
    //    NSLog(@"主线程1111 ---- %@", [NSThread currentThread]);
    //
    //    // 1.创建并发队列
    //    // 方式一 一般都使用这种方式获取
    ////    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //
    //    // 方式二 和创建串行队列一样
    //    dispatch_queue_t queue = dispatch_queue_create("syncConcurrentncy", DISPATCH_QUEUE_CONCURRENT);
    //
    //    // 2.加添任务到队列
    //    dispatch_sync(queue, ^{
    //        NSLog(@"下载图片1 ---- %@", [NSThread currentThread]);
    //        [self loadImage:1];
    //    });
    //
    //    dispatch_sync(queue, ^{
    //        NSLog(@"下载图片2 ---- %@", [NSThread currentThread]);
    //        [self loadImage:2];
    //    });
    //
    //    dispatch_sync(queue, ^{
    //        NSLog(@"下载图片3 ---- %@", [NSThread currentThread]);
    //        [self loadImage:3];
    //    });
    //
    //    NSLog(@"主线程2222 ---- %@", [NSThread currentThread]);


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
