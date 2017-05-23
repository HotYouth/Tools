//
//  DCViedoView.h
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/5.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCViedoViewDelegate  <NSObject>

- (void)backBtnDidSelected;

- (void)takePhotoEnd:(NSString *)path;

- (void)recordVideoEnd:(NSString *)path;

@end

@interface DCViedoView : UIView

@property (nonatomic,assign) id <DCViedoViewDelegate> eventDelegate;

@property (nonatomic,assign) BOOL canMultiSelect; //是否可以照片多选

@property (nonatomic,assign) BOOL canRecord; //是否可以录像

//@property (nonatomic,copy)void (^takePhotoEnd)(NSString *photoPath);


@end
