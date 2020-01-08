//
//  NSObject+MethodIntercept.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/8.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "NSObject+MethodIntercept.h"
#import "NormalForwarding.h"

@implementation NSObject (MethodIntercept)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
//    NSLog(@"%s sel = %@", __FUNCTION__, NSStringFromSelector(sel));
    return YES;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"%s sel = %@", __FUNCTION__, NSStringFromSelector(aSelector));
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"%s sel = %@", __FUNCTION__, NSStringFromSelector(aSelector));
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NormalForwarding *nr = [NormalForwarding new];
    [nr methodCrashHanding:anInvocation];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector([anInvocation selector]));
}

//若forwardInvocation没有实现，则会调用此方法
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"%s %@ 消息无法处理", __FUNCTION__, NSStringFromSelector(aSelector));
}


@end
