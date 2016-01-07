//
//  CommonWeb.h
//  CarCalc
//
//  Copyright © 2016年 Vanchu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCWebView.h"

@interface CommonWeb : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *naviTitle;
@property (weak, nonatomic) IBOutlet CCWebView *webView;

@property (strong, nonatomic) NSString *dataTitle;
@property (strong, nonatomic) NSString *dataUrl;

- (void) setTitle:(NSString *)title andUrl:(NSString *)url;
- (void) setHeader:(NativeContext *)context;

@end
