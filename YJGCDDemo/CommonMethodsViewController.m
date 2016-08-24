//
//  CommonMethodsViewController.m
//  YJGCDDemo
//
//  Created by GongHui_YJ on 16/8/24.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "CommonMethodsViewController.h"
#define global_queue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) // 获取全局并发队列
#define main_queue dispatch_get_main_queue() // 获取主队列

@interface CommonMethodsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThree;

@end

@implementation CommonMethodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)updataImage:(UIImage *)image{
    self.imageViewOne.image = image;
    self.imageViewTwo.image = image;
    self.imageViewThree.image = image;
}

/**
 *  延迟迟早
 *
 *  @param sender
 */
- (IBAction)delayExecution:(id)sender {

    NSLog(@"打印线程----- %@", [NSThread currentThread]);
    // 延时执行方式一 使用NSObject的方法
    // 2秒后再调用self的run方法
//    [self performSelector:@selector(loadImage) withObject:nil afterDelay:2.0];

    // 延迟执行方式二 使用GCD函数
       // 在同步函数中执行
        // 注意 如果使用异步函数 dispatch_async 那么[self performSelector:@selector(loadImage) withObject:nil afterDelay:5.0]; 不会被执行
//    dispatch_queue_t queue = dispatch_queue_create("yangjian.net.cn", 0);
//    dispatch_sync(queue, ^{
//        [self performSelector:@selector(loadImage) withObject:nil afterDelay:2.0];
//    });

    // 延迟执行方式三 可以安排其线程---> 主队列
//    dispatch_queue_t queue = dispatch_get_main_queue();
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), queue, ^{
//        NSLog(@"主队列--延迟执行------%@",[NSThread currentThread]);
//        [self gcdLoadImage];
//    });

    // 延迟执行方式四 可以安排其线程---> 并发队列
    //1、获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //2、计算任务执行的时间
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
    //3、会在when这个时间点，执行queue中的这个任务
    dispatch_after(when, queue, ^{
        NSLog(@"并发队列--延迟执行 ---- %@", [NSThread currentThread]);
        [self gcdLoadImage];
    });

}

/**
 *  gcd延迟执行
 */
- (void)gcdLoadImage{
    NSLog(@"延迟执行 ---- %@", [NSThread currentThread]);
    UIImage *image = [self requestImageData:@"http://atth.eduu.com/album/201203/12/1475134_1331559643qMzc.jpg"];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self updataImage:image];
    });

    // 打印结果 延迟执行 在主线程执行
    /**
     2016-08-24 15:27:37.918 YJGCDDemo[2283:78552] 打印线程----- <NSThread: 0x7fc751604c10>{number = 1, name = main}
     2016-08-24 15:27:42.919 YJGCDDemo[2283:78552] 主队列--延迟执行------<NSThread: 0x7fc751604c10>{number = 1, name = main}
     2016-08-24 15:27:42.919 YJGCDDemo[2283:78552] 延迟执行 ---- <NSThread: 0x7fc751604c10>{number = 1, name = main}
     */


    // 打印结果 延迟执行 并发队列
    /**
     2016-08-24 15:33:22.318 YJGCDDemo[2298:80469] 打印线程----- <NSThread: 0x7fc7a26025b0>{number = 1, name = main}
     2016-08-24 15:33:27.319 YJGCDDemo[2298:80564] 并发队列--延迟执行 ---- <NSThread: 0x7fc7a24845e0>{number = 2, name = (null)}
     2016-08-24 15:33:27.319 YJGCDDemo[2298:80564] 延迟执行 ---- <NSThread: 0x7fc7a24845e0>{number = 2, name = (null)}

     */

    // 小结: 如果队列是主队列，那么就在主线程执行，如果队列是并发队列，那么会新开启一个线程，在子线程中执行。
}


/**
 *  延迟执行方法
 */
