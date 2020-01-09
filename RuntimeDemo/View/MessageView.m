//
//  MessageView.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2020/1/2.
//  Copyright © 2020 贺文杰. All rights reserved.
//

#import "MessageView.h"
#import <objc/runtime.h>
#import "NormalForwarding.h"

@implementation MessageView

//- (void)beginMessage
//{
//    NSLog(@"大明风华");
//}

void replaceBegin(id self, SEL _cmd){
    NSLog(@"修真聊天群");
    [self signatureAction];
}

/*
    消息转发的3次求救机会
    1.resolveInstanceMethod
    2.forwardingTargetForSelector
    3.methodSignatureForSelector,forwardInvocation
    
    1.先查询消息接收者所属的类，看是否能动态添加方法，以处理当前这个无法响应的selecto,如果第一阶段执行结束，接收者就无法再以动态新增方法来响应消息，进入第二阶段
    2.看看有没有其他的备用接收者能处理此消息，如果有，运行时系统会把消息发给那个对象，转发过程结束，如果没有，则启动完整的消息转发机制。
    3.完整的消息转发机制，运行时系统会把与消息有关的全部细节封装到NSInvocation对象中，令其设法解决当前还未处理的消息。
 */

#pragma mark -- 消息转发机制 第1阶段: 动态消息解析
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"%s", __FUNCTION__);
    if (sel == @selector(beginMessage)) {
        /*
            拦截，并实现方法
            两种实现方式
         */
//        class_addMethod([self class], sel, imp_implementationWithBlock(^(id self){
//            NSLog(@"我代替你了");
//        }), "v@:"); //第一种
        class_addMethod([self class], sel, (IMP)replaceBegin, "v@:"); //第二种
        //如果没有实现对应的实例方法，那么返回NO或者[super resolveInstanceMethod:sel]，都会进入第2阶段：快速转发
        return [super resolveInstanceMethod:sel];
    }
    return [super resolveInstanceMethod:sel];
}

#pragma mark -- 消息转发机制 第2阶段: 快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"%s", __FUNCTION__);
    if ([NSStringFromSelector(aSelector) isEqualToString:@"beginMessage"]) {
        //拦截，并实现方法
//        return [NormalForwarding new];
        //如果返回nil或者[super forwardingTargetForSelector:aSelector]，那么进入第3阶段:正常转发
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark -- 消息转发机制 第3阶段: 正常转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSLog(@"%s", __FUNCTION__);
    //NSMethodSignatures是方法签名类，协同NSInvocation来进行消息转发
    if ([NSStringFromSelector(aSelector) isEqualToString:@"beginMessage"]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }

    //如果返回为nil，消息即无法处理并报错unrecognized selector sent to instance,如果返回NSMethodSignature,则进入forwardInvocation
    return nil;
}

//在这里修改实现方法、修改响应对象,如果依然不能正确响应消息，则报错unrecognized selector sent to instance/class
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
//    NormalForwarding *nr = [NormalForwarding new];
//    [nr methodCrashHanding:anInvocation];
    NSLog(@"%s %@", __FUNCTION__, NSStringFromSelector([anInvocation selector]));
    //在这里对崩溃的方法进行最后一次拦截
//    if ([NSStringFromSelector([anInvocation selector]) isEqualToString:@"beginMessage"]) {
//        [anInvocation invokeWithTarget:[NormalForwarding new]];
//    }
    //如果在这之前都没有对崩溃的方法进行实现却又调了父类的forwardInvocation，又没有实现doesNotRecognizeSelector,那么就会报错unrecognized selector sent to instance
    [super forwardInvocation:anInvocation];
}

//若forwardInvocation没有实现，则会调用此方法,可以在这里抛出异常
- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    NSLog(@"%s 消息无法处理", __FUNCTION__);
}

#pragma mark -- NSMethodSignature和NSInvocation的基本使用
- (void)signatureAction
{
    NSMethodSignature *signature = [MessageView instanceMethodSignatureForSelector:@selector(fly:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //设置方法调用者
    invocation.target = self;
    //这里的方法名必须与方法签名类中的方法一致
    invocation.selector = @selector(fly:);
    NSString *str = @"知否知否应是绿肥红瘦";
    //默认0是self(target),1是selector(_cmd)
    [invocation setArgument:&str atIndex:2];
    [invocation invoke];
}

- (void)fly:(NSString *)string
{
    NSLog(@"%s ssss = %@", __FUNCTION__, string);
}

@end
