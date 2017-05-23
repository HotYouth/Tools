//
//  AlbumImgViewController.m
//  PhotoSelect
//
//  Created by 象萌cc002 on 15/8/25.
//  Copyright (c) 2015年 象萌cc002. All rights reserved.
//
#import "AlbumImgViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlbumImageListViewController.h"

@implementation albumImageViewCell

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame         = self.imageView.frame;
    frame.size.width     = self.frame.size.height - 5;
    frame.size.height    = frame.size.width;
    frame.origin.y       = (self.frame.size.height - frame.size.height) / 2;
    self.imageView.frame = frame;
}

@end


@interface AlbumImgViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain)UITableView *tableView;
@property (nonatomic,retain)NSMutableArray *groupList;


@end

@implementation AlbumImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickBack)];
//    [self addBarButtonWithImageNames:@[@"fanhui"] andDirection:TXDirectionLeft];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    title.text = @"相薄";
    
    title.textAlignment = NSTextAlignmentCenter;
    
    title.textColor = COLOR(70, 88, 98);
    
    title.font = [UIFont boldSystemFontOfSize:16.0f];
    
    self.navigationItem.titleView = title;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"dismiss"object:nil];
    
    [self.view addSubview:self.tableView];
    [self getAllGroup];
}

#pragma mark  - getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

-(NSMutableArray *)groupList{
    if (!_groupList) {
        _groupList = [NSMutableArray new];
    }
    return _groupList;
}

#pragma mark - tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _groupList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    albumImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[albumImageViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    ALAssetsGroup *group = _groupList[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"group_default"];
    [self getLastImageByGroup:group usingBlock:^(UIImage *image) {
        cell.imageView.image = image;
    }];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(%ld张)",[group valueForProperty:ALAssetsGroupPropertyName],[group numberOfAssets]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 0);
        tableView.layoutMargins = cell.layoutMargins;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
        tableView.separatorInset = cell.separatorInset;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_groupList[indexPath.row] numberOfAssets] <= 0) {
//        SVPHUD_ERROR(@"此相册没有照片");
        return;
    }
    AlbumImageListViewController *listView = [AlbumImageListViewController new];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    title.font = [UIFont boldSystemFontOfSize:18.0f];
    
    title.text = [_groupList[indexPath.row] valueForProperty:ALAssetsGroupPropertyName];
    
    title.textAlignment = NSTextAlignmentCenter;
    
    title.textColor = [UIColor whiteColor];
    
    
    listView.title = title.text;
    listView.groupVC = self;
    listView.group = _groupList[indexPath.row];
    [self.navigationController pushViewController:listView animated:YES];
//    listView.navigationItem.titleView = title;
}


#pragma - 获取相册内容
//获取所有相薄
-(void)getAllGroup{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^{
        library = [[ALAssetsLibrary alloc]init];
    });
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group){
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
            [self.groupList addObject:group];
        }else{
            [self.tableView reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failBlock = ^(NSError *error){
        NSLog(@"没有权限");
    };
    
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream | ALAssetsGroupSavedPhotos;
    [library enumerateGroupsWithTypes:type usingBlock:resultsBlock failureBlock:failBlock];
}

//获取某个相薄的最后一张图片
- (void)getLastImageByGroup:(ALAssetsGroup *)group usingBlock:(void (^)(UIImage *image))block{
    void (^selectionBlock)(ALAsset *,NSUInteger,BOOL *) = ^(ALAsset *asset,NSUInteger index,BOOL *innerStop){
        if (asset == nil) {
            return ;
        }
        if (block) {
            block([UIImage imageWithCGImage:[asset thumbnail]]);
        }
    };
    
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    if ([group numberOfAssets] > 0) {
        NSUInteger index = [group numberOfAssets] - 1;
        NSIndexSet *lastphotoIndexSet = [NSIndexSet indexSetWithIndex:index];
        [group enumerateAssetsAtIndexes:lastphotoIndexSet options:0 usingBlock:selectionBlock];
    }
    
}

-(void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
}

-(void)clickBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
