//
//  DescriptionViewController.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/11.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "DescriptionViewController.h"
//使用runtime方法，必须导入runtime.h文件
#import <objc/runtime.h>
#import <objc/message.h>
#import "SurprisedView.h"
#import "User.h"
#import "StudentModel.h"
#import "NSObject+WJExtension.h"
#import "NSObject+MethodIntercept.h"
#import "ViewController.h"
#import "MainViewController.h"

@interface DescriptionViewController ()<SurprisedViewDelegate>

@property(nonatomic,strong)SurprisedView *sv;
@property(nonatomic,copy)NSString *path;

@end

@implementation DescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self initView];
    
    //崩溃拦截处理
//    SurprisedView *m = [[SurprisedView alloc] init];
//    [m beginMessage];
    
//    NSArray *ary = @[@"sdsf", @"sdefe"];
//    NSLog(@"strtre = %@", [ary objectAtIndex:4]); //崩溃点
    
    //获取成员变量列表
//    [self getIvarList];
    
    //获取方法列表
//    [self getMethodList];
    
    //获取属性列表
//    [self getPropertyList];
    
    //动态变量控制
//    [self dynamicChangeIvar];
    
    //动态添加方法
//    [self dynamicAddMethod];
    
    //动态交换两个方法的实现
//    [self dynamicReplaceMethod];
    
    //归档
//    [self automicKeyedArchiver];
    
    //实现字典转模型的自动转换
//    [self automicChangeModel];
    
    //动态创建类
    [self dynamicCreateClass];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%s", __FUNCTION__);
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark -- init View
- (void)initView
{
    self.sv = [[SurprisedView alloc] init];
    self.sv.frame = CGRectMake(20, 100, 200, 200);
    self.sv.backgroundColor = [UIColor orangeColor];
    self.sv.delegate = self;
    [self.view addSubview:self.sv];
}

#pragma mark -- Touch Begin
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //获取协议列表
//    [self getProtocolList];
    
//    [self changeMethod];
    
    //解档
//    [self automicKeyedUnarchiver];
    
    //push
    MainViewController *vc = [MainViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- SurprisedViewDelegate
- (void)changeValue:(NSString *)value
{
    NSLog(@"%s, value = %@", __FUNCTION__, value);
}

- (void)changeBackgroundColor:(void (^)(UIColor * _Nonnull))block
{
    ViewController *vc = [ViewController new];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    block([UIColor redColor]);
}

#pragma mark -- 获取成员变量列表
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
    free(ivar);
}

#pragma mark -- 获取属性列表
- (void)getPropertyList
{
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self.sv class], &count);
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *propertyName = property_getName(property);
        NSLog(@"propertyName---->%@", [NSString stringWithUTF8String:propertyName]);
    }
    free(propertyList);
}

#pragma mark -- 获取方法列表
- (void)getMethodList
{
    unsigned int count = 0;
    Method *methodList = class_copyMethodList([self.sv class], &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method---->%@", NSStringFromSelector(method_getName(method)));
    }
    free(methodList);
}

#pragma mark -- 获取协议列表
- (void)getProtocolList
{
    if ([SurprisedView conformsToProtocol:@protocol(SurprisedViewDelegate)]) {
        NSLog(@"已经实现");
        unsigned int count = 0;
        __unsafe_unretained Protocol **protocolList = class_copyProtocolList([SurprisedView class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Protocol *protocol = protocolList[i];
            const char *protocolName = protocol_getName(protocol);
            NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
        }
        free(protocolList);
    }else{
        NSLog(@"没有实现");
    }
}

#pragma mark -- 动态变量控制
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
    free(ivar);
}

#pragma mark -- 动态添加方法
- (void)dynamicAddMethod
{
    class_addMethod([self.sv class], @selector(look:), (IMP)lookImp, "v@:");
    if ([self.sv respondsToSelector:@selector(look:)]) {
        [self.sv performSelector:@selector(look:) withObject:@{@"age" : @"22", @"sex" : @"man"}];
    }else{
        NSLog(@"error:not found method");
    }
}

void lookImp(id self, SEL _cmd, NSDictionary *dic){
    NSLog(@"lookImp dic =2 %@", dic);
}


#pragma mark -- 动态交换两个方法的实现
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

#pragma mark -- 拦截并替换方法
- (void)changeMethod
{
    NSLog(@"%s 盘龙", __FUNCTION__);
}

#pragma mark -- 实现NSCoding的自动归档和解档
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

#pragma mark -- 实现字典转模型和模型转字典的自动转换
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

#pragma mark -- 动态创建类
- (void)dynamicCreateClass
{
    //动态创建一个Student继承于NSObject类
    Class student = objc_allocateClassPair([NSObject class], "Student", 0);
    //为该类添加NSString *_name的成员变量
    class_addIvar(student, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    //注册方法名为fly的方法
    SEL fly = sel_registerName("fly:");
    //增加名为fly的方法
    class_addMethod(student, fly, (IMP)flyIMP, "v@:@");
    //注册该类
    objc_registerClassPair(student);
    
    //创建类的实例
    id s = [[student alloc] init];
    //kvc动态改变对象s中的实例变量
    [s setValue:@"五竹" forKey:@"name"];
    NSLog(@"name = %@", [s valueForKey:@"name"]);
    ((void (*)(id, SEL, id))objc_msgSend)(s, fly, @"庆余年");
    //当student类或者它的子类的实例还存在，则不能调用objc_disposeClassPair这个方法；因此这里要先销毁实例对象后才能销毁类；
    s = nil;
    //销毁类
    objc_disposeClassPair(student);
    
    NSLog(@"after name = %@", [s valueForKey:@"name"]);
}

void flyIMP(id self, SEL _cmd, NSString *s){
    NSLog(@"sssss = %@", s);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
