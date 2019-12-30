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

+ (id)objectChangeValue:(id)keyValues;

+ (NSDictionary *)customKeyValue;

@end

NS_ASSUME_NONNULL_END
