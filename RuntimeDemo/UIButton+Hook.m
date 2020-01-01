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
/*
    +load方法是当类或分类被添加到Objective-C runtime时被调用的
    只调用一次
    不能使用Super且不沿用父类实现
 */
+ (void)load{
    /*
        swizzling会改变全局状态，所以使用dispatch_once就能够保证代码只被执行一次
        在+load中执行时，不要调用[super load]，会导致父类的swizzling失效
     */
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
    
    /*
        为什么这里需要调用mySendAction:to:forEvent:，是因为已经和sendAction:to:forEvent:互换了，如果你在这里调用sendAction:to:forEvent:就会引发死循环。
     */
    [self mySendAction:action to:target forEvent:event];
}

#pragma mark -- 在类别中添加属性
static const char kName;

- (NSString *)channel
{
    return objc_getAssociatedObject(self, &kName);
}

/*
 OBJC_ASSOCIATION_ASSIGN = 0,           weak,assign
 OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, strong,nonatomic
 OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   copy,nonatomic
 OBJC_ASSOCIATION_RETAIN = 01401,       strong,atomic
 OBJC_ASSOCIATION_COPY = 01403          copy,atomic
 */
- (void)setChannel:(NSString *)channel
{
    objc_setAssociatedObject(self, &kName, channel, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
