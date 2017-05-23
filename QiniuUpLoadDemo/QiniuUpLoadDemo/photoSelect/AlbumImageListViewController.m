//
//  AlbumImageListViewController.m
//  PhotoSelect
//
//  Created by 象萌cc002 on 15/9/16.
//  Copyright (c) 2015年 象萌cc002. All rights reserved.
//

#import "AlbumImageListViewController.h"

const CGFloat imageSpacing = 2.0f;  /**< 图片间距 */
const NSInteger maxCountInLine = 3; /**< 每行显示图片张数 */

@implementation ListCell{
//    UIButton *_selectedBtn;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
        
//        _selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 23, 5, 18, 18)];
//        [_selectedBtn setImage:[UIImage imageNamed:@"gallery_chs_normal"] forState:UIControlStateNormal];
//        [_selectedBtn setImage:[UIImage imageNamed:@"gallery_chs_seleceted"] forState:UIControlStateSelected];
//        _selectedBtn.userInteractionEnabled = NO;
//        [self.contentView addSubview:_selectedBtn];
    }
    return self;
}

-(void)setIsChoose:(BOOL)isChoose{
//    _isChoose = isChoose;
//    _selectedBtn.selected = isChoose;
}


@end


@interface AlbumImageListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,retain)UICollectionView *collectionView;
@property (nonatomic,retain)NSMutableArray *selectedAssets;
@property (nonatomic,retain)UIButton *finishButton;


@end

@implementation AlbumImageListViewController{
    NSMutableArray *_selectedFalgList;  /**< 是否选中标记 */
    NSMutableArray *_assetList;         /**< 当前相薄所有asset */
    NSInteger       _selectedCount;     /**< 已选asset总数 */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    title.text = self.title;
    
    title.textAlignment = NSTextAlignmentCenter;
    
    
    
    title.textColor = COLOR(70, 88, 98);
    title.font = [UIFont systemFontOfSize:16.0];
    
    
    self.navigationItem.titleView = title;
    
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    self.navigationController.navigationItem.hidesBackButton = YES;
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickCancel)];
//    [self addRightButton:@"取消"];
//    [self addLeftButton:@"返回"];
//    [self addBarButtonWithImageNames:@[@"fanhui"] andDirection:TXDirectionLeft];
    self.navigationController.navigationBar.backItem.hidesBackButton = YES;
    _selectedCount = 0;
    [self getAllPhoto];
    [self.view addSubview:self.collectionView];
    
}


#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat width = (self.view.frame.size.width - imageSpacing * (maxCountInLine - 1))/maxCountInLine;
        layout.itemSize = CGSizeMake(width, width);
        layout.minimumInteritemSpacing = imageSpacing;
        layout.minimumLineSpacing = imageSpacing;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ListCell class] forCellWithReuseIdentifier:@"list"];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

-(NSMutableArray *)selectedAssets{
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray new];
    }
    return _selectedAssets;
}

-(UIButton *)finishButton{
    if (!_finishButton) {
        _finishButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 49)];
        [_finishButton addTarget:self action:@selector(clickFinish) forControlEvents:UIControlEventTouchUpInside];
        [_finishButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _finishButton.backgroundColor = [UIColor whiteColor];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _finishButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _finishButton.layer.shadowOffset = CGSizeMake(0, -3);
        _finishButton.layer.shadowOpacity = 0.5f;
        [self.view addSubview:_finishButton];
        [self.view bringSubviewToFront:_finishButton];
    }
    return _finishButton;
}

#pragma mark - 获取图片数量
-(void)getAllPhoto{
    _assetList = [NSMutableArray new];
    _selectedFalgList = [NSMutableArray new];

    [self.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqual:ALAssetTypePhoto]) {
                [_assetList addObject:result];
                [_selectedFalgList addObject:@0];
            }
        }else{
            [self.collectionView reloadData];
            
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_assetList.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    }];
}

#pragma mark - showAnimation
-(void)showFinishButton{
    self.finishButton.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = _finishButton.frame;
        frame.origin.y = self.view.bounds.size.height - frame.size.height;
        _finishButton.frame = frame;
        
        frame = _collectionView.frame;
        frame.size.height = _finishButton.frame.origin.y;
        _collectionView.frame = frame;
    }];
    [_finishButton setTitle:[NSString stringWithFormat:@"已选%ld张",_selectedCount] forState:UIControlStateNormal];
}

-(void)hiddenFinishButton{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = _finishButton.frame;
        frame.origin.y = self.view.frame.size.height;
        _finishButton.frame = frame;
        
        frame = _collectionView.frame;
        frame.size.height = _finishButton.frame.origin.y;
        _collectionView.frame = frame;
    } completion:^(BOOL finished) {
        self.finishButton.hidden = YES;
    }];
}

#pragma mark - collectionViewDelegete/collectionViewdataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _assetList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{


    ListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"list" forIndexPath:indexPath];
    if (!cell) {
        cell = [ListCell new];
    }
    cell.imageView.image = [UIImage imageWithCGImage:[_assetList[indexPath.row ] thumbnail]];
    cell.isChoose = [_selectedFalgList[indexPath.row ] boolValue];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    _selectedFalgList[indexPath.row ] = [NSNumber numberWithBool:![_selectedFalgList[indexPath.row ] boolValue]];
//    if (_selectedCount >= self.groupVC.maxSelectionCount &&[_selectedFalgList[indexPath.row] boolValue]) {
//        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"最多可选%ld张图片",self.groupVC.maxSelectionCount]];
//        return;
//    }
//    ListCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.isChoose = [_selectedFalgList[indexPath.row ] boolValue];
    
    ALAsset *assets = _assetList[indexPath.row ];
//    if (cell.isChoose) {
//        [self.selectedAssets addObject:assets];
//        _selectedCount ++;
//    }else{
//        if ([self.selectedAssets containsObject:assets]) {
//            [self.selectedAssets removeObject:assets];
//        }
//        _selectedCount --;
//    }
    
//    if (_selectedCount > 0) {
        if (self.groupVC.delegate && [self.groupVC.delegate respondsToSelector:@selector(didSelectPhoto:WithAlbumUmg:)]) {
            [self.groupVC.delegate didSelectPhoto:[UIImage imageWithCGImage:assets.defaultRepresentation.fullScreenImage] WithAlbumUmg:self];
        }
//        [self showFinishButton];
//    }else{
//        [self hiddenFinishButton];
//    }
    
}


#pragma mark -  action
-(void)clickCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)leftButtonActions:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)clickBack{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//- (void)clickCancel{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)clickFinish{
    if (self.groupVC.delegate && [self.groupVC.delegate respondsToSelector:@selector(didSelectPhotos:)]) {
        NSMutableArray *photos = [NSMutableArray new];
        for (ALAsset *asset in _selectedAssets) {
            [photos addObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
        }
        [self.groupVC.delegate didSelectPhotos:photos];
    }
//    [self rightButtonAction:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
