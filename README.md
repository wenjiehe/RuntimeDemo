# Runtime入门

## 使用

> 在当前ViewController使用导入#import <objc/runtime.h>

## 消息转发机制

## 应用

> xcode中使用shift+command+0,选择Objective-C点击目录列表中的Objective-C Runtime->Reference->Objective-C Runtime，可以看到所有api

1. 获取成员变量列表

```
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

```
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

```
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
```
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

```
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

```
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

```
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

```
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

9. 实现字典转模型的自动转换

```
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
}
```

## 参考资料
* [runtime官网api文档](https://developer.apple.com/documentation/objectivec/objective-c_runtime?language=objc)
* [runtime官网源码](https://opensource.apple.com/release/macos-10141.html)
* [runtime编译源码-objc4-750.1](https://github.com/wenjiehe/RuntimeSourceCode)
* [runtime官网介绍文档,已不再维护](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048-CH1-SW1
)


