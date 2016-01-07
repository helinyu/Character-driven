//
//  CCWebView.m
//  CarCalc
//
//  Created by helen on 16/1/4.
//  Copyright © 2016年 Vanchu. All rights reserved.
//

#import "CCWebView.h"

@interface WebviewDelegate : NSObject <UIWebViewDelegate>
@end

@implementation WebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    
    /*if ([requestString hasPrefix:@"system-http"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[requestString substringCaptureFromIndex:7]]];
        return NO;
    }*/
    
    if(![requestString hasPrefix:@"js-frame:"])
        return YES;
    
    if(![webView isKindOfClass:CCWebView.class])
        return YES;
    
    CCWebView *bridgedWebview = (CCWebView *)webView;
    if(!bridgedWebview.nativeDelegate)
        return YES;
    
    //step 1. parse calling arguments
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    NSString *method = [NSString stringWithFormat:@"nativeCall_%@", [(NSString*)[components objectAtIndex:1] stringByAppendingString:@":"]];
    
    //step 2. perpare the call
    if([bridgedWebview.nativeDelegate respondsToSelector:NSSelectorFromString(method)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NativeContext *context = [[NativeContext alloc] initWithWebview:bridgedWebview];
        context.callback = [((NSString*)[components objectAtIndex:2]) integerValue];
        context.params = [NSJSONSerialization JSONObjectWithData:[[[components objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        
        [bridgedWebview.nativeDelegate performSelector:NSSelectorFromString(method) withObject:context];
#pragma clang diagnostic pop
    }
    else{
        NSLog(@"unknown native call: %@", method);
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if(![webView isKindOfClass:CCWebView.class])
        return;
    
    CCWebView *bridgedWebview = (CCWebView *)webView;
    if(!bridgedWebview.nativeDelegate)
        return;
    
    if([bridgedWebview.nativeDelegate respondsToSelector:@selector(onWebviewStartLoad:)])
        [bridgedWebview.nativeDelegate performSelector:@selector(onWebviewStartLoad:) withObject:bridgedWebview];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    if(![webView isKindOfClass:CCWebView.class])
        return;
	   
    CCWebView *bridgedWebview = (CCWebView *)webView;
    if(!bridgedWebview.nativeDelegate)
        return;
    
    if([bridgedWebview.nativeDelegate respondsToSelector:@selector(onWebviewDocumentReady:)])
        [bridgedWebview.nativeDelegate performSelector:@selector(onWebviewDocumentReady:) withObject:bridgedWebview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(![webView isKindOfClass:CCWebView.class])
        return;
    
    CCWebView *bridgedWebview = (CCWebView *)webView;
    if(!bridgedWebview.nativeDelegate)
        return;
    
    if (error.code == -999) {
        return;
    }
    
    if([bridgedWebview.nativeDelegate respondsToSelector:@selector(onWebviewLoadFailed:)])
        [bridgedWebview.nativeDelegate performSelector:@selector(onWebviewLoadFailed:) withObject:bridgedWebview];
}
@end

#pragma mark - NativeContext
@implementation NativeContext
- (id)initWithWebview:(CCWebView *)webview
{
    self = [super init];
    if(self){
        self.webview = webview;
    }
    return self;
}

@end

#pragma mark - UIBridgedWebView
@interface CCWebView()
{
    WebviewDelegate *_webviewDelegate;
}
@end

@implementation CCWebView
- (void)awakeFromNib
{
    _webviewDelegate = [[WebviewDelegate alloc] init];
    self.delegate = _webviewDelegate;
    self.scrollView.scrollEnabled = NO;
    self.dataDetectorTypes = 0;
    self.scrollView.bounces = NO;
}

- (NSDictionary *)webViewCall:(NSString *)method withParams:(NSDictionary *)params
{
    NSString *javascript = [NSString stringWithFormat:@"WebviewBridge.%@(%@)", method, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding]];
    NSString *resultString = [self stringByEvaluatingJavaScriptFromString:javascript];
    if(resultString.length > 0){
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[[resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        return result;
    }
    return nil;
}

- (void)webViewReturn:(NSInteger)callback withParams:(NSDictionary *)params
{
    NSString *javascript = [NSString stringWithFormat:@"NativeBridge.returnFromNative(%ld, %@)", (long)callback, [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:0 error:nil] encoding:NSUTF8StringEncoding]];
    [self stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)loadLocalFile:(NSString *)name withParams:(NSString *)params
{
    NSString *localUrl = [[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", name] ofType:@"html"]] absoluteString];
    if(params){
        localUrl = [localUrl stringByAppendingString:@"#"];
        localUrl = [localUrl stringByAppendingString:params];
    }
    
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:localUrl]]];
}

- (void)loadRemoteFile:(NSString *)host withPath:(NSString *)path
{
    if (!host || [host isEqual:@""]) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]]];
    }else if([path hasPrefix:@"http://"]){
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", path]]]];
    }else{
        if ([path hasPrefix:@"/"]) {
            [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", host, path]]]];
        }else {
            [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", host, path]]]];
        }
    }
}
@end
