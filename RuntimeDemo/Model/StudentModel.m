//
//  StudentModel.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "StudentModel.h"
#import "NSObject+WJExtension.h"



@implementation ClassModel

+ (NSDictionary *)customKeyValue
{
    return @{@"list" : @"StudentModel", @"teacher" : @"TeacherModel"};
}

@end

@implementation TeacherModel



@end

@implementation StudentModel

+ (NSDictionary *)customKeyValue
{
    return @{@"teacher" : @"TeacherModel"};
}

@end
