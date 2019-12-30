//
//  CustomMacro.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//
#import <objc/runtime.h>

#ifndef CustomMacro_h
#define CustomMacro_h

#define encodeRuntime(cla) \
\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([cla class], &count);\
for (NSInteger i = 0; i < count; i++) {\
    Ivar ivar = ivars[i];\
    const char *name = ivar_getName(ivar);\
    NSString *key = [NSString stringWithUTF8String:name];\
    id value = [self valueForKey:key];\
    [coder encodeObject:value forKey:key];\
}\
free(ivars);\
\

#define decodeRuntime(cla) \
\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([cla class], &count);\
for (NSInteger i = 0; i < count; i++) {\
    Ivar ivar = ivars[i];\
    const char *name = ivar_getName(ivar);\
    NSString *key = [NSString stringWithUTF8String:name];\
    id value = [coder decodeObjectForKey:key];\
    [self setValue:value forKey:key];\
}\
free(ivars);\
\

#endif /* CustomMacro_h */
