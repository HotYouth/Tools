//
//  DCAnimationRecordView.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/5.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCAnimationRecordView.h"

#define kCircleLineWidth 5

#define MaxRecordTime 30

@interface DCAnimationRecordView ()<CAAnimationDelegate>

@property (nonatomic,strong)UIImageView *readyImageView,*startImageView;

@property (nonatomic,strong)CAShapeLayer *arcLayer;

@property (nonatomic,assign)CFTimeInterval startTime;

@end

@implementation DCAnimationRecordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.readyImageView];
        [self addSubview:self.startImageView];
        [self makeUI];
    }
    return self;
}

- (void)setCanRecord:(BOOL)canRecord {
    _canRecord = canRecord;
    if (self.canRecord) {
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        longpress.minimumPressDuration = 0.2;
        [self addGestureRecognizer:longpress];
    }else {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
    }
}

- (void)makeUI {
    self.readyImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.startImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)startAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        self.readyImageView.alpha = 0;
        self.startImageView.alpha = 1;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self addCircleLayer];
    }];
}

- (void)endAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
        self.readyImageView.alpha = 1;
        self.startImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.arcLayer removeAnimationForKey:@"CircleAnimantion"];
        [self.arcLayer removeFromSuperlayer];
        self.arcLayer = nil;
    }];
}

- (void)addCircleLayer {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [path addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:(self.bounds.size.height - kCircleLineWidth) / 2 startAngle:-M_PI_2 endAngle:2 *M_PI clockwise:YES];
    if (self.arcLayer) {
        [self.arcLayer removeAnimationForKey:@"CircleAnimantion"];
        [self.arcLayer removeFromSuperlayer];
        self.arcLayer = nil;
    }
    self.arcLayer = [CAShapeLayer layer];
    self.arcLayer.path = path.CGPath;
    self.arcLayer.fillColor = [UIColor clearColor].CGColor;
    self.arcLayer.strokeColor = [UIColor colorWithRed:50/255. green:190/255. blue:120/255. alpha:1].CGColor;
    self.arcLayer.lineWidth = kCircleLineWidth;
    self.arcLayer.frame = rect;
    [self.startImageView.layer addSublayer:self.arcLayer];
    [self drawLineAnimation];
    
}

- (void)drawLineAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = MaxRecordTime;
    animation.delegate = self;
    animation.fromValue = [NSNumber numberWithInteger:0];
    animation.toValue = [NSNumber numberWithInteger:1];
    [self.arcLayer addAnimation:animation forKey:@"CircleAnimantion"];
}


- (void)handleGesture:(UIGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"began");
            [self startAnimation];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"end");
            [self endAnimation];
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"cancel");
            break;
            
        default:
            break;
    }
}

- (void)tapGesture:(UIGestureRecognizer *)gesture {
//    NSLog(@"点按 拍照");
    if (self.takePhoto) {
        self.takePhoto();
    }
}

#pragma mark - animationDelegate 
- (void)animationDidStart:(CAAnimation *)anim {
    self.startTime = CACurrentMediaTime();
    NSLog(@"didStart time = %f",self.startTime);
    if (self.startRecord) {
        self.startRecord();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CFTimeInterval didStopTime = CACurrentMediaTime() - self.startTime;
    NSLog(@"stop flag = %tu  stopTime = %f",flag,didStopTime);
    [self endAnimation];
    if (self.completeRecord) {
        self.completeRecord(didStopTime);
    }
}

- (UIImageView *)readyImageView {
    if (!_readyImageView) {
        UIImage *image = [UIImage imageNamed:@"record_ready"];
        _readyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _readyImageView.image = image;
        _readyImageView.alpha = 1;
        _readyImageView.userInteractionEnabled = YES;
    }
    return _readyImageView;
}

- (UIImageView *)startImageView {
    if (!_startImageView) {
        UIImage *image = [UIImage imageNamed:@"record_start"];
        _startImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _startImageView.image = image;
        _startImageView.alpha = 0;
        _startImageView.userInteractionEnabled = YES;
    }
    return _startImageView;
}


@end
