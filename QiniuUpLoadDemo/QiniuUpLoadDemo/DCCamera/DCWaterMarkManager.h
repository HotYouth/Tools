//
//  DCWaterMarkManager.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/10.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface DCWaterMarkManager : NSObject

- (void)createWatermark:(UIImage *)waterMarkImg video:(NSString *)videoPath complier:(void(^)(BOOL success,NSString *newPath))complier;

@end
