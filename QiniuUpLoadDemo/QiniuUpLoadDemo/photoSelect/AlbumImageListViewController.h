//
//  AlbumImageListViewController.h
//  PhotoSelect
//
//  Created by 象萌cc002 on 15/9/16.
//  Copyright (c) 2015年 象萌cc002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumImgViewController.h"

@interface ListCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;
//@property (assign, nonatomic) BOOL isChoose;/**< 是否已选择 */
//@property (nonatomic,retain)UIButton *selectedBtn;
@end


@interface AlbumImageListViewController : UIViewController

@property (nonatomic,retain)ALAssetsGroup* group;
@property (strong, nonatomic) AlbumImgViewController *groupVC;
@end
