//
//  UIWebView+XYBlocks.m
//  VideoTweak
//
//  Created by swae on 2018/1/14.
//  Copyright © 2018年 alpface. All rights reserved.
//

#import "UIWebView+XYBlocks.h"
#import <objc/runtime.h>

@interface UIWebView ()

@property (nonatomic, copy) void (^loadedBlock)(UIWebView *webView);
@property (nonatomic, copy) void (^failureBlock)(UIWebView *webView, NSError *error);
@property (nonatomic, copy) void(^loadStartedBlock)(UIWebView *webView);
@property (nonatomic, copy) BOOL(^shouldLoadBlock)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType);
@property (nonatomic, assign) NSInteger loadedWebItems;


@end

@implementation UIWebView (XYBlocks)

#pragma mark - UIWebView+Blocks

+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock{
    
    return [self loadRequest:request loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *webView))loadedBlock
                       failed:(void (^)(UIWebView *webView, NSError *error))failureBlock{
    
    return [self loadHTMLString:htmlString loaded:loadedBlock failed:failureBlock loadStarted:nil shouldLoad:nil];
}

+ (UIWebView *)loadHTMLString:(NSString *)htmlString
                       loaded:(void (^)(UIWebView *))loadedBlock
                       failed:(void (^)(UIWebView *, NSError *))failureBlock
                  loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                   shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock{
    UIWebView *webView  = [[UIWebView alloc] init];
    webView.loadedWebItems    = 0;
    webView.loadedBlock = loadedBlock;
    webView.failureBlock = failureBlock;
    webView.loadStartedBlock = loadStartedBlock;
    webView.shouldLoadBlock = shouldLoadBlock;
    
    webView.delegate = (id)[self class];
    [webView loadHTMLString:htmlString baseURL:nil];
    
    return webView;
}


- (void)loadHTMLString:(NSString *)htmlString
                loaded:(void (^)(UIWebView *))loadedBlock
                failed:(void (^)(UIWebView *, NSError *))failureBlock
           loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
            shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock {
    self.loadedBlock = loadedBlock;
    self.failureBlock = failureBlock;
    self.loadStartedBlock = loadStartedBlock;
    self.shouldLoadBlock = shouldLoadBlock;
    
    self.delegate = (id)[self class];
    [self loadHTMLString:htmlString baseURL:nil];
}

+ (UIWebView *)loadRequest:(NSURLRequest *)request
                    loaded:(void (^)(UIWebView *webView))loadedBlock
                    failed:(void (^)(UIWebView *webView, NSError *error))failureBlock
               loadStarted:(void (^)(UIWebView *webView))loadStartedBlock
                shouldLoad:(BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType))shouldLoadBlock{
    
    UIWebView *webView  = [[UIWebView alloc] init];
    webView.loadedWebItems    = 0;
    
    webView.loadedBlock       = loadedBlock;
    webView.failureBlock      = failureBlock;
    webView.loadStartedBlock  = loadStartedBlock;
    webView.shouldLoadBlock   = shouldLoadBlock;
    
    
    webView.delegate    = (id) [self class];
    
    [webView loadRequest: request];
    
    return webView;
}


- (void) loadRequest: (NSURLRequest *) request
                     loaded: (void (^)(UIWebView *webView)) loadedBlock
                     failed: (void (^)(UIWebView *webView, NSError *error)) failureBlock
                loadStarted: (void (^)(UIWebView *webView)) loadStartedBlock
                 shouldLoad: (BOOL (^)(UIWebView *webView, NSURLRequest *request, UIWebViewNavigationType navigationType)) shouldLoadBlock {
    self.loadedWebItems    = 0;
    
    self.loadedBlock       = loadedBlock;
    self.failureBlock      = failureBlock;
    self.loadStartedBlock  = loadStartedBlock;
    self.shouldLoadBlock   = shouldLoadBlock;
    
    
    self.delegate    = (id) [self class];
    
    [self loadRequest: request];
    
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIWebViewDelegate
////////////////////////////////////////////////////////////////////////

+ (void)webViewDidFinishLoad:(UIWebView *)webView {
    webView.loadedWebItems--;
    
    if (webView.loadedBlock && (!TRUE_END_REPORT || webView.loadedWebItems == 0)){
        webView.loadedWebItems = 0;
        webView.loadedBlock(webView);
    }
}

+ (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    webView.loadedWebItems--;
    
    if(webView.failureBlock)
        webView.failureBlock(webView, error);
}

+ (void)webViewDidStartLoad:(UIWebView *)webView{
    webView.loadedWebItems++;
    
    if (webView.loadStartedBlock && (!TRUE_END_REPORT || webView.loadedWebItems > 0))
        webView.loadStartedBlock(webView);
}

+ (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(webView.shouldLoadBlock)
        return webView.shouldLoadBlock(webView, request, navigationType);
    
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////

- (void)setLoadedBlock:(void (^)(UIWebView *))loadedBlock {
    objc_setAssociatedObject(self, @selector(loadedBlock), loadedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIWebView *))loadedBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFailureBlock:(void (^)(UIWebView *, NSError *))failureBlock {
    objc_setAssociatedObject(self, @selector(failureBlock), failureBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIWebView *, NSError *))failureBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLoadStartedBlock:(void (^)(UIWebView *))loadStartedBlock {
    objc_setAssociatedObject(self, @selector(loadStartedBlock), loadStartedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIWebView *))loadStartedBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setShouldLoadBlock:(BOOL (^)(UIWebView *, NSURLRequest *, UIWebViewNavigationType))shouldLoadBlock {
    objc_setAssociatedObject(self, @selector(shouldLoadBlock), shouldLoadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIWebView *, NSURLRequest *, UIWebViewNavigationType))shouldLoadBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLoadedWebItems:(NSInteger)loadedWebItems {
    objc_setAssociatedObject(self, @selector(loadedWebItems), @(loadedWebItems), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)loadedWebItems {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
