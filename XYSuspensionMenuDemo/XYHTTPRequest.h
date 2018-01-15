//
//  XYHTTPRequest.h
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/16.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XYHTTPRequestMethod) {
    XYHTTPRequestMethodGET,
    XYHTTPRequestMethodPOST,
    XYHTTPRequestMethodPUT,
    XYHTTPRequestMethodHEAD
};

typedef void(^XYHTTPRequestCompletionHandler)(NSData *resultData, NSError *error);

@interface XYHTTPRequest : NSObject

+ (NSURLSessionDataTask *)rquestWithURLString:(NSString *)URLString
                                   parameters:(NSDictionary *)parameters
                                      headers:(NSDictionary *)headers
                                       method:(XYHTTPRequestMethod)method
                                   completion:(XYHTTPRequestCompletionHandler)completionHandler;

+ (NSURLSessionDataTask *)rquest:(NSMutableURLRequest *)request
                      parameters:(NSDictionary *)parameters
                      completion:(XYHTTPRequestCompletionHandler)completionHandler;

@end

