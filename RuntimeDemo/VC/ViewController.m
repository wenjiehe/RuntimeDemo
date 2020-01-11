//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/4.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

typedef void(^customBlock)(void);

@interface ViewController ()

@property(nonatomic,strong)customBlock block;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.block = ^{
        [self tv];
    };

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tv
{
    NSLog(@"将夜");
}

- (void)objcRuntime
{
    void (*setter)(id, SEL ,BOOL);
    setter = (void(*)(id, SEL, BOOL))[self methodForSelector:@selector(moark:)];
    setter(self, @selector(moark:), YES);
}

- (void)moark:(BOOL)isSuccess
{
    NSLog(@"%s %ld",__FUNCTION__, isSuccess);
}

@end
