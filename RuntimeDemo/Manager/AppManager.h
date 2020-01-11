//
//  AppManager.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/8.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppManager : NSObject

@property(nonatomic,strong)NSMutableArray *vcMtbAry; //存储没有释放dealloc的vc

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
