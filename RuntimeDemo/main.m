//
//  main.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/4.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MessageView.h"
#import <dlfcn.h>

//instrumentObjcMessageSends的实现函数在objc-class.mm中,开启之后Log日志放在硬盘/private/tmp/msgSends-%d,%d是进程pid
//打开文件可以看到消息转发调用的方法流程
//extern void instrumentObjcMessageSends(BOOL);

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        instrumentObjcMessageSends(YES);
        MessageView *m = [[MessageView alloc] init];
        [m beginMessage];
//        instrumentObjcMessageSends(NO);
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
