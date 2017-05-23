//
//  DCNetWorkManager.m
//  QiniuUpLoadDemo
//
//  Created by 王忠诚 on 2017/5/16.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCNetWorkManager.h"
#import "AFNetworkActivityIndicatorManager.h" 
#import "NSString+DCMD5.h"

//https://www.koudaicfo.com.cn/index.php/index/user/industry
#define BASE_URL @"http://192.168.0.23:8080/web"//@"https://www.koudaicfo.com.cn/index.php"

@implementation DCNetWorkManager

+(instancetype)shareManager {
    static DCNetWorkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    });
    return manager;
}


- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        self.requestSerializer.timeoutInterval = 30;
        self.requestSerializer.cachePolicy  = NSURLRequestReloadIgnoringLocalCacheData; //缓存策略
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer = response;
        
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil]];
    }
    return self;
}

//不带缓存
+ (void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock progress:(downloadProgress)progress {
    switch (type) {
            
        case HttpRequestTypeGet:
        {
            [[DCNetWorkManager shareManager] GET:urlString parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {
                
                progress(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                successBlock(responseObject);
                
                NSLog(@"Get请求结果：%@",responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
            }];
            
            break;
        }
        case HttpRequestTypePost:
        {
            
            [[DCNetWorkManager shareManager] POST:urlString parameters:paraments progress:^(NSProgress * _Nonnull uploadProgress) {
                
                progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                successBlock(responseObject);
                
                NSLog(@"Post请求结果：%@",responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
                
                NSLog(@"Error结果：%@",error);
                
            }];
        }
    }
}

//带缓存
+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments jsonCacheBlock:(requestCache)jsonCache withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock progress:(downloadProgress)progress{
    
    NSDictionary *responsedic = [DCNetWorkManager cacheJsonWithURL:urlString];
    
    if (responsedic!=nil) { //获取缓存
        
        jsonCache([DCNetWorkManager cacheJsonWithURL:urlString]);
    }
    
    NSLog(@"请求URL： %@/%@",BASE_URL,urlString);
    NSLog(@"请求参数：%@",paraments);
    
    switch (type) {
            
        case HttpRequestTypeGet:
        {
            [[DCNetWorkManager shareManager] GET:urlString parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {
                
                progress(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                successBlock(responseObject);
                
                [DCNetWorkManager saveJsonResponseToCacheFile:responseObject andURL:urlString];
                
                NSLog(@"Get请求结果：%@",responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
                
                NSLog(@"Error结果：%@",error);
            }];
            
            break;
        }
            
        case HttpRequestTypePost:
        {
            [[DCNetWorkManager shareManager] POST:urlString parameters:paraments progress:^(NSProgress * _Nonnull uploadProgress) {
                
                progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSLog(@"Post请求结果：%@",responseObject);
                
                successBlock(responseObject);
                
                [DCNetWorkManager saveJsonResponseToCacheFile:responseObject andURL:urlString];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                failureBlock(error);
                
                NSLog(@"Error结果：%@",error);
                
            }];
        }
    }
}

+ (void)uploadImageWithOperations:(NSDictionary *)operations withImagePaths:(NSArray *)paths withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress {
    urlString = [NSString stringWithFormat:@"%@/%@",BASE_URL,urlString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger i = 0 ;
        for (NSString *imagePath in paths) {
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            NSString *name = [NSString stringWithFormat:@"image_%ld.png",(long)i];
            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/png"];
            i ++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        successBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failureBlock(error);
    }];
}

//文件下载
+(void)downLoadFileWithOperations:(NSDictionary *)operations withSavaPath:(NSString *)savePath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withDownLoadProgress:(downloadProgress)progress
{
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return  [NSURL URLWithString:savePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            
            failureBlock(error);
        }
        
    }];
    
}

#pragma mark - 缓存处理 方法
+(BOOL)saveJsonResponseToCacheFile:(id)jsonResponse andURL:(NSString *)URL{
    
    NSDictionary *json = jsonResponse;
    
    NSString *path = [self cacheFilePathWithURL:URL];
    
    YYCache *cache = [[YYCache alloc] initWithPath:path];
    
    if(json!=nil)
    {
        BOOL state = [cache containsObjectForKey:URL];
        
        [cache setObject:json forKey:URL];
        
        if(state){
            
            NSLog(@"缓存写入/更新成功");
        }
        
        return state;
    }
    
    return NO;
}

+(id )cacheJsonWithURL:(NSString *)URL{
    
    id cacheJson;
    
    NSString *path = [self cacheFilePathWithURL:URL];
    
    YYCache *cache = [[YYCache alloc] initWithPath:path];
    
    BOOL state = [cache containsObjectForKey:URL];
    
    if(state){
        
        cacheJson = [cache objectForKey:URL];
    }
    
    return cacheJson;
}

+ (NSString *)cacheFilePathWithURL:(NSString *)URL {
    
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"bcwYYCache"];
    
    [self checkDirectory:path];//check路径
    
    //文件名
    NSString *cacheFileNameString = [NSString stringWithFormat:@"URL:%@ AppVersion:%@",URL,[self appVersionString]];
    NSString *cacheFileName = [cacheFileNameString MD5String];//[self md5StringFromString:cacheFileNameString];
    path = [path stringByAppendingPathComponent:cacheFileName];
    
    //   DNSLog(@"缓存 path = %@",path);
    
    return path;
}

+(void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

+ (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        
        [self addDoNotBackupAttribute:path];
    }
}

+ (void)addDoNotBackupAttribute:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (error) {
        NSLog(@"error to set do not backup attribute, error = %@", error);
    }
}


+ (NSString *)appVersionString {
    
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


@end
