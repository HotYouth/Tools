//
//  DCPhotoPreview.m
//  CameraDemo
//
//  Created by 王忠诚 on 2017/5/3.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCPhotoPreview.h"
#import "DCLocationManager.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DCPhotoPreview ()

@property (nonatomic,strong)UIImageView *imageView;

@property (nonatomic,strong)UIImage *resultImage;

@end

@implementation DCPhotoPreview

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
        [self addSubview:self.imageView];
        
        /*
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 44, 44)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
        UIButton *saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 44 - 10, 20, 44, 44)];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(saveBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveBtn];
        */
        
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    CGSize imageSize = [self sizeOfImageView:image];
    _imageView.frame = CGRectMake((SCREEN_WIDTH - imageSize.width) / 2, (SCREEN_HEIGHT - imageSize.height) > 0 ? (SCREEN_HEIGHT - imageSize.height) / 2 : 0, imageSize.width, imageSize.height);
    
    DCLocationManager *manager = [DCLocationManager manager];
    self.imageView.image = self.image;
    [manager startLocationWithSuccess:^(NSString *addressStr) {
        NSString *logStr = [NSString stringWithFormat:@"%@%@%@",[DCPhotoPreview currentDateStr],@"&&",addressStr];
        UIImage *maskImage = [DCPhotoPreview ImageWithText:logStr];
        self.resultImage = [DCPhotoPreview addImage:image maskImage:maskImage rect:CGRectMake(image.size.width - maskImage.size.width - 10, image.size.height - maskImage.size.height - 10, maskImage.size.width, maskImage.size.height)];
        self.imageView.image = self.resultImage;
    } andFailure:^(NSError *error) {
        NSLog(@"回调时间");
    }];
    
    self.contentSize = CGSizeMake(0, imageSize.height + 10);
}

- (CGSize)sizeOfImageView:(UIImage *)image {
    CGSize imageSize = image.size;
    CGFloat width = 0;
    CGFloat height = 0;
    if (imageSize.width >= SCREEN_WIDTH) {
        width = SCREEN_WIDTH;
        height = imageSize.height * (width / imageSize.width);
    }else {
        width = imageSize.width;
        height = imageSize.height;
    }
    return CGSizeMake(width, height);
}

- (void)cancelBtnAction {
    [self removeFromSuperview];
    NSLog(@"浏览视图移除");
    if (self.eventDelegate && [self.eventDelegate respondsToSelector:@selector(didCancel)]) {
        [self.eventDelegate didCancel];
    }
}

- (void)saveInPath:(NSString *)path complier:(void(^)(BOOL success))complier {
    if (_resultImage == nil) {
        return;
    }
    NSData *data = [self compressImage:self.resultImage toMaxDataSizeKBytes:200];
    NSString *msg = nil;
    BOOL success = NO;
    if ([data writeToFile:path atomically:YES]) {
        msg = @"保存成功";
        success = YES;
        complier(success);
    }else {
        msg = @"保存失败";
        success = NO;
        complier(success);
    }
//    [[[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
//    _resultImage = [UIImage imageWithData:[self compressImage:_resultImage toMaxDataSizeKBytes:200]];
//    UIImageWriteToSavedPhotosAlbum(_resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    /*
    NSString *filepath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    filepath = [NSString stringWithFormat:@"%@/data.jpeg",filepath];

     */
    
}


- (void)cancel {
    [self removeFromSuperview];
}


