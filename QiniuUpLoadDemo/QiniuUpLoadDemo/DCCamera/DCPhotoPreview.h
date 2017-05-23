//
//  DCPhotoPreview.h
//  CameraDemo
//
//  Created by 王忠诚 on 2017/5/3.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCPhotoPreviewDelegate <NSObject>

- (void)didCancel;

@end

@interface DCPhotoPreview : UIScrollView

@property (nonatomic,strong)UIImage *image;

@property (nonatomic,assign) id <DCPhotoPreviewDelegate> eventDelegate;

+ (UIImage *)ImageWithText:(NSString *)text;

- (void)cancel;

- (void)saveInPath:(NSString *)path complier:(void(^)(BOOL success))complier;

+ (NSString *)currentDateStr;

@end
