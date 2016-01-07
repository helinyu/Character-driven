//
//  ServiceManager.h
//  simulate_gmq
//
//  Created by felix on 16/1/6.
//  Copyright © 2016年 felix. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OBTAIN_SERVICE(classname) (classname *)[[ServiceManager shareInstance]initAServiceWithClass:classname.class]


@interface ServiceManager : NSObject

+ (instancetype)shareInstance;

- (id)instantiateAServiceWithClass:(Class)class;

@end
