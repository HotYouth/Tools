//
//  DCVideoUtil.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/8.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCVideoUtil.h"
#import "NSString+DCMD5.h"

#define kVideoName @"dcvideorecorder_video"

#define kPhotoName @"dcvideorecorder_photo"

@implementation DCVideoUtil


+ (DCVideoModel *)createNewVideo {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *videoName = [[formatter stringFromDate:currentDate] MD5String];
    NSString *videoPath = [self getFilePath];
    DCVideoModel *model = [[DCVideoModel alloc]init];
    model.videoRelativePath = [NSString stringWithFormat:@"%@.mp4",videoName];
    model.thumRelativePath = [NSString stringWithFormat:@"%@.JPG",videoName];
    
    model.videoAbsolutePath = [videoPath stringByAppendingPathComponent:model.videoRelativePath];
    model.thumAbsolutePath = [videoPath stringByAppendingPathComponent:model.thumRelativePath];
    model.recordTime = currentDate;
    
    NSString *photoPath = [self getPhotoPath];
    NSString *photoName = [[formatter stringFromDate:currentDate] MD5String];
    model.photoRelativePath = [NSString stringWithFormat:@"%@.JPG",photoName];
    model.photoAbsolutePath = [photoPath stringByAppendingPathComponent:model.photoRelativePath];
    return model;
}

+ (BOOL)existVideo {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *nameList = [fileManager subpathsAtPath:[self getFilePath]];
    return nameList.count > 0;
}


+ (void)deleteVideo:(NSString *)videoPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:videoPath error:&error];
    if (error) {
        NSLog(@"删除视频失败:%@",error);
    }
//    NSString *thumPath = [videoPath stringByReplacingOccurrencesOfString:@"mp4" withString:@"JPG"];
//    NSError *error2 = nil;
//    [fileManager removeItemAtPath:thumPath error:&error2];
//    if (error2) {
//        NSLog(@"删除缩略图失败:%@",error);
//    }
}



+ (NSString *)getFilePath {
    return [self getCacheSubPath:kVideoName];
}

+ (NSString *)getPhotoPath {
    return [self getCacheSubPath:kPhotoName];
}

+ (NSString *)getCacheSubPath:(NSString *)dirName {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:dirName];
}

+ (void)initialize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [self getFilePath];
    
    NSError *error = nil;
    [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"创建文件夹失败:%@",error);
    }
    
    NSString *photoPath = [self getPhotoPath];
    [fileManager createDirectoryAtPath:photoPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"创建文件夹失败:%@",error);
    }
}


@end
