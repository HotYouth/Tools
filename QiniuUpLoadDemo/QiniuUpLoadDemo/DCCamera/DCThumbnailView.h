//
//  DCThumbnailView.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^showListViewBlock)();

@interface DCThumbnailView : UIView

@property (nonatomic,strong)NSMutableArray *ThumbnailList;

@property (nonatomic,copy) showListViewBlock showBlock;


- (void)addImagePath:(NSString *)path;


@end
