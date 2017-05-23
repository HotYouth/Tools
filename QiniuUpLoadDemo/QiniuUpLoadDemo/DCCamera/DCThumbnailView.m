//
//  DCThumbnailView.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCThumbnailView.h"

@interface DCThumbnailView ()

@property (nonatomic,strong)UIImageView *showView;

@property (nonatomic,strong)UILabel *numLab;

@end

@implementation DCThumbnailView

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
        [self addSubview:self.showView];
        [self addSubview:self.numLab];
        self.userInteractionEnabled = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)addImagePath:(NSString *)path {
    if (path.length == 0) {
        return;
    }
    [self.ThumbnailList addObject:path];
    [self coverImage:path];
    if (self.ThumbnailList.count > 0) {
        self.userInteractionEnabled = YES;
        self.numLab.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.ThumbnailList.count];
        self.numLab.hidden = NO;
    }
}

- (void)coverImage:(NSString *)imagePath {
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
    self.showView.image = image;
    
}

- (void)tap {
    NSLog(@"--->tap");
    if (self.showBlock) {
        self.showBlock();
    }
}

- (NSMutableArray *)ThumbnailList {
    if (!_ThumbnailList) {
        _ThumbnailList = [NSMutableArray arrayWithCapacity:0];
    }
    return _ThumbnailList;
}

- (UIImageView *)showView {
    if (!_showView) {
        _showView = [[UIImageView alloc]initWithFrame:self.bounds];
        _showView.contentMode = UIViewContentModeScaleAspectFill;
        _showView.clipsToBounds = YES;
    }
    return _showView;
}

- (UILabel *)numLab {
    if (!_numLab) {
        _numLab = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width - 10, -10, 20, 20)];
        _numLab.textColor = [UIColor whiteColor];
        _numLab.backgroundColor = [UIColor redColor];
        _numLab.font = [UIFont systemFontOfSize:12.0f];
        _numLab.textAlignment = NSTextAlignmentCenter;
        _numLab.layer.cornerRadius = 10;
        _numLab.clipsToBounds = true;
        _numLab.hidden = YES;
    }
    return _numLab;
}



@end