- (void)loadImage{
    NSLog(@"延迟执行 ---- %@", [NSThread currentThread]);
    UIImage *image = [self requestImageData:@"http://atth.eduu.com/album/201203/12/1475134_1331559643qMzc.jpg"];
    // 回到主线程刷新UI
    [self performSelectorOnMainThread:@selector(updataImage:) withObject:image waitUntilDone:YES];

    // 打印结果 延迟了2秒 都在主线程执行
    /**
     2016-08-24 15:03:24.850 YJGCDDemo[2192:68387] 打印线程----- <NSThread: 0x7fb71ae02f60>{number = 1, name = main}
     2016-08-24 15:03:26.851 YJGCDDemo[2192:68387] 延迟执行 ---- <NSThread: 0x7fb71ae02f60>{number = 1, name = main}
     */
}



/**
 *  合并图片
 *
 *  @param sender
 */
- (IBAction)mergeImage:(id)sender {
    [self mergeImage];
//    [self groupMergeImage];
}

/**
 *  合并图片
 */
- (void)mergeImage{

//    // 获取全局并发队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//
//    // 获取主队列
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();


    dispatch_async(global_queue, ^{
        // 下载图片1
        UIImage *image1 = [self requestImageData:@"http://h.hiphotos.baidu.com/image/pic/item/dc54564e9258d109a4d1165ad558ccbf6c814d23.jpg"];
        NSLog(@"图片1下载完成----%@", [NSThread currentThread]);

        UIImage *image2 = [self requestImageData:@"http://5.26923.com/download/pic/000/335/06efd7b7d40328f1470d4fd99a214243.jpg"];

        NSLog(@"图片2下载完成----%@", [NSThread currentThread]);

        // 回到主线程显示图片
        dispatch_async(main_queue, ^{
            NSLog(@"显示图片---%@", [NSThread currentThread]);
            self.imageViewOne.image = image1;
            self.imageViewTwo.image = image2;

            // 合并两张图片
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, 0.0);
            [image1 drawAsPatternInRect:CGRectMake(0, 0, 100, 200)];
            [image2 drawAsPatternInRect:CGRectMake(100, 0, 100, 200)];
            self.imageViewThree.image = UIGraphicsGetImageFromCurrentImageContext();
            // 关闭上下文
            UIGraphicsEndImageContext();

            NSLog(@"图片合并完成----%@", [NSThread currentThread]);

        });
    });

    // 打印结果 需要等图片1下载完 在下载图片2 再回到主线程
    /**
     2016-08-24 16:58:40.123 YJGCDDemo[3480:125975] 图片1下载完成----<NSThread: 0x7ff65acd85f0>{number = 3, name = (null)}
     2016-08-24 16:58:40.319 YJGCDDemo[3480:125975] 图片2下载完成----<NSThread: 0x7ff65acd85f0>{number = 3, name = (null)}
     2016-08-24 16:58:40.319 YJGCDDemo[3480:125910] 显示图片---<NSThread: 0x7ff65ad00dd0>{number = 1, name = main}
     2016-08-24 16:58:40.335 YJGCDDemo[3480:125910] 图片合并完成----<NSThread: 0x7ff65ad00dd0>{number = 1, name = main}
     */
    // 效率不高 需要等图片1，图片2都下载完了后才合并
    // 优化 使用队列组可以让图片1 图片2的下载任务同事进行，且当两个下载任务都完成的时候回到主线程进行显示。


}

/**
 *  使用队列组解决
 */
