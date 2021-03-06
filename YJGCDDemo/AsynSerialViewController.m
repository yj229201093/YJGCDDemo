//
//  AsynSerialViewController.m
//  YJGCDDemo
//
//  Created by GongHui_YJ on 16/8/23.
//  Copyright © 2016年 YangJian. All rights reserved.
//

#import "AsynSerialViewController.h"
#define ROW_COUNT 5
#define COLUMN_COUNT 3
#define ROW_HEIGHT 100
#define ROW_WIDTH ROW_HEIGHT
#define CELL_SPACING 10

@interface AsynSerialViewController (){
    NSMutableArray *_imageViews;
    NSMutableArray *_imageNames;
}

@end

@implementation AsynSerialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.translucent = NO;
    [self layoutUI];
    // Do any additional setup after loading the view.
}

/**
 *  UI
 */
-(void)layoutUI{
    //创建多个图片控件用于显示图片
    _imageViews=[NSMutableArray array];
    for (int r=0; r<ROW_COUNT; r++) {
        for (int c=0; c<COLUMN_COUNT; c++) {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(c*ROW_WIDTH+(c*CELL_SPACING), r*ROW_HEIGHT+(r*CELL_SPACING                           ), ROW_WIDTH, ROW_HEIGHT)];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            //            imageView.backgroundColor=[UIColor redColor];
            [self.view addSubview:imageView];
            [_imageViews addObject:imageView];

        }
    }

    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(50, 400, 220, 25);
    [button setTitle:@"加载图片" forState:UIControlStateNormal];
    //添加方法
    [button addTarget:self action:@selector(loadImageWithMultiThread) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    //创建图片链接
    _imageNames=[NSMutableArray array];
    for (int i=0; i<ROW_COUNT*COLUMN_COUNT; i++) {
        [_imageNames addObject:[NSString stringWithFormat:@"http://atth.eduu.com/album/201203/12/1475134_1331559643qMzc.jpg"]];
    }
    
}

#pragma mark 将图片显示到界面
-(void)updateImageWithData:(NSData *)data andIndex:(int )index{
    UIImage *image=[UIImage imageWithData:data];
    UIImageView *imageView= _imageViews[index];
    imageView.image=image;
}

#pragma mark 请求图片数据
-(NSData *)requestData:(int )index{
    NSURL *url=[NSURL URLWithString:_imageNames[index]];
    NSData *data=[NSData dataWithContentsOfURL:url];

    return data;
}


#pragma mark - 加载图片
- (void)loadImage:(NSNumber *)index {
    NSLog(@"线程=== %@", [NSThread currentThread]);
    int i = [index intValue];
    //请求数据
    NSData *data = [self requestData:i];

    // 更新UI界面 此处调用了GCD主线程队列的方法
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [self updateImageWithData:data andIndex:i];
    });

}


/**
 *  多线程下载图片
 */
- (void)loadImageWithMultiThread{
    int count = ROW_COUNT *COLUMN_COUNT;
    /**
     *  创建一个串行队列
     *
     *  @param "AsynSerial"          队列名称
     *  @param DISPATCH_QUEUE_SERIAL 队列类型(串行队列)  DISPATCH_QUEUE_CONCURRENT(并行队列) 如果为NULL 默认就是 串行队列
     *
     *  @return 队列
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("AsynSerial", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < count; i++) {
        // 异步执行队列任务
        dispatch_async(serialQueue, ^{
            [self loadImage:[NSNumber numberWithInt:i]];
        });
    }

    // 非ARC环境要释放
//    dispatch_release(serialQueue);
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
