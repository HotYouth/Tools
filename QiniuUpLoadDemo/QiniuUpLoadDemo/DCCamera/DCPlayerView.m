//
//  DCPlayerView.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/9.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation DCPlayerView {
    AVPlayer *_player;
    BOOL _isPlaying;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl {
    self = [super initWithFrame:frame];
    if (self) {
        _autoReplay = YES;
        _videoUrl = videoUrl;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:_videoUrl];
    _player = [AVPlayer playerWithPlayerItem:item];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:playerLayer];
}

- (void)playEnd {
    if (!_autoReplay) {
        return;
    }
    [_player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [_player play];
    }];
}

- (void)play {
    if (_isPlaying) {
        return;
    }
    [self tapAction];
}

- (void)stop {
    if (_isPlaying) {
        [self tapAction];
    }
}

- (void)tapAction {
    if (_isPlaying) {
        [_player pause];
    }
    else {
        [_player play];
    }
    _isPlaying = !_isPlaying;
}

- (void)removeFromSuperview {
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

@end
