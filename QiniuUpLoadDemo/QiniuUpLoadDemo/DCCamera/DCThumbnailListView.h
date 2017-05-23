//
//  DCThumbnailListView.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^sendBlock)(NSArray *pathList);

@interface DCThumbnailListView : UIView



@property (nonatomic,strong)NSArray *listArray;


@property (nonatomic,copy)sendBlock send;

@end
