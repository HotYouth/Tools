//
//  DCPlayerView.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/9.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPlayerView : UIView

@property (nonatomic,strong) NSURL *videoUrl;
@property (nonatomic,assign) BOOL autoReplay;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;

- (void)play;

- (void)stop;

@end
