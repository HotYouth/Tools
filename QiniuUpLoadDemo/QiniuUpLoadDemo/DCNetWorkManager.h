//
//  DCNetWorkManager.h
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/16.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYCache.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSUInteger,HttpRequestType){
    HttpRequestTypeGet = 0,
    HttpRequestTypePost
};

//缓存回调
typedef void(^requestCache)(id jsonCache);

//成功回调
typedef void(^requestSuccess)(NSDictionary *responseObject);

//失败回调
typedef void(^requestFailure)(NSError *error);

//上传进度
typedef void(^uploadProgress)(float progress);

//下载进度
typedef void(^downloadProgress)(float progress);


@interface DCNetWorkManager : AFHTTPSessionManager

+ (instancetype)shareManager;

+ (void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock progress:(downloadProgress)progress;

+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments jsonCacheBlock:(requestCache)jsonCache withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock progress:(downloadProgress)progress;

+ (void)uploadImageWithOperations:(NSDictionary *)operations withImagePaths:(NSArray *)paths withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress;

+(void)downLoadFileWithOperations:(NSDictionary *)operations withSavaPath:(NSString *)savePath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withDownLoadProgress:(downloadProgress)progress;

@end
