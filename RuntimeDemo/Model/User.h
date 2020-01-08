//
//  User.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//实现当前类可以归档与反归档，需要遵守一个协议NSCoding
@interface User : NSObject<NSCoding,NSSecureCoding>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *age;
@property(nonatomic,copy)NSString *sex;

@end

NS_ASSUME_NONNULL_END
