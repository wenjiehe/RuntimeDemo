//
//  NormalForwarding.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/7.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NormalForwarding : NSObject

- (void)methodCrashHanding:(NSInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
