//
//  DCViedoView.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/5.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCViedoView.h"
#import <AVFoundation/AVFoundation.h>

#import "DCAnimationRecordView.h"
#import "DCPhotoPreview.h"
#import "DCPlayerView.h"
#import "DCThumbnailView.h"

#import "DCVideoUtil.h"
#import "DCVideoModel.h"
#import "DCAddWaterMark.h"

#import "DCVideoRecorder.h"

#import "DCWaterMarkManager.h"
#import "DCLocationManager.h"

#import "DCThumbnailListView.h"

@interface DCViedoView ()
{
    BOOL _isPhoto;
}

@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) DCAnimationRecordView *recordView;

@property (nonatomic,strong) UIButton *sendBtn,*cancelBtn;

@property (nonatomic,strong) UILabel *tipsLab;

@property (nonatomic,strong) DCVideoModel *currentRecord;

//前后摄像头转换
@property (nonatomic,strong) UIButton *reverseBtn;
@property (nonatomic,strong) DCPhotoPreview *photoView;
@property (nonatomic,strong) UIView *videoView;
@property (nonatomic,strong) DCPlayerView *playerView;
@property (nonatomic,strong) DCThumbnailView *thumbnailView;


@property (nonatomic,strong) DCVideoRecorder *currentRecorder;
@property (nonatomic,strong) NSString *currentVideoPath;
@property (nonatomic,strong) DCThumbnailListView *listView;



//闪光灯开关
//@property (nonatomic,strong) UIButton *flashButton;

@end

@implementation DCViedoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
        shadow.shadowBlurRadius = 6;
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"取消" attributes:@{
                                                                                                           NSFontAttributeName:[UIFont systemFontOfSize:15.0f],
                                                                                                           NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                           NSShadowAttributeName : shadow
                                                                                                           }];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setAttributedTitle:str forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (DCAnimationRecordView *)recordView {
    if (!_recordView) {
        _recordView = [[DCAnimationRecordView alloc]initWithFrame:CGRectMake(self.bounds.size.width / 2 - 60, self.bounds.size.height - 50 - 120, 120, 120)];
    }
    return _recordView;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        UIImage *btnImg = [UIImage imageNamed:@"record_finish"];
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setImage:btnImg forState:UIControlStateNormal];
        _sendBtn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
        _sendBtn.alpha = 0;
        [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIImage *btnImg = [UIImage imageNamed:@"record_cancel"];
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:btnImg forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.alpha = 0;
    }
    return _cancelBtn;
}

- (UILabel *)tipsLab {
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _tipsLab.text = @"轻触拍照，长按录像";
        _tipsLab.font = [UIFont systemFontOfSize:14.0];
        _tipsLab.textColor = [UIColor whiteColor];
        _tipsLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsLab;
}

- (UIButton *)reverseBtn {
    if (_reverseBtn == nil) {
        _reverseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"camera-switch"];
        _reverseBtn.frame = CGRectMake(self.bounds.size.width - 20 - 44, 20, 44, 44);
        [_reverseBtn addTarget:self action:@selector(reverseBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_reverseBtn setImage:image forState:UIControlStateNormal];
    }
    return _reverseBtn;
}

- (DCPhotoPreview *)photoView {
    if (_photoView == nil) {
        _photoView = [[DCPhotoPreview alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _photoView.alpha = 1;
    }
    return _photoView;
}

//MARK: lazy
- (UIView *)videoView
{
    if(!_videoView){
        _videoView = [[UIView alloc] initWithFrame:self.bounds];
        
    }
    return _videoView;
}

- (DCThumbnailView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[DCThumbnailView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    }
    return _thumbnailView;
}


//- (UIButton *)flashButton {
//    if (_flashButton == nil) {
//        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_flashButton setImage:[UIImage imageNamed:@"camera-flash-off"] forState:UIControlStateNormal];
//        [_flashButton setImage:[UIImage imageNamed:@"camera-flash-on"] forState:UIControlStateSelected];
////        [_flashButton addTarget:self action:@selector(flashBtnAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _flashButton;
//}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentRecorder = [[DCVideoRecorder alloc]initWithSuperView:self];
        
        
        
        [self addSubViews];
        [self makeUI];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"kLocationMsg" : @"" }];
        [[DCLocationManager manager] startLocationWithSuccess:^(NSString *addressStr) {
            [[NSUserDefaults standardUserDefaults] setObject:addressStr forKey:@"kLocationMsg"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } andFailure:^(NSError *error) {
            
        }];
    }
    return self;
}

- (void)setCanRecord:(BOOL)canRecord {
    _canRecord = canRecord;
    _tipsLab.text = self.canRecord ? @"轻触拍照，长按录像" : @"轻触拍照";
    
    self.recordView.canRecord = self.canRecord;
}

- (void)addSubViews {
    [self addSubview:self.videoView];
    [self addSubview:self.backBtn];
    [self addSubview:self.recordView];
    [self addSubview:self.thumbnailView];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.sendBtn];
    [self addSubview:self.tipsLab];
//    [self addSubview:self.reverseBtn];
}

