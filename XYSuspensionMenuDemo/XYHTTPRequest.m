//
//  XYHTTPRequest.m
//  XYSuspensionMenuDemo
//
//  Created by swae on 2018/1/16.
//  Copyright © 2018年 xiaoyuan. All rights reserved.
//

#import "XYHTTPRequest.h"

@implementation XYHTTPRequest

+ (NSURLSessionDataTask *)rquest:(NSMutableURLRequest *)request
                      parameters:(NSDictionary *)parameters
                      completion:(XYHTTPRequestCompletionHandler)completionHandler {
    NSParameterAssert(request);
    NSString *str;
    if (parameters) {
        NSError *parseError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&parseError];
        str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if (completionHandler) {
                    completionHandler(nil, error);
                }
                return;
            }
            else {
                completionHandler(data, nil);
            }
        });
        
        
    }];
    [task resume];
    return task;
}

+ (NSURLSessionDataTask *)rquestWithURLString:(NSString *)URLString
                                   parameters:(NSDictionary *)parameters
                                      headers:(NSDictionary *)headers
                                       method:(XYHTTPRequestMethod)method
                                   completion:(XYHTTPRequestCompletionHandler)completionHandler {
    NSParameterAssert(URLString.length);
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    if (request.timeoutInterval == 0) {
        request.timeoutInterval = 5.0;
    }
    if (!request.allHTTPHeaderFields.count) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    if (headers) {
        for (NSString *key in headers) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    NSString *str;
    if (parameters) {
        NSError *parseError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&parseError];
        str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }
    switch (method) {
        case XYHTTPRequestMethodGET:
            [request setHTTPMethod:@"GET"];
            break;
        case XYHTTPRequestMethodPOST:
            [request setHTTPMethod:@"POST"];
            break;
        case XYHTTPRequestMethodPUT:
            [request setHTTPMethod:@"PUT"];
            break;
        case XYHTTPRequestMethodHEAD:
            [request setHTTPMethod:@"HEAD"];
            break;
        default:
            [request setHTTPMethod:@"GET"];
            break;
    }
    NSURLSessionDataTask *task = [self rquest:request parameters:parameters completion:completionHandler];
    [task resume];
    return task;
}


@end
