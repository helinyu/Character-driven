//
//  BasicController.h
//  simulate_gmq
//
//  Created by felix on 16/1/6.
//  Copyright © 2016年 felix. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicController : UIViewController

@property (assign , nonatomic) BOOL shouldDisPlayStatusBar;//是否显示statusBar
@property (assign , nonatomic) BOOL shouldDdisplayNaivgaitonBar; //是否显示navigationBar
@property (assign , nonatomic) BOOL shouldAnimateNavigationBar;//是否显示navigationBar的动画


- (void)viewFirstWillAppear; //第一次将会系那是
- (void)viewFirstWillLayoutSubviews; //布局子视图
- (void)viewFirstDidLayoutSubviews;
- (BOOL)hasGuideView;
- (void)guideViewclose;

@end
