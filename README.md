# Runtime入门

## 编译环境

* Xcode 11.3
* Mac OS 10.15.1

## 简介

>   Objective-C是一门动态语言，它会将一些工作放在代码运行时才处理而并非编译时，所以只有编译器是不够的，还需要一个运行时系统(runtime system)来执行编译后的代码。Runtime 又叫运行时，是一套底层的 C 语言 API，其为 iOS 内部的核心之一，我们平时编写的 OC 代码，底层都是基于它来实现的。runtime其实有两个版本:"modern"和"legacy"。我们现在用的Objective-C 2.0采用的是Modern版的runtime系统，只能运行在iOS和macOS 10.5之后的64位程序中。而较早的32位程序使用Legacy版本的runtime系统，这两个版本最大的区别在于当你更改一个类的实例变量的布局时，在Legacy版本中你需要重新编译它的子类，而Modern版本就不需要。

* Runtime的作用

`Objective-C`在三种层面上与 `Runtime` 系统进行交互:

1. 通过 `Objective-C` 源代码
2. 通过 `Foundation` 框架的 `NSObject` 类定义的方法
3. 通过对 `Runtime` 库函数的直接调用

* 如何把代码转换为`runtime`的实现

打开终端，使用命令`clang -rewrite-objc main.m`对实现文件转换为`.cpp`文件，就可以看到实现文件的源码，关于[clang](http://clang.llvm.org/docs/),例如:

```Objective-C
//main.m文件
#import <Foundation/Foundation.h>
#import "People.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        People *pe = [[People alloc] init];
        [pe book];
    }
    return 0;
}
```
```C++
//main.cpp文件
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        People *pe = ((People *(*)(id, SEL))(void *)objc_msgSend)((id)((People *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("People"), sel_registerName("alloc")), sel_registerName("init"));
        ((void (*)(id, SEL))(void *)objc_msgSend)((id)pe, sel_registerName("book"));
    }
    return 0;
}
```

当一个对象调用方法`[pe book]`;的时候，实际上是调用了`runtime`的`objc_msgSend`函数，它的原型为:`id objc_msgSend(id self, SEL _cmd, ...)`,`self`与`_cmd`是默认隐藏的参数，`self`是一个指向接收对象的指针，`_cmd`为方法选择器,这个函数的实现为汇编版本,可以在`objc-msg-arm/arm64/i386/x86_64/simulator-i386/simulator-x86_64.s`中查看汇编代码的实现

* 为什么使用汇编语言

 选取`objc-msg-arm64.s`部分代码，在`objc-msg-arm64.s`文件中包含了多个版本的`objc_msgSend`方法，它们是根据返回值的类型和调用者的类型分别处理的,当需要发送消息时，编译器会生成中间代码，根据情况分别调用其中之一。

    - objc_msgSend:返回值类型为id
    - objc_msgSend_stret:返回值类型为结构体
    - objc_msgSendSuper:向父类发消息，返回值类型为id
    - objc_msgSendSuper_stret:向父类发消息，返回值类型为结构体

objc_msgSend的汇编部分代码:

```Objective-C
#if SUPPORT_TAGGED_POINTERS
    .data
    .align 3
    .globl _objc_debug_taggedpointer_classes
_objc_debug_taggedpointer_classes:
    .fill 16, 8, 0
    .globl _objc_debug_taggedpointer_ext_classes
_objc_debug_taggedpointer_ext_classes:
    .fill 256, 8, 0
#endif

    ENTRY _objc_msgSend
    UNWIND _objc_msgSend, NoFrame

    cmp    p0, #0            // nil check and tagged pointer check
#if SUPPORT_TAGGED_POINTERS
    b.le    LNilOrTagged        //  (MSB tagged pointer looks negative)
#else
    b.eq    LReturnZero
#endif
    ldr    p13, [x0]        // p13 = isa
    GetClassFromIsa_p16 p13        // p16 = class
```
`SUPPORT_TAGGED_POINTERS`的定义在`objc-config.h`文件中可以看到，只存在于64位架构，当OC版本为2.0版本时，并开始使用`64`位架构的处理器。别名为[Taggedpointer](https://www.jianshu.com/p/01153d2b28eb),是苹果为了在`64`位架构的处理器下节省内存和提高执行效率而提出的概念。

可以看到`LNilOrTagged`如果不为`nil`那么最后调用了`LGetIsaDone`，`LGetIsaDone`调用了`CacheLookup NORMAL`,当`CacheLookup NORMAL`如果返回`objc_msgSend_uncached`时，调用了`MethodTableLookup`，接着调用了`__class_lookupMethodAndLoadCache3`(这是runtime方法)
```Objective-C
//lookUpImpOrForward调用时使用缓存参数传入为NO,因为之前已经尝试过查找缓存，
IMP _class_lookupMethodAndLoadCache3(id obj, SEL sel, Class cls)
{
    return lookUpImpOrForward(cls, sel, obj, 
                              YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
}
```

`lookUpImpOrForward`做了两件事：
1. 如果`cache`参数为`YES`,那就调用`cache_getImp`,获取到`imp`,方法结束
2. 如果`initialize`参数为`YES`并且`cls->isInitialized()`为`NO`,那么进行初始化工作，开辟一个用于读写数据的空间

当`lookUpImpOrForward`的参数`resolver`为`YES`时，进入动态方法解析。调用了`_class_resolveMethod`,`_class_resolveMethod`方法中判断类是否是元类，解析实例方法和解析类方法，如果动态解析实例方法不起作用，走消息转发，会调用到`_objc_msgForward_impcache`，接着转入`objc-msg-arm64.s`中调用`__objc_msgForward`，汇编代码中看到调用了`__objc_forward_handler`，然后又转入`objc-runtime.mm`调用了`void *_objc_forward_handler = (void*)objc_defaultForwardHandler;`这里我们就可以看到`objc_defaultForwardHandler`里面那句熟悉的`unrecognized selector sent to instance`
```Objective-C
#if !__OBJC2__

// Default forward handler (nil) goes to forward:: dispatch.
void *_objc_forward_handler = nil;
void *_objc_forward_stret_handler = nil;

#else

// Default forward handler halts the process.
__attribute__((noreturn)) void 
objc_defaultForwardHandler(id self, SEL sel)
{
    //打日志触发crash
    _objc_fatal("%c[%s %s]: unrecognized selector sent to instance %p "
                "(no message forward handler is installed)", 
                class_isMetaClass(object_getClass(self)) ? '+' : '-', 
                object_getClassName(self), sel_getName(sel), self);
}
void *_objc_forward_handler = (void*)objc_defaultForwardHandler;

#if SUPPORT_STRET
struct stret { int i[100]; };
__attribute__((noreturn)) struct stret 
objc_defaultForwardStretHandler(id self, SEL sel)
{
    objc_defaultForwardHandler(self, sel);
}
void *_objc_forward_stret_handler = (void*)objc_defaultForwardStretHandler;
#endif

void objc_setForwardHandler(void *fwd, void *fwd_stret)
{
    _objc_forward_handler = fwd;
#if SUPPORT_STRET
    _objc_forward_stret_handler = fwd_stret;
#endif
}
```
我们想要实现消息转发，就需要替换掉`Handler` 并赋值给`_objc_forward_handler` 或 `_objc_forward_handler_stret`，赋值的过程就需要用到 `objc_setForwardHandler` 函数。


## 消息转发机制

![动态方法解析流程](https://github.com/wenjiehe/RuntimeDemo/blob/master/RuntimeDemo/objective-runtime.png)

1. 通过`resolveInstanceMethod`得知方法是否为动态添加，`YES`则通过`class_addMethod`动态添加方法，处理消息，否则进入下一步。
2. `forwardingTargetForSelector`用于指定哪个对象来响应消息。如果不为nil就把消息原封不动的转发给目标对象，如果返回`nil`则进入`methodSignatureForSelector`。
3.  `methodSignatureForSelector`进行方法签名，可以将函数的参数类型和返回值封装。如果返回nil说明消息无法处理并报错` unrecognized selector sent to instance`，如果返回 `methodSignature`，则进入 `forwardInvocation`。
4. `forwardInvocation`,在这个方法里面可以响应消息，如果依然不能正确响应消息，则报错 `unrecognized selector sent to instance`，如果在这方法里面不做任何事，却又调用了`[super forwardInvocation:anInvocation]`;,那么就进入了`doesNotRecognizeSelector`
5. `doesNotRecognizeSelector`方法


* 快速转发：Fast Rorwarding
> 快速转发只要重载forwardingTargetForSelector方法,这个方法只能转发给一个对象

* 完整消息转发：Normal Forwarding
> 完整消息转发需要重载methodSignatureForSelector和forwardInvocation方法，forwardInvocation能转发给多个对象

## API介绍

```Objective-C

//获取成员变量列表
Ivar *class_copyIvarList(Class cls, unsigned int *outCount);
//获取变量名称
const char * ivar_getName(Ivar v);
//获取变量类型
const char * ivar_getTypeEncoding(Ivar v);

//获取属性列表
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount);
//获取属性名称
const char * property_getName(objc_property_t property);

//获取类名
const char *class_getName(Class cls);
//为类添加成员变量
BOOL class_addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types);
//从类中获取成员变量Ivar
Ivar class_getInstanceVariable(Class cls, const char *name);
//为类的实例的成员变量赋值
void object_setIvar(id obj, Ivar ivar, id value);
//为类添加新的方法，如果该方法已存在则返回NO
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
//获取类中的某个实例方法(减号方法)
Method class_getInstanceMethod(Class cls, SEL name);
//获取类中的某个类方法(加号方法)
Method class_getClassMethod(Class cls, SEL name);
//获取类中的方法列表
Method *class_copyMethodList(Class cls, unsigned int *outCount);
//替换类中已有方法的实现，如果该方法不存在则添加该方法
IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types);
//获取类中的方法实现
IMP class_getMethodImplementation(Class cls, SEL name);
//获取类中的方法实现，该方法的返回值类型为struct
IMP class_getMethodImplementation_stret(Class cls, SEL name);
//判断类中是否包含某个方法的实现
BOOL class_respondsToSelector(Class cls, SEL sel);

//获取Method中的SEL
SEL method_getName(Method m);
//获取Method中的IMP
IMP method_getImplementation(Method m);
//获取方法的Type字符串（包含参数类型和返回值类型）
const char *method_getTypeEncoding(Method m);
//获取参数个数
unsigned int method_getNumberOfArguments(Method m);
//获取返回值类型字符串
char *method_copyReturnType(Method m);
//获取Method的描述
struct objc_method_description * method_getDescription(Method m);
//设置Method的IMP
IMP method_setImplementation(Method m, IMP imp);
//替换Method
void method_exchangeImplementations(Method m1, Method m2);

//获取SEL的名称
const char * sel_getName(SEL sel);
//注册一个SEL
SEL sel_registerName(const char *str);
//判断两个SEL对象是否相同
BOOL sel_isEqual(SEL lhs, SEL rhs);

//通过块创建函数指针，block的形式为returnType^(id self, self, method_args …)
IMP imp_implementationWithBlock(id block);
//获取IMP中的block
id imp_getBlock(IMP anImp);
//移除IMP中的block
BOOL imp_removeBlock(IMP anImp);

//创建一个类，继承自superclass
Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes);
//销毁类
void objc_disposeClassPair(Class cls);
//注册一个类
void objc_registerClassPair(Class cls);

// 添加协议
BOOL class_addProtocol ( Class cls, Protocol *protocol );
// 返回类是否实现指定的协议
BOOL class_conformsToProtocol ( Class cls, Protocol *protocol );
// 返回类实现的协议列表
Protocol * class_copyProtocolList ( Class cls, unsigned int *outCount );

// 返回指定的协议
Protocol * objc_getProtocol ( const char *name );
// 获取运行时所知道的所有协议的数组
Protocol ** objc_copyProtocolList ( unsigned int *outCount );
// 创建新的协议实例
Protocol * objc_allocateProtocol ( const char *name );
// 在运行时中注册新创建的协议
void objc_registerProtocol ( Protocol *proto ); //创建一个新协议后必须使用这个进行注册这个新协议，但是注册后不能够再修改和添加新方法。

// 为协议添加方法
void protocol_addMethodDescription ( Protocol *proto, SEL name, const char *types, BOOL isRequiredMethod, BOOL isInstanceMethod );
// 添加一个已注册的协议到协议中
void protocol_addProtocol ( Protocol *proto, Protocol *addition );
// 为协议添加属性
void protocol_addProperty ( Protocol *proto, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty );
// 返回协议名
const char * protocol_getName ( Protocol *p );
// 测试两个协议是否相等
BOOL protocol_isEqual ( Protocol *proto, Protocol *other );
// 获取协议中指定条件的方法的方法描述数组
struct objc_method_description * protocol_copyMethodDescriptionList ( Protocol *p, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount );
// 获取协议中指定方法的方法描述
struct objc_method_description protocol_getMethodDescription ( Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod );
// 获取协议中的属性列表
objc_property_t * protocol_copyPropertyList ( Protocol *proto, unsigned int *outCount );
// 获取协议的指定属性
objc_property_t protocol_getProperty ( Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty );
// 获取协议采用的协议
Protocol ** protocol_copyProtocolList ( Protocol *proto, unsigned int *outCount );
// 查看协议是否采用了另一个协议
BOOL protocol_conformsToProtocol ( Protocol *proto, Protocol *other );

```

## 使用

> 在当前ViewController使用导入#import <objc/runtime.h>

## 应用

> xcode中使用shift+command+0,选择Objective-C点击目录列表中的Objective-C Runtime->Reference->Objective-C Runtime，可以看到所有api

1. 获取成员变量列表

```Objective-C
- (void)getIvarList
{
    unsigned int count = 0;
    Ivar *ivar = class_copyIvarList([self.sv class], &count);
    for (NSInteger i = 0; i < count; i++) {
        Ivar *var = &ivar[i];
        const char *varName = ivar_getName(*var);
        NSString *ivarName = [NSString stringWithUTF8String:varName]; //获取变量名称
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(*var)]; //获取变量类型
        NSLog(@"ivarName = %@, ivarType = %@", ivarName, ivarType);
    }
}
```

2. 获取方法列表

```Objective-C
- (void)getMethodList
{
    unsigned int count = 0;
    Method *methodList = class_copyMethodList([self.sv class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
    }
}
```

3. 获取属性列表

```Objective-C
- (void)getPropertyList
{
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self.sv class], &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        NSLog(@"propertyName---->%@", [NSString stringWithUTF8String:propertyName]);
    }
}
```

4. 动态变量控制
```Objective-C
- (void)dynamicChangeIvar
{
    NSLog(@"befroe age = %@", self.sv.getAge);
    unsigned int count = 0;
    //获取成员变量列表
    Ivar *ivar = class_copyIvarList([self.sv class], &count);
    for (NSInteger i = 0; i < count; i++) {
        Ivar *var = &ivar[i];
        const char *varName = ivar_getName(*var);
        NSString *ivarName = [NSString stringWithUTF8String:varName]; //获取变量名称
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(*var)]; //获取变量类型
        NSLog(@"ivarName = %@, ivarType = %@", ivarName, ivarType);
        if ([ivarName isEqualToString:@"_age"]) {
            object_setIvar(self.sv, *var, @"30");
        }
    }
    NSLog(@"after age = %@", self.sv.getAge);
}
```

5. 动态添加方法

```Objective-C
- (void)dynamicAddMethod
{
    class_addMethod([self.sv class], @selector(look:), (IMP)lookImp, "v@:");
    if ([self.sv respondsToSelector:@selector(look:)]) {
        [self.sv performSelector:@selector(look:) withObject:@{@"age" : @"22", @"sex" : @"man"}];
    }else{
        NSLog(@"error:not found method");
    }
}
```

6. 动态交换两个方法的实现

```Objective-C
- (void)dynamicReplaceMethod
{
    NSLog(@"%s", __FUNCTION__);
    Method m1 = class_getInstanceMethod([DescriptionViewController class], @selector(viewDidAppear:));
    Method m2 = class_getInstanceMethod([DescriptionViewController class], @selector(customDidAppear:));
    method_exchangeImplementations(m1, m2);
}

- (void)customDidAppear:(BOOL)animated
{
    NSLog(@"%s", __FUNCTION__);
    [self customDidAppear:animated];
}
```

7. 拦截并替换方法

```Objective-C
- (void)swizzleInstanceSel:(SEL)oldSel withNewSel:(SEL)newSel {
    Class class = SurprisedView.class;
    Method oldM = class_getInstanceMethod(class, oldSel);
    Method newM = class_getInstanceMethod(DescriptionViewController.class, newSel);
    BOOL didAdd = class_addMethod(class, oldSel, method_getImplementation(newM), method_getTypeEncoding(newM));
    if (didAdd) {
        NSLog(@"swizzleInstanceSel * didAdd");
        class_replaceMethod(class, newSel, method_getImplementation(oldM), method_getTypeEncoding(oldM));
    }
    else {
        NSLog(@"swizzleInstanceSel * didn'tAdd ----> exchange!");
        method_exchangeImplementations(oldM, newM);
    }
}
```

8. 自动归档和解档

```Objective-C
- (void)automicKeyedArchiver
{
    self.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.path = [self.path stringByAppendingString:@"/data.archiver"];
    
    User *user = [User new];
    user.name = @"范闲";
    user.age = @"20";
    user.sex = @"男";
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user requiringSecureCoding:YES error:nil];
    BOOL isSucc = [[NSFileManager defaultManager] createFileAtPath:self.path contents:data attributes:nil];
    if (isSucc) {
        NSLog(@"存入文件成功");
    }
}

- (void)automicKeyedUnarchiver
{
    NSData *data = [NSData dataWithContentsOfFile:self.path];
    
    User *user = [NSKeyedUnarchiver unarchivedObjectOfClass:[User class] fromData:data error:nil];
    NSLog(@"%s user = %@", __FUNCTION__, user);
}
```

9. 实现字典转模型和模型转字典的自动转换

```Objective-C
- (void)automicChangeModel
{
    //三层模型转换
    NSDictionary *dic = @{@"name" : @"警察班",
                          @"code" : @"9527",
                          @"list" : @[
                                  @{@"name" : @"刘德华",
                                    @"age" : @"28",
                                    @"teacher" : @{@"name" : @"<nsnull>", @"sex" : @"男"}
                                  },
                                  @{@"name" : @"梁朝伟",
                                    @"age" : @"29",
                                    @"teacher" : @{@"name" : @"NULL", @"sex" : @"男"}
                                  },
                                  @{@"name" : @"曾志伟",
                                    @"age" : @"32",
                                    @"teacher" : @{@"name" : @"武则天", @"sex" : @"女"}
                                  }
                                  ],
                          @"teacher" : @{@"name" : @"战豆豆", @"sex" : @"女"}
    };
    ClassModel *stModel = [ClassModel objectChangeValue:dic];
    NSLog(@"stModel = %@", [stModel debugDescription]);
    
    NSDictionary *dictionary = [NSObject valueWithObject:stModel];
    NSLog(@"dictionary = %@", dictionary);
}
```

10. 类别中添加属性

```Objective-C
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
```

## 参考资料
* [runtime官网api文档](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)
* [runtime官网源码](https://opensource.apple.com/release/macos-10141.html)
* [runtime编译源码-objc4-750.1](https://github.com/wenjiehe/RuntimeSourceCode)
* [runtime官网介绍文档,已不再维护](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048-CH1-SW1
)
* [http://yulingtianxia.com/blog/2016/06/15/Objective-C-Message-Sending-and-Forwarding/](http://yulingtianxia.com/blog/2016/06/15/Objective-C-Message-Sending-and-Forwarding/)


