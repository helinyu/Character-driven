//
//  CommonWeb.m
//  CarCalc
//
//  Copyright © 2016年 Vanchu. All rights reserved.
//

#import "CommonWeb.h"

@interface CommonWeb ()<NativeDelegate>{
    BOOL isWebContorl;
    BOOL isWebviewReady;
}
@end

@implementation CommonWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.scrollsToTop=YES;
    self.naviTitle.title = self.dataTitle;
    
    self.webView.nativeDelegate = self;
    self.webView.multipleTouchEnabled = YES;
    self.webView.scrollView.scrollEnabled = YES;
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self.webView loadRemoteFile:@"test.carcalc.oa.com" withPath:(self.dataUrl)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(isWebviewReady)
        [self onWebviewDocumentReady:self.webView];
}

- (IBAction)onBackBtnClicked:(id)sender {
    if(isWebContorl) {
        [self.webView webViewCall:@"TriggerBack" withParams:@{}];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (void) setTitle:(NSString *)title andUrl:(NSString *)url {
    self.dataTitle = title;
    self.dataUrl = url;
}
- (void)setHeader:(NativeContext *)context {
    
    NSString *title = [context.params objectForKey:(@"title")];
    
    self.naviTitle.title = title;
    
}

#pragma mark - Webview Delegate Functions
- (void)onWebviewDocumentReady:(CCWebView *)webview {
    isWebviewReady = YES;
    NSDictionary *params = @{};
    
    [webview webViewCall:@"activate" withParams:params];
}
- (void)onWebviewStartLoad:(CCWebView *)webview {
    NSLog(@"onWebviewStartLoad");
}

- (void)onWebviewLoadFailed:(CCWebView *)webview {
    NSLog(@"onWebviewLoadFailed");
    
}
- (void)nativeCall_GoBack:(NativeContext *)context {
    NSLog(@"call GoBack");
    [self onBackBtnClicked:nil];
}
- (void)nativeCall_ControleBack:(NativeContext *)context {
    NSLog(@"call ControleBack");
    
    NSString *flag = [context.params objectForKey:(@"isControle")];
    
    if( [flag intValue] == 1) {
        isWebContorl = YES;
    }else {
        isWebContorl = NO;
    }
    
}
@end
