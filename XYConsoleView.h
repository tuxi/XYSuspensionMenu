//
//  XYConsoleView.h
//  XYConsoleView
//
//  Created by xiaoyuan on 05/12/2017.
//  Copyright © 2017 xiaoyuan. All rights reserved.
//

#ifdef __OBJC__

#define XYConsole_dispatch_main_safe_async(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } \
    else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#define XYLog(frmt, ...) \
    xy_log(__PRETTY_FUNCTION__, __LINE__, frmt, ## __VA_ARGS__);

@import Foundation;

static NSNotificationName XYLogDidChangeLogNotification = @"XYLogDidChangeLogNotification";

static void xy_print(NSString *msg, const char *function, NSInteger Line) {
    
    NSString *tempMsg = msg.copy;
    NSString *funcString = [NSString stringWithUTF8String:function];
    static NSDateFormatter *formatter = nil;
    static NSMutableString *xy_logSting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        xy_logSting = [NSMutableString new];
    });
    
    tempMsg = [NSString stringWithFormat:@"%@ %@ [line:%ld] %@\n\n",[formatter stringFromDate:[NSDate new]], funcString,(long)Line, msg];
    
    const char *resultCString = NULL;
    if ([tempMsg canBeConvertedToEncoding:NSUTF8StringEncoding]) {
        resultCString = [tempMsg cStringUsingEncoding:NSUTF8StringEncoding];
    }
    // 控制台打印，只打印当前log
    printf("%s", resultCString);
    [xy_logSting appendString:tempMsg];
    
    XYConsole_dispatch_main_safe_async(^{
         [[NSNotificationCenter defaultCenter] postNotificationName:XYLogDidChangeLogNotification object:xy_logSting];
    })
    
}

__unused static void xy_log(const char *function, NSUInteger line, NSString *format, ...) {
    va_list args;
    
    if (format) {
        va_start(args, format);
        
        NSString *message = nil;
        message = [[NSString alloc] initWithFormat:format arguments:args];
        
        xy_print(message, function, line);
    }
    
}

#endif 

#import "XYSuspensionMenu.h"

@class XYConsoleTextView, XYConsoleView;

@interface UIApplication (XYConsole)

@property (nonatomic) XYConsoleView *xy_consoleView;

- (XYConsoleView *)xy_showConsoleWithCompletion:(void (^)(BOOL finished))completion;
- (BOOL)xy_hideConsoleWithCompletion:(void (^)(BOOL finished))completion;
- (void)xy_toggleConsoleWithCompletion:(void (^)(BOOL finished))completion;

@end


@interface XYConsoleTextView : UITextView

@end

@interface XYConsoleView : SuspensionWindow

@property (nonatomic, strong) XYConsoleTextView *consoleTextView;

@property (nonatomic, copy) NSString *text;

@end
