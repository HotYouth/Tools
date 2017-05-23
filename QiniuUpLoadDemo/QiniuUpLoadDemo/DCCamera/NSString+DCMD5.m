//
//  NSString+DCMD5.m
//  VideoDemo
//
//  Created by 王忠诚 on 2017/5/8.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "NSString+DCMD5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (DCMD5)

- (NSString *)MD5String
{
    if([self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [NSString stringWithString:outputString];
}

@end
