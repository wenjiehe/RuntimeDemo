//
//  AppManager.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/8.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "AppManager.h"

@interface AppManager ()


@end

@implementation AppManager

+ (instancetype)sharedInstance
{
    static AppManager *sharedInstance = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[AppManager alloc] init];
    });
    return sharedInstance;
}

- (NSMutableArray *)vcMtbAry
{
    if (!_vcMtbAry) {
        _vcMtbAry = [NSMutableArray new];
    }
    return _vcMtbAry;
}

@end