- (void)makeUI {
    [self.backBtn sizeToFit];
    CGRect btnRect = self.backBtn.frame;
    btnRect.origin.x = 20;//self.recordView.frame.origin.x / 2;
    btnRect.size.width = 44;
    btnRect.size.height = 44;
    btnRect.origin.y = 20;//self.recordView.center.y - 44 / 2;
    self.backBtn.frame = btnRect;
    
    CGRect viewRect = self.thumbnailView.frame;
    viewRect.origin.x = (self.bounds.size.width / 2 - CGRectGetMinX(self.recordView.frame)) / 2 ;
    viewRect.origin.y = self.recordView.center.y - viewRect.size.height / 2;
    self.thumbnailView.frame = viewRect;
    
    
    self.tipsLab.frame = CGRectMake(0, CGRectGetMinY(self.recordView.frame) - 30, self.bounds.size.width, 30);
    
    self.cancelBtn.center = self.recordView.center;
    self.sendBtn.center = self.recordView.center;
    [self showBtn];
    
    __weak __typeof(self) weakSelf = self;
    
    self.recordView.startRecord = ^{
        _isPhoto = NO;
        weakSelf.currentRecord = [DCVideoUtil createNewVideo];
        [weakSelf.currentRecorder startRecordWithFilePath:weakSelf.currentRecord.videoAbsolutePath];
        [weakSelf hideBtn];
    };
#pragma mark 完成录制
    self.recordView.completeRecord = ^(CFTimeInterval recordTime) {
        NSLog(@"--recordTime %ld",(long)recordTime);
        [weakSelf.currentRecorder stopRecord];
//        DCWaterMarkManager *manager = [[DCWaterMarkManager alloc] init];
        [[[DCWaterMarkManager alloc] init] createWatermark:[UIImage imageNamed:@"iosIcon"] video:weakSelf.currentRecord.videoAbsolutePath complier:^(BOOL success, NSString *newPath) {
            if (success) {
                weakSelf.currentVideoPath = newPath;
                [weakSelf addPlayLayer];
                [weakSelf remakeBtnLayout];
            }
        }];
        
        
    };
#pragma mark 拍照
    self.recordView.takePhoto = ^{
        _isPhoto = YES;
        weakSelf.currentRecord = [DCVideoUtil createNewVideo];
        [weakSelf hideBtn];
        [weakSelf.currentRecorder takePhoto:^(UIImage *image) {
            if (image) {
                [weakSelf remakeBtnLayout];
                weakSelf.photoView.image = image;
                [weakSelf insertSubview:weakSelf.photoView aboveSubview:weakSelf.videoView];
            }
        }];
    };
    
    //展示缩略图列表
    self.thumbnailView.showBlock = ^{
        DCThumbnailListView *listView = [[DCThumbnailListView alloc]initWithFrame:weakSelf.bounds];
        listView.listArray = weakSelf.thumbnailView.ThumbnailList;
        
        [weakSelf addSubview:listView];
    };
    
    
    
    
}

- (void)remakeBtnLayout{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect cancelBtnRect = self.cancelBtn.frame;
        cancelBtnRect.origin.x = 30;
        self.cancelBtn.frame = cancelBtnRect;
        
        CGRect sendBtnRect = self.sendBtn.frame;
        sendBtnRect.origin.x = self.bounds.size.width - 30 - sendBtnRect.size.width;
        self.sendBtn.frame = sendBtnRect;
        self.sendBtn.alpha = 1;
        self.cancelBtn.alpha = 1;
        self.recordView.alpha = 0;
    }];
}

- (void)resetBtnLayout {
    [UIView animateWithDuration:0.25 animations:^{
        self.cancelBtn.center = self.recordView.center;
        self.sendBtn.center = self.recordView.center;
        self.sendBtn.alpha = 0;
        self.cancelBtn.alpha = 0;
        self.recordView.alpha = 1;
    }];
}

- (void)showBtn {
    self.backBtn.hidden = NO;
    self.reverseBtn.hidden = NO;
    self.tipsLab.hidden = NO;
    self.tipsLab.alpha = 1;
    self.thumbnailView.hidden = NO;
    [UIView animateWithDuration:0.2 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tipsLab.alpha = 0;
    } completion:^(BOOL finished) {
        self.tipsLab.hidden = YES;
    }];
}

- (void)hideBtn {
    self.backBtn.hidden = YES;
    self.tipsLab.hidden = YES;
    self.reverseBtn.hidden = YES;
    self.thumbnailView.hidden = YES;
}

- (void)addPlayLayer {
    NSURL *videoURL = [NSURL fileURLWithPath:self.currentVideoPath];
    self.playerView = [[DCPlayerView alloc]initWithFrame:self.bounds videoUrl:videoURL];
    [self addSubview:self.playerView];
    [self.playerView play];
    [self insertSubview:self.playerView aboveSubview:self.videoView];
}

#pragma mark - action 
- (void)cancelBtnAction {
    [self showBtn];
    [self resetBtnLayout];
    [self.currentRecorder runing];
    if (_isPhoto) {
        [self.photoView cancel];
        self.photoView = nil;
    }else {
        [self.playerView stop];
        [self.playerView removeFromSuperview];
        self.playerView = nil;
        [DCVideoUtil deleteVideo:self.currentRecord.videoAbsolutePath];
        [DCVideoUtil deleteVideo:self.currentVideoPath];
    }
    
}

- (void)reverseBtnAction {

}

- (void)backAction {
    if (self.eventDelegate&& [self.eventDelegate respondsToSelector:@selector(backBtnDidSelected)]) {
        [self.eventDelegate backBtnDidSelected];
    }
}

- (void)sendAction {
    if (_isPhoto) {
        [_photoView saveInPath:_currentRecord.photoAbsolutePath complier:^(BOOL success) {
            if (success) {
                NSLog(@"保存成功");
                [self showBtn];
                [self resetBtnLayout];
                [self.photoView cancel];
                self.photoView = nil;
                if (self.canMultiSelect) {
                    [_thumbnailView addImagePath:_currentRecord.photoAbsolutePath];
                }else {
                    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(takePhotoEnd:)]) {
                        [self.eventDelegate takePhotoEnd:_currentRecord.photoAbsolutePath];
                    }
                }
            }
        }];
    }else {
        if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(recordVideoEnd:)]) {
            [self.eventDelegate recordVideoEnd:self.currentVideoPath];
        }
    }
}

@end
