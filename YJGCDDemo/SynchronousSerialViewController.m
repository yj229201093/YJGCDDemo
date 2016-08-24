//
//  SynchronousSerialViewController.m
//  YJGCDDemo
//
//  Created by GongHui_YJ on 16/8/23.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "SynchronousSerialViewController.h"


@interface SynchronousSerialViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThree;

@end

@implementation SynchronousSerialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"同步串行队列";

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
        self.imageViewOne.image = image;
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
 */
- (void)loadImage:(int)index{
    NSData *data = [self requestData];
    [self updateImage:data index:index];
    // 回到主线程刷新
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_sync(mainQueue, ^{
//        [self updateImage:data index:index];
//    });
//    
}

/**
 *  下载图片
 *
 *  @param sender
 */
- (IBAction)download:(id)sender {
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
