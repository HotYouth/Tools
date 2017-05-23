//
//  DCAnimationRecordView.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/5.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCAnimationRecordView : UIView

@property (nonatomic,copy) void(^startRecord)();

@property (nonatomic,copy) void(^completeRecord)(CFTimeInterval recordTime);

@property (nonatomic,copy) void(^takePhoto)();

@property (nonatomic,assign) BOOL canRecord;

@end
