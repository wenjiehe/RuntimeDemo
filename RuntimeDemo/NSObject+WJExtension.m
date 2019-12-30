//
//  NSObject+WJExtension.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "NSObject+WJExtension.h"
#import <objc/runtime.h>

@implementation NSObject (WJExtension)

+ (id)objectChangeValue:(id)keyValues
{
    NSDictionary *dic = keyValues;
    id objc = [[self alloc] init];
    NSArray *keyAry = @[], *valueAry = @[];
    NSDictionary *csDic;
    if ([self respondsToSelector:@selector(customKeyValue)]) {
        id object = [self performSelector:@selector(customKeyValue)];
        csDic = object;
        if (csDic) {
            keyAry = [csDic allKeys];
            valueAry = [csDic allValues];
        }
    }
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (NSInteger i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        const char *name = ivar_getName(ivar);
        NSString *key = [NSString stringWithUTF8String:name];
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if ([key containsString:@"_"]) {
            key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
        }
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSLog(@"key = %@, value = %@, ivarType = %@", key, dic[key], ivarType);
        if ([ivarType isEqualToString:@"NSString"]) {
            [objc setValue:dic[key] forKey:key];
        }else if ([ivarType isEqualToString:@"NSArray"]){
            for (NSInteger k = 0 ; k < keyAry.count; k++) {
                id value = [self createObject:valueAry[k] dicValue:dic[key]];
                if ([value isKindOfClass:[NSArray class]]) {
                    NSArray *a = value;
                    if (a.count > 0) {
                        [objc setValue:value forKey:key];
                    }
                }else{
                    [objc setValue:value forKey:key];
                }
            }
        }
    }
    free(ivarList);
    return objc;
}

- (id)createObject:(NSString *)classStr dicValue:(id)value
{
    if (classStr.length > 0 && value) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *list = value;
            NSMutableArray *mtbAry = [NSMutableArray new];
            for (NSInteger i = 0; i < list.count; i++) {
                Class cla = NSClassFromString(classStr);
                id ob = [[cla alloc] init];
                NSArray *keyAry = @[], *valueAry = @[];
                NSDictionary *csDic;
                if ([cla respondsToSelector:@selector(customKeyValue)]) {
                    csDic = [cla performSelector:@selector(customKeyValue)];
                    if (csDic) {
                        keyAry = [csDic allKeys];
                        valueAry = [csDic allValues];
                    }
                }
                NSDictionary *dic = list[i];
                unsigned int count = 0;
                Ivar *ivarList = class_copyIvarList([cla class], &count);
                for (NSInteger k = 0; k < count; k++) {
                    Ivar ivar = ivarList[k];
                    const char *name = ivar_getName(ivar);
                    NSString *key = [NSString stringWithUTF8String:name];
                    if ([key containsString:@"_"]) {
                        key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
                    }
//                    NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
//                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
//                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//                    ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    if ([dic[key] isKindOfClass:[NSString class]]) {
                        [ob setValue:dic[key] forKey:key];
                    }else if ([dic[key] isKindOfClass:[NSArray class]]){
                        for (NSInteger j = 0 ; j < keyAry.count; j++) {
                            id value = [self createObject:valueAry[j] dicValue:dic[key]];
                            [ob setValue:value forKey:key];
                        }
                    }else if ([dic[key] isKindOfClass:[NSDictionary class]]){
                        for (NSInteger j = 0 ; j < keyAry.count; j++) {
                            id value = [self createObject:valueAry[j] dicValue:dic[key]];
                            [ob setValue:value forKey:key];
                        }
                    }
                }
                [mtbAry addObject:ob];
                free(ivarList);
            }
            return mtbAry;
        }else if ([value isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = value;
            Class cla = NSClassFromString(classStr);
            id ob = [[cla alloc] init];
            NSArray *keyAry = @[], *valueAry = @[];
            NSDictionary *csDic;
            if ([cla respondsToSelector:@selector(customKeyValue)]) {
                csDic = [cla performSelector:@selector(customKeyValue)];
                if (csDic) {
                    keyAry = [csDic allKeys];
                    valueAry = [csDic allValues];
                }
            }
            unsigned int count = 0;
            Ivar *ivarList = class_copyIvarList([cla class], &count);
            for (NSInteger k = 0; k < count; k++) {
                Ivar ivar = ivarList[k];
                const char *name = ivar_getName(ivar);
                NSString *key = [NSString stringWithUTF8String:name];
                if ([key containsString:@"_"]) {
                    key = [key stringByReplacingOccurrencesOfString:@"_" withString:@""];
                }
//                NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
//                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
//                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//                ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                if ([dic[key] isKindOfClass:[NSString class]]) {
                    [ob setValue:dic[key] forKey:key];
                }else if ([dic[key] isKindOfClass:[NSArray class]]){
                    for (NSInteger j = 0 ; j < keyAry.count; j++) {
                        id value = [self createObject:valueAry[j] dicValue:dic[key]];
                        [ob setValue:value forKey:key];
                    }
                }else if ([dic[key] isKindOfClass:[NSDictionary class]]){
                    for (NSInteger j = 0 ; j < keyAry.count; j++) {
                        id value = [self createObject:valueAry[j] dicValue:dic[key]];
                        [ob setValue:value forKey:key];
                    }
                }
            }
            free(ivarList);
            return ob;
        }
    
    }
    return nil;
}

- (void)load
{
//    self.classMtbAry = [[NSMutableArray alloc] init];
    NSArray *classAry = @[
                      [NSURL class],
                      [NSDate class],
                      [NSNumber class],
                      [NSDecimalNumber class],
                      [NSData class],
                      [NSMutableData class],
                      [NSArray class],
                      [NSMutableArray class],
                      [NSDictionary class],
                      [NSMutableDictionary class],
                      [NSString class],
                      [NSMutableString class]
                      ];
    [self classChangeString:classAry];
}

- (void)classChangeString:(NSArray *)ary
{
    for (NSUInteger index = 0; index < ary.count; index++) {
//        [self.classMtbAry addObject:NSStringFromClass(ary[index])];
    }
}

- (NSString *)debugDescription
{
    NSMutableDictionary *mtbDic = [NSMutableDictionary new];
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (NSInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        id value = [self valueForKey:name] ? : @"nil";
        [mtbDic setObject:value forKey:name];
    }
    free(properties);
    return [NSString stringWithFormat:@"%s -- %@", __FUNCTION__, mtbDic];
}


@end
