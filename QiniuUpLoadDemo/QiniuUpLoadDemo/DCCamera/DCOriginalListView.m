//
//  DCOriginalListView.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCOriginalListView.h"

@interface DCOriginalListView ()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView *originalScroll;

@property (nonatomic,strong)UIView *navBar;

@property (nonatomic,strong)UIView *bar;

@property (nonatomic,assign)BOOL showBar;

@property (nonatomic,strong)UIButton *choseBtn;

@property (nonatomic,strong)NSMutableArray *choseArray;

@property (nonatomic,strong)UIButton *sendBtn;

@end

@implementation DCOriginalListView

@synthesize navBar,bar,choseBtn,sendBtn;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIScrollView *)originalScroll {
    if (!_originalScroll) {
        _originalScroll = [[UIScrollView alloc]initWithFrame:self.bounds];
        _originalScroll.pagingEnabled = YES;
        _originalScroll.backgroundColor = [UIColor blackColor];
        _originalScroll.delegate = self;
    }
    return _originalScroll;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showBar = YES;
        self.flagArray = [[NSMutableArray alloc]initWithCapacity:0];
        self.choseArray = [[NSMutableArray alloc]initWithCapacity:0];
        [self addSubview:self.originalScroll];
        [self setNav];
        [self bottomBar];
    }
    return self;
}

- (void)setNav {
    navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
    navBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [leftBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:leftBtn];
    
    choseBtn = [[UIButton alloc]initWithFrame:CGRectMake(navBar.bounds.size.width - 60, 20, 50, 44)];
    [choseBtn setTitle:@"未选择" forState:UIControlStateNormal];
    [choseBtn setTitle:@"已选择" forState:UIControlStateSelected];
    [choseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    choseBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [choseBtn addTarget:self action:@selector(choseBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:choseBtn];
    
//    UIButton *right = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 44, 44)];
//    [right setTitle:@"完成" forState:UIControlStateNormal];
//    [right setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    right.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//    [navBar addSubview:right];
    
    [self addSubview:navBar];
}

- (void)bottomBar {
    bar = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 49, self.bounds.size.width, 49)];
    bar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self addSubview:bar];
    
    sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(bar.bounds.size.width - 50, 0, 50, 49)];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [bar addSubview:sendBtn];
}

- (void)cancelAction {
    [self removeFromSuperview];
}

- (void)choseBtnAction:(UIButton *)btn {
    btn.selected = !btn.selected;
    NSInteger index = self.originalScroll.contentOffset.x / self.bounds.size.width;
    
    if (index < self.flagArray.count) {
        [self.flagArray replaceObjectAtIndex:index withObject:@(btn.selected)];
        if (self.choseBlock) {
            self.choseBlock(index, btn.selected);
            if (btn.selected) {
                 [self.choseArray addObject:self.listArray[index]];
            }else {
                 [self.choseArray removeObject:self.listArray[index]];
            }
            sendBtn.enabled = !(self.choseArray.count == 0);
        }
    }
}

- (void)sendAction {

    if (self.choseArray.count > 0) {
        if (self.send) {
            self.send();
        }
    }
}


- (void)currentIndex:(NSInteger)index {
    if (self.listArray.count > 0 && self.flagArray.count > 0) {
        for (int i = 0; i < self.listArray.count; i ++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width * i, 0, self.bounds.size.width, self.bounds.size.height)];
            imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.listArray[i]]];
            [self.originalScroll addSubview:imageView];
            if (index == i) {
                NSNumber *boolValue = self.flagArray[i];
                choseBtn.selected = boolValue.boolValue;
                if (choseBtn.selected) {
                    [self.choseArray addObject:self.listArray[i]];
                }
                sendBtn.enabled = !(self.choseArray.count == 0);
            }
            
        }
        
        [self.originalScroll setContentSize:CGSizeMake(self.bounds.size.width * self.listArray.count, self.bounds.size.height)];
        [self.originalScroll setContentOffset:CGPointMake(self.bounds.size.width * index, 0)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(barAnimation)];
        [self addGestureRecognizer:tap];
    }
}

- (void) barAnimation {
    self.showBar = !self.showBar;
    if (self.showBar) {
        [self showBarAnimation];
    }else {
        [self hidenBarAnimation];
    }
}

- (void)showBarAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        navBar.frame = CGRectMake(0, 0, self.bounds.size.width, 64);
        bar.frame = CGRectMake(0, self.bounds.size.height - 49, self.bounds.size.width, 49);
    }];
}

- (void)hidenBarAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        navBar.frame = CGRectMake(0, -64, self.bounds.size.width, 64);
        bar.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, 49);
    }];
}

#pragma mark - delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.bounds.size.width;
    if (index < self.flagArray.count) {
        NSNumber *boolValue = self.flagArray[index];
        choseBtn.selected = boolValue.boolValue;
    }
}



@end
