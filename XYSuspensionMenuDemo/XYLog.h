//
//  XYLog.h
//  XYLog
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 xiaoyuan. All rights reserved.
//

@import Foundation;

NSNotificationName XYLogDidChangeLogNotification = @"XYLogDidChangeLogNotification";

// 添加一个全局的logString 防止局部清除
static NSMutableString *xy_logSting;

extern void xy_print(NSString *msg, const char *function, NSInteger Line);
extern void xy_log(const char *function, NSUInteger line, NSString *format, ...) NS_FORMAT_FUNCTION(3,4);

#define XYLog(frmt, ...) \
    xy_log(__PRETTY_FUNCTION__, __LINE__, frmt, ## __VA_ARGS__);

void xy_log(const char *function, NSUInteger line, NSString *format, ...) {
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        NSString *message = nil;
        message = [[NSString alloc] initWithFormat:format arguments:args];

        xy_print(message, function, line);
    }
    
}
void xy_print(NSString *msg, const char *function, NSInteger Line) {
    // 转换方法名称为NSString
    NSString *funcString = [NSString stringWithUTF8String:function];
    // 时间格式化
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    msg = [NSString stringWithFormat:@"%@ %@ [line:%ld] %@\n\n",[formatter stringFromDate:[NSDate new]], funcString,(long)Line,msg];
    
    const char *resultCString = NULL;
    if ([msg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        resultCString = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    }
    // 控制台打印，只打印当前log
    printf("%s", resultCString);
    [xy_logSting appendString:msg];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XYLogDidChangeLogNotification object:xy_logSting];
    
}

