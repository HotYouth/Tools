//
//  DCVideoModel.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/8.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCVideoModel : NSObject

//视频的绝对路径
@property (nonatomic,copy)NSString *videoAbsolutePath;

//相对路径
@property (nonatomic,copy)NSString *videoRelativePath;

//缩略图相对路径
@property (nonatomic,copy)NSString *thumRelativePath;

//缩略图绝对路径
@property (nonatomic,copy)NSString *thumAbsolutePath;

//视频录制时间
@property (nonatomic,strong)NSDate *recordTime;

@property (nonatomic,strong)NSString *photoRelativePath;

@property (nonatomic,strong)NSString *photoAbsolutePath;

@end
