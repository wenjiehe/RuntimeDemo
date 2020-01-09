//
//  NormalForwarding.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/7.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "NormalForwarding.h"

@implementation NormalForwarding

- (void)methodCrashHanding:(NSInvocation *)invocation
{
    NSLog(@"NormalForwarding---在类:%@中 未实现该方法:%@",NSStringFromClass([invocation.target class]),NSStringFromSelector(invocation.selector));
    if ([NSStringFromSelector([invocation selector]) isEqualToString:@"beginMessage"]) {
        [self like];
    }
}

- (void)beginMessage
{
    NSLog(@"星辰变");
}

- (void)like
{
    NSLog(@"名侦探柯南");
}


@end