- (void)saveBtnAction {
    if (_resultImage == nil) {
        return;
    }
    _resultImage = [UIImage imageWithData:[self compressImage:_resultImage toMaxDataSizeKBytes:200]];
    UIImageWriteToSavedPhotosAlbum(_resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//    NSString *filepath =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    filepath = [NSString stringWithFormat:@"%@/data.jpeg",filepath];
//    NSData *data = [self compressImage:self.image toMaxDataSizeKBytes:200];
//    NSString *msg = nil;
//    if ([data writeToFile:filepath atomically:YES]) {
//        msg = @"保存成功";
//    }else {
//        msg = @"保存失败";
//    }
//    [[[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil;
    if (error) {
        msg = @"图片保存失败";
    }else {
        msg = @"图片保存成功";
    }
    NSLog(@"%@",msg);
}

//压缩到指定大小
- (NSData *)compressImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size {
    NSData *data;//UIImageJPEGRepresentation(image,1.0);
    CGFloat dataKBytes ;//= data.length / 1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat minQuality = 0.1f;
    CGFloat midQuelity = 0.0;
//    CGFloat lastData = dataKBytes;
    NSLog(@"压缩前大小 %f kb",data.length / 1000.0);
    
    while (maxQuality >= minQuality) {
        midQuelity = (maxQuality  + minQuality) / 2;
        data = UIImageJPEGRepresentation(image, midQuelity);
        dataKBytes = data.length / 1000.0;
        if (dataKBytes > size) {
            maxQuality = midQuelity - 0.05;
        }else {
            if ((size - dataKBytes) > 10) {
                minQuality = midQuelity + 0.05;
            }else {
                break;
            }
        }
        NSLog(@"--------------");
        NSLog(@"压缩后大小 %f kb",dataKBytes);
    }
    
    /*
    while (dataKBytes > size) {
        midQuelity = (maxQuality  + minQuality) / 2;
        data = UIImageJPEGRepresentation(image, midQuelity);
        dataKBytes = data.length / 1000.0;
        if (dataKBytes == lastData) {
            break;
        }else {
            lastData = dataKBytes;
            maxQuality = midQuelity - 0.05;
        }
        NSLog(@"--------------");
        NSLog(@"压缩后大小 %f kb",data.length / 1000.0);
    }
    */
    
    
    
    
    
    
//    while (dataKBytes > size && maxQuality > 0.01) {
//        maxQuality = maxQuality - 0.01;
//        data = UIImageJPEGRepresentation(image, maxQuality);
//        dataKBytes = data.length / 1000.0;
//        if (dataKBytes == lastData) {
//            break;
//        }else {
//            lastData = dataKBytes;
//        }
//        NSLog(@"--------");
//    }
//    NSLog(@"压缩后大小 %f kb",data.length / 1000.0);
    NSLog(@"maxQuality : %f",midQuelity);
//    NSLog(@"压缩后大小 %f kb",data.length / 1000.0);
    return data;
}



+ (NSString *)currentDateStr {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    return [formatter stringFromDate:currentDate];
}

+ (UIImage *)ImageWithText:(NSString *)text {
    NSArray *strs = [text componentsSeparatedByString:@"&&"];
    if (strs.count == 0) {
        return nil;
    }
    UIFont *font = [UIFont systemFontOfSize:25];
    CGFloat maxWidth = 0;
    CGFloat tempWidth = 0;
    for (NSString *str in strs) {
        tempWidth = [self strOfSize:str font:font].width;
        if (tempWidth > maxWidth) {
            maxWidth = tempWidth;
        }
    }
    
    NSString *newStr = [text stringByReplacingOccurrencesOfString:@"&&" withString:@"\n"];
    
    CGSize size = CGSizeMake(maxWidth, [self strOfSize:newStr font:font].height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.alignment = NSTextAlignmentRight;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc]initWithString:newStr];
    [mStr addAttributes:@{NSFontAttributeName : font,NSForegroundColorAttributeName : [UIColor whiteColor],NSParagraphStyleAttributeName : style} range:NSMakeRange(0, mStr.length)];
    [mStr drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return textImage;
}

+ (CGSize)strOfSize:(NSString *)text font:(UIFont *)aFont {
    if (text == nil) {
        return CGSizeZero;
    }
    return [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : aFont} context:nil].size;
}

+ (UIImage *)addImage:(UIImage *)useImage maskImage:(UIImage *)aMaskImage rect:(CGRect)aRect {
    UIGraphicsBeginImageContextWithOptions(useImage.size, NO, 0.0);
    [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
    [aMaskImage drawInRect:aRect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
