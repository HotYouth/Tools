//
//  AlbumImgViewController.h
//  PhotoSelect
//
//  Created by 象萌cc002 on 15/8/25.
//  Copyright (c) 2015年 象萌cc002. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumImgDelegate <NSObject>

-(void)didSelectPhotos:(NSMutableArray *)photos;
-(void)didSelectPhoto:(UIImage *)image WithAlbumUmg:(UIViewController *)viewController;

@end

@interface albumImageViewCell : UITableViewCell

@end


@interface AlbumImgViewController : UIViewController
@property (assign, nonatomic) NSInteger maxSelectionCount;/**< 最多选择图片张数 */


@property(nonatomic,assign)id <AlbumImgDelegate>delegate;

@end
