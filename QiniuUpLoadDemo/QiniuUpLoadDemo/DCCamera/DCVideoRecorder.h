//
//  DCVideoRecorder.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/10.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DCVideoRecorder : NSObject

- (id)initWithSuperView:(UIView *)view;

- (void)startRecordWithFilePath:(NSString *)path;

- (void)stopRecord;

- (void)takePhoto:(void(^)(UIImage *image))complier;

- (void)runing;

@end
