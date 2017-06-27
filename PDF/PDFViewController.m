//
//  PDFViewController.m
//  cxd4iphone
//
//  Created by Edward on 2017/6/22.
//  Copyright © 2017年 hexy. All rights reserved.
//

#import "PDFViewController.h"
#import <QuickLook/QuickLook.h>

@interface PDFViewController ()<NSURLSessionDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource>

@property(nonatomic, strong)QLPreviewController *qlpreView;

//@property(nonatomic, strong)UIWebView *webView;

@property(nonatomic, strong)NSMutableData *data;
@property(nonatomic, assign)NSInteger totalLength;

@end

@implementation PDFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [NSMutableData data];
    
    self.title = @"借款合同";
    self.view.backgroundColor = [UIColor lightGrayColor];
//    
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kDefine.screenWidth, kDefine.screenHeight)];
//    [self.view addSubview:self.webView];
//    NSString *path1 = [[NSBundle mainBundle] pathForResource:[self myFileName] ofType:nil];
//    NSURL *url = [NSURL fileURLWithPath:path1];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
    
//    [self download];
    
    //  判断文件存不存在
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:[self myFileName]]) {
        //创建管理类NSURLSessionConfiguration
        NSURLSessionConfiguration *config =[NSURLSessionConfiguration defaultSessionConfiguration];
        
        //初始化session并制定代理
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:self.fileURL]];
        // 开始
        [task resume];

    } else {
        [self showplView];
    }
    
}
#pragma mark  ====  接收到数据调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    //允许继续响应
    completionHandler(NSURLSessionResponseAllow);
    //获取文件的总大小
    self.totalLength = response.expectedContentLength;
}


#pragma mark  ===== 接收到数据调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    //将每次接受到的数据拼接起来
    [self.data appendData:data];
    //计算当前下载的长度
    NSInteger nowlength = self.data.length;
    
    //  可以用些 三方动画
    CGFloat value = nowlength*1.0/self.totalLength;
//    [HUD showProgress:value status:@"正在加载..."];
}
#pragma mark ====  下载用到的 代理方法
#pragma mark *下载完成调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSLog(@"%@",[NSThread currentThread]);
    
    //将下载的二进制文件转成入文件
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDownLoad =  [manager createFileAtPath:[self myFileName] contents:self.data attributes:nil];
    
    if (isDownLoad) {
        
        [self showplView];
    }else{
        
//        [HUD showErrorWithStatus:@"加载失败"];
    }
}

- (NSString *)myFileName {
    // 文件名
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.fileID];
    
    return filePath;
}

- (void)showplView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.qlpreView = [[QLPreviewController alloc]init];
        
        self.qlpreView.view.frame = self.view.bounds;
        
        self.qlpreView.delegate= self;
        
        self.qlpreView.dataSource = self;
        
        [self.view addSubview:self.qlpreView.view];
        
//        [HUD dismiss];
    });
}

- (void)download {
    // 文件名
    NSString  *filename = self.fileID;
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSLog(@"文件不存在");
        
        NSURL *url = [NSURL URLWithString:self.fileURL];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //将下载后的数据存入文件(firstObject 无数据返回nil，不会导致程序崩溃)
            NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            //destPath = [destPath stringByAppendingPathComponent:@"my.zip"];
            destPath = [destPath stringByAppendingPathComponent:self.fileID];
            NSLog(@"%@",destPath);
            
            //将下载的二进制文件转成入文件
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL isDownLoad =  [manager createFileAtPath:destPath contents:data attributes:nil];
            if (isDownLoad) {
                
                NSLog(@"%@", [NSThread currentThread]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.qlpreView = [[QLPreviewController alloc]init];
                    
                    self.qlpreView.view.frame = self.view.bounds;
                    
                    self.qlpreView.delegate= self;
                    
                    self.qlpreView.dataSource = self;
                    
                    [self.view addSubview:self.qlpreView.view];
                });
                
                
            }else{
//                [HUD showErrorWithStatus:@"加载失败"];
            }
        }];
        
        [task resume];
    }else{
        NSLog(@"文件存在 ===== %@", filePath);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.qlpreView = [[QLPreviewController alloc]init];
            
            self.qlpreView.view.frame = self.view.bounds;
            
            self.qlpreView.delegate= self;
            
            self.qlpreView.dataSource = self;
            
            [self.view addSubview:self.qlpreView.view];
        });
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.qlpreView = nil;
}

#pragma mark =======  QLPreviewController  代理
#pragma mark ==== 返回文件的个数
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

#pragma mark ==== 即将要退出浏览文件时执行此方法
- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
}

#pragma mark ===== 在此代理处加载需要显示的文件
- (NSURL *)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
    //获取指定文件 路径
//    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
    
    NSURL *storeUrl = [NSURL fileURLWithPath:[self myFileName]];
    
    return storeUrl;
}

@end
