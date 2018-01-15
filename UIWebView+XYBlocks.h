//
//  UIWebView+XYBlocks.h
//  VideoTweak
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (XYBlocks)

#define TRUE_END_REPORT NO

+ (UIWebView *) loadRequest: (NSURLRequest *) request
                     loaded: (void (^)(UIWebView *webView)) loadedBlock
                     failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock;


+ (UIWebView *) loadRequest: (NSURLRequest *) request
                     loaded: (void (^)(UIWebView *webView)) loadedBlock
                     failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock
                loadStarted: (void (^)(UIWebView *webView)) loadStartedBlock
                 shouldLoad: (BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType)) shouldLoadBlock;

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *webView))loadedBlock
                       failed:(void (^)(UIWebView *webView, NSError *error))failureBlock;

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *))loadedBlock
                       failed:(void (^)(UIWebView *, NSError *))failureBlock
                  loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                   shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock;

- (void) loadRequest: (NSURLRequest *) request
              loaded: (void (^)(UIWebView *webView)) loadedBlock
              failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock
         loadStarted: (void (^)(UIWebView *webView)) loadStartedBlock
          shouldLoad: (BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType)) shouldLoadBlock;

- (void)loadHTMLString:(NSString *)htmlString
                loaded:(void (^)(UIWebView *webView))loadedBlock
                failed:(void (^)(UIWebView *webView, NSError *))failureBlock
           loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
            shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock;
@end
