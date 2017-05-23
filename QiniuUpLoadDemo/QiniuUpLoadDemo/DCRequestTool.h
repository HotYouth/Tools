//
//  DCRequestTool.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/16.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^requestFailure)(NSError *error);

//获取七牛token
typedef void(^qiniuToken)(NSString *token);

@interface DCRequestTool : NSObject

@end