- (void)groupMergeImage{
    //步骤
    //  1、创建一个队列组
    //  2、开启一个任务下载图片1
    //  3、开启一个任务下载图片2
    //  同时执行下载图片1  和 下载图片2操作
    //  4、等group中的所有任务都执行完毕，再回到主线程执行其他操作

    // 1、创建一个队列租
    dispatch_group_t group = dispatch_group_create();

    // 2、开启一个任务下载图片1
    __block UIImage *image1 = nil;
    dispatch_group_async(group, global_queue, ^{
        image1 = [self requestImageData:@"http://h.hiphotos.baidu.com/image/pic/item/dc54564e9258d109a4d1165ad558ccbf6c814d23.jpg"];
        NSLog(@"图片1下载完成--- %@", [NSThread currentThread]);
    });

    // 3、开启一个任务下载图片2
    __block UIImage *image2 = nil;
    dispatch_group_async(group, global_queue, ^{
        image2 = [self requestImageData:@"http://5.26923.com/download/pic/000/335/06efd7b7d40328f1470d4fd99a214243.jpg"];
        NSLog(@"图片2下载完成--- %@", [NSThread currentThread]);
    });

    // 同时执行下载图片1\下载图片2操作

    // 4、等group重的所有任务都执行完毕，再回到主线程执行其他操作
    dispatch_group_notify(group, main_queue, ^{
        NSLog(@"显示图 --- %@", [NSThread currentThread]);
        self.imageViewOne.image = image1;
        self.imageViewTwo.image = image2;

        // 合并两张图片
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, 0.0);
        [image1 drawAsPatternInRect:CGRectMake(0, 0, 100, 200)];
        [image2 drawAsPatternInRect:CGRectMake(100, 0, 100, 200)];
        self.imageViewThree.image = UIGraphicsGetImageFromCurrentImageContext();
        // 关闭上下文
        UIGraphicsEndImageContext();

        NSLog(@"图片合并完成 --- %@", [NSThread currentThread]);
    });


    // 同时开启两个线程 分别下载图片 会比上面的效率高一点
    /**
     2016-08-24 16:58:03.785 YJGCDDemo[3467:125346] 图片1下载完成--- <NSThread: 0x7f8d13cc61c0>{number = 3, name = (null)}
     2016-08-24 16:58:03.978 YJGCDDemo[3467:125349] 图片2下载完成--- <NSThread: 0x7f8d13ece620>{number = 4, name = (null)}
     2016-08-24 16:58:03.978 YJGCDDemo[3467:125303] 显示图 --- <NSThread: 0x7f8d13e052b0>{number = 1, name = main}
     2016-08-24 16:58:03.995 YJGCDDemo[3467:125303] 图片合并完成 --- <NSThread: 0x7f8d13e052b0>{number = 1, name = main}

     */

}


/**
 *  从网络上下载图片
 *
 *  @param urlStr 图片Url
 *
 *  @return UImage
 */
- (UIImage *)requestImageData:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}



/**
 1、后台运行
 2、主线程执行
 3、一次性执行
 4、延迟2秒执行
 5、执行某个代码片段N次
 6、队列组的使用
 */

// 下载两张照片完后，合并照片。


/**
 *  后台执行
 */
- (void)backgrountExecution{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // something
    });
}

/**
 *  主线程执行
 */
- (void)mainThreadExecution{
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
    });
}

/**
 *  一次性执行
 */
- (void)onceExecution{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // code to be execution once
        NSLog(@"改行代码只执行一次");
    });
}

/**
 *  延迟执行
 */
- (void)delayExecution{

    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        // code to be execution on the main queue after delay
    });
}

- (void)applyExecution{

    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(4, globalQueue, ^(size_t index) {
        // 执行4次
    });
}

/**
 *  自定义dispatch_queue_t
 */
- (void)customDispatch_queue_t{
    dispatch_queue_t urls_queue = dispatch_queue_create("yangjian.net.cn", DISPATCH_QUEUE_SERIAL);
    dispatch_async(urls_queue, ^{
        // your code
    });
}

/**
 *  混合
 */
- (void)blend{
    // 需求
    //1  分别异步执行2个耗时的操作
    //2  等两个异步操作都执行完毕后，再回到主线程执行操作

//   如果想要快速高效地实现上述需求，可以考虑用队列组

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 并发执行的线程一
    });

    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 并发执行的线程二
    });

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        // 等前面的异步操作都执行完毕后，回到主线程
    });
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
