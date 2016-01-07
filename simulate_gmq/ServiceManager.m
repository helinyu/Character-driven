//
//  ServiceManager.m
//  simulate_gmq
//
//  Created by felix on 16/1/6.
//  Copyright © 2016年 felix. All rights reserved.
//

#import "ServiceManager.h"
#import "RestService.h"


@interface ServiceManager ()
{
    NSMutableDictionary *_serviceMap;
}

@end

@implementation ServiceManager


+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static ServiceManager *thiz;
    dispatch_once(&onceToken, ^{
        thiz = [ServiceManager new];
    });
    return thiz;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serviceMap = [NSMutableDictionary new];
    }
    return self;
}

- (id)instantiateAServiceWithClass:(Class)class{
    RestService *service = [_serviceMap objectForKey:NSStringFromClass(class)];
    if (!service) {
        service = [class new];
        [_serviceMap setObject:service forKey:NSStringFromClass(class)];
    }
    return service;
}



@end
