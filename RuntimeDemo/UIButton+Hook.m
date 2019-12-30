//
//  UIButton+Hook.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "UIButton+Hook.h"
#import <objc/runtime.h>

static NSInteger kCount = 0;

@implementation UIButton (Hook)

#pragma mark -- 拦截方法，并为按钮点击方法增加计数功能
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = [self class];
        SEL actionSEL = @selector(sendAction:to:forEvent:);
        Method actionMethod = class_getInstanceMethod(selfClass, actionSEL);
        SEL cusSEL = @selector(mySendAction:to:forEvent:);
        Method myActionMethod = class_getInstanceMethod(selfClass, cusSEL);
        
        BOOL addSucc = class_addMethod(selfClass, actionSEL, method_getImplementation(myActionMethod), method_getTypeEncoding(myActionMethod));
        if (addSucc) {
            class_replaceMethod(selfClass, cusSEL, method_getImplementation(actionMethod), method_getTypeEncoding(actionMethod));
        }else{
            method_exchangeImplementations(actionMethod, myActionMethod);
        }
    });
}

- (void)mySendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    kCount++;
    NSLog(@"count = %ld", kCount);
    [self mySendAction:action to:target forEvent:event];
}

@end
