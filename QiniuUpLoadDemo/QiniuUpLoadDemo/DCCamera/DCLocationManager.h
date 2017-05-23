//
//  DCLocationManager.h
//  CameraDemo
//
//  Created by 王忠诚 on 2017/5/3.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LocationBlock)(NSString *addressStr);

typedef void(^LocationErrorBlock)(NSError *error);

@interface DCLocationManager : NSObject

+ (instancetype)manager;

- (void)startLocationWithSuccess:(LocationBlock)success andFailure:(LocationErrorBlock)failure;

- (void)stopLocation;

@end
