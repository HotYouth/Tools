//
//  DCCameraVC.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCCameraVC : UIViewController

@property (nonatomic,copy)void (^photoList)(NSArray *list); //多张图片路径

@property (nonatomic,copy)void (^solaPhoto)(NSString *photoPath); //单张图片路径

@property (nonatomic,copy)void (^solaVideo)(NSString *videoPath); //单个视频路径

@end
