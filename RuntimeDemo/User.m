//
//  User.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "User.h"
#import "CustomMacro.h"

@implementation User

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    encodeRuntime(User)
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        decodeRuntime(User)
    }
    return self;
}

@end
