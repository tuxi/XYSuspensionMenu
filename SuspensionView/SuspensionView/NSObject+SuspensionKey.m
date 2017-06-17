//
//  NSObject+SuspensionKey.m
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "NSObject+SuspensionKey.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSObject (SuspensionKey)

- (void)setKey:(NSString *)key {
    objc_setAssociatedObject(self, @selector(key), key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)key {
    NSString *key = objc_getAssociatedObject(self, @selector(key));
    if (!key.length) {
        self.key = (key = [self md5:self.description]);
    }
    return key;
}

- (NSString *)keyWithIdentifier:(NSString *)identifier {
    return [self.key stringByAppendingString:identifier];
}

- (NSString *)md5:(NSString *)str {
    const char * cStr = [str UTF8String];
    unsigned char result[16];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7], result[8], result[9],
            result[10], result[11], result[12], result[13],
            result[14], result[15]];
}

@end
