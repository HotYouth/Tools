//
//  DCThumbnailListView.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCThumbnailListView.h"

#import "DCOriginalListView.h"

@interface DCThumbnailListView ()
@property (nonatomic,strong)NSMutableArray *subViewList;

@property (nonatomic,strong)UIScrollView *thumbnailScroll;
@property (nonatomic,strong)NSMutableArray *flagArray;
@property (nonatomic,strong)NSMutableArray *choseArray;
@property (nonatomic,strong)UIButton *rightBtn;

@end


@implementation DCThumbnailListView

@synthesize rightBtn;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIScrollView *)thumbnailScroll {
    if (!_thumbnailScroll) {
        _thumbnailScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.bounds.size.width, self.bounds.size.height - 64)];
    }
    return _thumbnailScroll;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.subViewList = [[NSMutableArray alloc]initWithCapacity:0];
        self.flagArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.choseArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.backgroundColor = [UIColor whiteColor];
        [self setNav];
    }
    return self;
}

- (void)setNav {
    UIView *navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
    navBar.backgroundColor = [UIColor whiteColor];
    
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [leftBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:leftBtn];
    
    rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width - 44, 20, 44, 44)];
    [rightBtn setTitle:@"发送" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    rightBtn.enabled = NO;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [navBar addSubview:rightBtn];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(44, 20, self.bounds.size.width - 88, 44)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"选取照片";
    lab.font = [UIFont systemFontOfSize:14.0f];
    lab.textColor = [UIColor blackColor];
    [navBar addSubview:lab];
    
    [self addSubview:navBar];
}

- (void)cancelAction {
    [self removeFromSuperview];
}

- (void)sendAction {
    if (_choseArray.count > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendName object:nil userInfo:@{@"list" : self.choseArray}];
    }
}


- (void)setListArray:(NSArray *)listArray {
    _listArray = listArray;
    if (listArray.count > 0) {
        [self addSubview:self.thumbnailScroll];
        CGFloat viewWidth = (self.bounds.size.width - 4) / 3;
        UIImageView *lastImageView = nil;
        for (int i = 0; i < listArray.count; i ++) {
            CGFloat row = i / 3;
            CGFloat loc = i % 3;
            CGFloat viewX = loc * (viewWidth + 2);
            CGFloat viewY = row *(viewWidth + 2);
            NSData *imageData = [NSData dataWithContentsOfFile:listArray[i]];
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(viewX, viewY, viewWidth, viewWidth)];
            imgView.tag = 10086 + i;
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            imgView.image = [UIImage imageWithData:imageData];
            imgView.userInteractionEnabled = YES;
            [self.thumbnailScroll addSubview:imgView];
            [self.subViewList addObject:imgView];
            
            lastImageView = imgView;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
            [imgView addGestureRecognizer:tap];
            
            
            UIButton *flagBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewWidth - 30, 0, 30, 30)];
            flagBtn.tag = 10010 + i;
            [flagBtn addTarget:self action:@selector(flagBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [imgView addSubview:flagBtn];
            [self.flagArray addObject:@(flagBtn.selected)];
        }
        
        [self.thumbnailScroll setContentSize:CGSizeMake(self.bounds.size.width, CGRectGetMaxY(lastImageView.frame))];
        
    }
}

- (void)flagBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    [self.flagArray replaceObjectAtIndex:btn.tag - 10010 withObject:@(btn.selected)];
    if (btn.selected) {
        btn.backgroundColor = [UIColor blueColor];
        [self.choseArray addObject:self.listArray[btn.tag - 10010]];
    }else {
        btn.backgroundColor = [UIColor clearColor];
        [self.choseArray removeObject:self.listArray[btn.tag - 10010]];
    }
    rightBtn.enabled = !(self.choseArray.count == 0);
    
    
    NSLog(@"----");
}

- (void)tap:(UITapGestureRecognizer *)tap {
    UIView *tapView = [tap view];
//    NSLog(@"---->%ld",(long)tapView.tag);
    DCOriginalListView *listView = [[DCOriginalListView alloc]initWithFrame:self.bounds];
    listView.listArray = self.listArray;
    listView.flagArray = self.flagArray;
    listView.choseBlock = ^(NSInteger index, BOOL isSelected) {
        [self.flagArray replaceObjectAtIndex:index withObject:@(isSelected)];
        UIButton *btn = [self viewWithTag:10010 + index];
        btn.selected = isSelected;
        if (btn.selected) {
            btn.backgroundColor = [UIColor blueColor];
            [self.choseArray addObject:self.listArray[btn.tag - 10010]];
        }else {
            btn.backgroundColor = [UIColor clearColor];
            [self.choseArray removeObject:self.listArray[btn.tag - 10010]];
        }
        rightBtn.enabled = !(self.choseArray.count == 0);
    };
    listView.send = ^{
      //发送通知
         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendName object:nil userInfo:@{@"list" : self.choseArray}];
    };
    [listView currentIndex:tapView.tag - 10086];
    [self addSubview:listView];
}


@end
