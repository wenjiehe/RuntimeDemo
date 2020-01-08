//
//  UIViewController+memory.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/8.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "UIViewController+memory.h"
#import <objc/runtime.h>

@implementation UIViewController (memory)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self vcSwizzleInstanceSel:NSSelectorFromString(@"dealloc") withNewSel:NSSelectorFromString(@"customVCDealloc")];
        [self vcSwizzleInstanceSel:NSSelectorFromString(@"customPresentViewController:animated:completion:") withNewSel:NSSelectorFromString(@"presentViewController:animated:completion:")];
    });
}

+ (void)vcSwizzleInstanceSel:(SEL)oldSel withNewSel:(SEL)newSel {
    Class class = UIViewController.class;
    Method oldM = class_getInstanceMethod(class, oldSel);
    Method newM = class_getInstanceMethod(class, newSel);
    BOOL didAdd = class_addMethod(class, oldSel, method_getImplementation(newM), method_getTypeEncoding(newM));
    if (didAdd) {
        class_replaceMethod(class, newSel, method_getImplementation(oldM), method_getTypeEncoding(oldM));
    }else {
        method_exchangeImplementations(oldM, newM);
    }
}

- (void)customVCDealloc
{
    NSLog(@"%s %@", __FUNCTION__, NSStringFromClass(self.class));
    [self customVCDealloc];
}

- (void)customPresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSLog(@"%s %@", __FUNCTION__, NSStringFromClass(viewControllerToPresent.class));
    [self customPresentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
