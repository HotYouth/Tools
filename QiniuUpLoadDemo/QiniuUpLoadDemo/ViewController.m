//
//  ViewController.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "ViewController.h"
#import "DCCameraVC.h"
#import "AlbumImgViewController.h"

#import "DCNetWorkManager.h"


@interface ViewController ()

@property (nonatomic,strong) NSString *filePath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}




- (IBAction)cameraAction:(id)sender {
    /*
    [DCNetWorkManager requestWithType:HttpRequestTypePost withUrlString:@"" withParaments:nil jsonCacheBlock:^(id jsonCache) {
        NSLog(@"jsonCache %@",jsonCache);
    } withSuccessBlock:^(NSDictionary *responseObject) {
        NSLog(@"success %@",responseObject);
    } withFailureBlock:^(NSError *error) {
        NSLog(@"errror : %@",error);
    } progress:^(float progress) {
        NSLog(@"progress %f",progress);
    }];
    */
    
    
    
    DCCameraVC *cameraVC = [[DCCameraVC alloc]init];
    cameraVC.photoList = ^(NSArray *list) {
        NSLog(@"多张图片 %@",list);
    };
    cameraVC.solaPhoto = ^(NSString *photoPath) {
        NSLog(@"单张图片 %@",photoPath);
        self.filePath = photoPath;
    };
    cameraVC.solaVideo = ^(NSString *videoPath) {
        NSLog(@"单个视频 %@",videoPath);
        self.filePath = videoPath;
    };
    [self presentViewController:cameraVC animated:YES completion:nil];
    
}

- (IBAction)picUpLoad:(id)sender {
    NSString *token = @"4qOP-JZKNhpEZWVT-x_eEOyN0uQfuoVhOTqA_Knl:u3tC7i22NPvjbjYriQF100NCohI=:eyJzY29wZSI6ImRwdGVzdCIsImRlYWRsaW5lIjoxNDk0OTI2MzY5fQ==";
    if (self.filePath.length == 0) {
        NSLog(@"路径为空");
        return;
    }
    
//    QNUploadOption *opt = [[QNUploadOption alloc] initWithMime:@"text/plain" progressHandler:nil params:@{ @"x:foo":@"fooval" } checkCrc:YES cancellationSignal:nil];
    QNUploadOption *opt = [[QNUploadOption alloc]initWithMime:@"video/mp4" progressHandler:^(NSString *key, float percent) {
        NSLog(@"key %@ , percent %f",key,percent);
    } params:nil checkCrc:YES cancellationSignal:nil];

    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    [upManager putData:data key:@"pic" token:token
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  NSLog(@"%@", info);
                  NSLog(@"%@", resp);
              } option:opt];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
