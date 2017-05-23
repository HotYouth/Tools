//
//  DCAddWaterMark.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/9.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface DCAddWaterMark : NSObject

- (void)performWithAsset:(AVAsset*)asset path:(NSString *)path;

@end
