//
//  DCOriginalListView.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^picChoseBlock)(NSInteger index,BOOL isSelected);

typedef void(^sendCallBack)();

@interface DCOriginalListView : UIView

@property (nonatomic,strong)NSArray *listArray;

@property (nonatomic,strong)NSMutableArray *flagArray;

@property (nonatomic,strong)picChoseBlock choseBlock;

@property (nonatomic,copy)sendCallBack send;

- (void)currentIndex:(NSInteger)index;

@end
