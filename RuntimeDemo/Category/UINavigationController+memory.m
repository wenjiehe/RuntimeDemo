//
//  UINavigationController+memory.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/8.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "UINavigationController+memory.h"
#import <objc/runtime.h>
#import "AppManager.h"

@implementation UINavigationController (memory)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self vcSwizzleInstanceSel:NSSelectorFromString(@"dealloc") withNewSel:NSSelectorFromString(@"customNavDealloc")];
        [self vcSwizzleInstanceSel:NSSelectorFromString(@"pushViewController:animated:") withNewSel:NSSelectorFromString(@"customNavPushViewController:animated:")];
    });
}

+ (void)vcSwizzleInstanceSel:(SEL)oldSel withNewSel:(SEL)newSel {
    Class class = self.class;
    Method oldM = class_getInstanceMethod(class, oldSel);
    Method newM = class_getInstanceMethod(class, newSel);
    BOOL didAdd = class_addMethod(class, oldSel, method_getImplementation(newM), method_getTypeEncoding(newM));
    if (didAdd) {
        class_replaceMethod(class, newSel, method_getImplementation(oldM), method_getTypeEncoding(oldM));
    }
    else {
        method_exchangeImplementations(oldM, newM);
    }
}

#pragma mark -- 利用runtime实现记录哪些ViewController没有释放dealloc
- (void)customNavDealloc
{
    NSLog(@"%s %@", __FUNCTION__, NSStringFromClass(self.class));
    if ([[AppManager sharedInstance].vcMtbAry containsObject:NSStringFromClass(self.class)]) {
        [[AppManager sharedInstance].vcMtbAry removeObject:NSStringFromClass(self.class)];
    }
    [self customNavDealloc];
}

- (void)customNavPushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s %@", __FUNCTION__, NSStringFromClass(viewController.class));
    [[AppManager sharedInstance].vcMtbAry addObject:NSStringFromClass(viewController.class)];
    [self customNavPushViewController:viewController animated:animated];
}



@end
