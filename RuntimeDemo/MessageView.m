//
//  MessageView.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/2.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "MessageView.h"


@implementation MessageView

- (void)beginMessage
{
    NSLog(@"大明风华");
}

+ (void)endMessage
{
    NSLog(@"知否知否应是绿肥红瘦");
}

#pragma mark -- 消息转发机制 第1阶段: 动态消息解析
+ (BOOL)resolveClassMethod:(SEL)sel
{
    NSLog(@"%s", __FUNCTION__);
    return [super resolveClassMethod:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSLog(@"%s", __FUNCTION__);
    if (aSelector) {
        return YES;
    }
    return NO;
}

#pragma mark -- 消息转发机制 第2阶段: 快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"%s", __FUNCTION__);
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark -- 消息转发机制 第3阶段: 正常转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"%s", __FUNCTION__);
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    //如果methodSignature为nil，消息即无法处理
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"%s", __FUNCTION__);
}

@end
