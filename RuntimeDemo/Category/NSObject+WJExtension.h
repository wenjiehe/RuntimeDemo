//
//  NSObject+WJExtension.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (WJExtension)

/// 字典转模型
/// @param keyValues 数据
+ (id)objectChangeValue:(id)keyValues;

/// 模型转字典
/// @param model 模型
+ (id)valueWithObject:(id)model;

+ (NSDictionary *)customKeyValue;

@end

NS_ASSUME_NONNULL_END
