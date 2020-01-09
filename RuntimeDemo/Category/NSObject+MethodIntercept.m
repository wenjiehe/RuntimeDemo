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

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NormalForwarding *nr = [NormalForwarding new];
    [nr methodCrashHanding:anInvocation];
}


@end
