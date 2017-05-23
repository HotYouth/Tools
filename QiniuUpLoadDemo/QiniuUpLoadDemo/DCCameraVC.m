//
//  DCCameraVC.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/15.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCCameraVC.h"
#import "DCViedoView.h"
@interface DCCameraVC ()<DCViedoViewDelegate>

@end

@implementation DCCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    DCViedoView *videoView = [[DCViedoView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    videoView.eventDelegate = self;
    videoView.canRecord = YES;
//    videoView.canMultiSelect = NO;
    [self.view addSubview:videoView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(send:) name:kNotificationSendName object:nil];
    
}

- (void)send:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSArray *arr = dict[@"list"];
    if (arr.count > 0) {
        if (self.photoList) {
            self.photoList(arr);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
//    NSLog(@"%@",arr);
}




- (void)dealloc {
    NSLog(@"------delloc");
}




#pragma - DCViedoViewDelegate
- (void)backBtnDidSelected {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePhotoEnd:(NSString *)path {
    if (self.solaPhoto) {
        self.solaPhoto(path);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordVideoEnd:(NSString *)path {
    if (self.solaVideo) {
        self.solaVideo(path);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
