//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/4.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "ViewController.h"
//使用runtime方法，必须导入runtime.h文件
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self objcRuntime];
    
}


- (void)objcRuntime
{
    void (*setter)(id, SEL ,BOOL);
    setter = (void(*)(id, SEL, BOOL))[self methodForSelector:@selector(moark:)];
    setter(self, @selector(moark:), YES);
}

- (void)moark:(BOOL)isSuccess
{
    NSLog(@"%ld", isSuccess);
}

@end
