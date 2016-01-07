//
//  CCWebView.h
//  CarCalc
//
//  Created by helen on 16/1/4.
//  Copyright © 2016年 Vanchu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCWebView;

#pragma mark - NativeDelegate
@protocol NativeDelegate<NSObject>
@optional
- (void)onWebviewStartLoad:(CCWebView *)webview;
@optional
- (void)onWebviewDocumentReady:(CCWebView *)webview;
@optional
- (void)onWebviewLoadFailed:(CCWebView *)webview;
@end

#pragma mark - NativeContext
@interface NativeContext : NSObject
@property (strong, nonatomic) CCWebView *webview;
@property (strong, nonatomic) NSDictionary* params;
@property (assign, nonatomic) NSInteger callback;

- (id)initWithWebview:(CCWebView *)webview;
@end

#pragma mark - GMWebView
@interface CCWebView : UIWebView
@property (weak, nonatomic) id<NativeDelegate> nativeDelegate;

- (NSDictionary *)webViewCall:(NSString *)method withParams:(NSDictionary *)params;
- (void)webViewReturn:(NSInteger)callback withParams:(NSDictionary *)params;

- (void)loadLocalFile:(NSString *)name withParams:(NSString *)params;
- (void)loadRemoteFile:(NSString *)host withPath:(NSString *)path;

@end
