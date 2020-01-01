//
//  SurprisedView.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/6.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "SurprisedView.h"
#import "UIButton+Hook.h"

@interface SurprisedView ()

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *age;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic,strong)NSArray *ary;
@property(nonatomic,strong)UIButton *btn;

@end

@implementation SurprisedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.age = @"3";
        self.name = @"李沐宸";
        self.url = [NSURL URLWithString:@"https://www.baidu.com"];
        self.ary = @[@"skd", @"dko"];
        
        [self addSubview:self.btn];
        self.btn.channel = @"长沙";
        NSLog(@"channel = %@", self.btn.channel);
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event 
{
    if ([self.delegate respondsToSelector:@selector(changeValue:)]) {
        [self.delegate changeValue:self.name];
    }
    
    [self book];
}

- (void)book
{
    NSLog(@"%s 沧元图", __FUNCTION__);
}

- (void)clickButton
{
    NSLog(@"发着呆");
    if ([self.delegate respondsToSelector:@selector(changeBackgroundColor:)]) {
        [self.delegate changeBackgroundColor:^(UIColor * _Nonnull color) {
            [UIView animateWithDuration:0.5f animations:^{
                self.backgroundColor = color;
            }];
        }];
    }
}

- (UIButton *)btn
{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(30, 30, 50, 50);
        [_btn setTitle:@"删掉" forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (NSString *)getAge
{
    return self.age;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
