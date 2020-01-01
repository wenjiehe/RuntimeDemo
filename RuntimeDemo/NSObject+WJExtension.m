//
//  NSObject+WJExtension.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "NSObject+WJExtension.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (WJExtension)

/// 字典转模型
+ (id)objectChangeValue:(id)keyValues
{
    if ([keyValues isEqual:[NSNull null]] || [keyValues isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return [self createObject:NSStringFromClass(self) dicValue:keyValues];
}

- (id)createObject:(NSString *)classStr dicValue:(id)value
{
    if (classStr.length > 0 && value) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *list = value;
            NSMutableArray *mtbAry = [NSMutableArray new];
            for (NSInteger i = 0; i < list.count; i++) {
                [mtbAry addObject:[self objectChange:classStr dic:list[i]]];
            }
            return mtbAry;
        }else if ([value isKindOfClass:[NSDictionary class]]){
            return [self objectChange:classStr dic:value];
        }
    }
    return nil;
}

- (id)objectChange:(NSString *)classStr dic:(NSDictionary *)dic
{
    Class cla = NSClassFromString(classStr);
    id ob = [[cla alloc] init];
    NSDictionary *csDic;
    if ([cla respondsToSelector:@selector(customKeyValue)]) {
        csDic = [cla performSelector:@selector(customKeyValue)];
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
//        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
//        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
//        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        dic = [NSObject judgeType:dic];
        if ([dic isKindOfClass:[NSString class]]) {
            NSString *st = (NSString *)dic;
            if (st.length == 0) return ob;
        }
        if ([dic[key] isKindOfClass:[NSString class]]) {
            if (dic[key]) [ob setValue:dic[key] forKey:key];
        }else if ([dic[key] isKindOfClass:[NSArray class]]){
            for (NSInteger j = 0 ; j < [csDic allKeys].count; j++) {
                id value = [self createObject:[csDic allValues][j] dicValue:dic[key]];
                if (value) [ob setValue:value forKey:key];
            }
        }else if ([dic[key] isKindOfClass:[NSDictionary class]]){
            for (NSInteger j = 0 ; j < [csDic allKeys].count; j++) {
                if ([key isEqualToString:[csDic allKeys][j]]) {
                    id value = [self createObject:[csDic allValues][j] dicValue:dic[key]];
                    if (value) [ob setValue:value forKey:key];
                }
            }
        }
    }
    free(ivarList);
    return ob;
}

/// 模型转字典
+ (id)valueWithObject:(id)model
{
    if (model) {
        NSMutableDictionary *mtbDic = [NSMutableDictionary new];
        const char *className = object_getClassName(model);
        Class cla = NSClassFromString([NSString stringWithCString:className encoding:NSUTF8StringEncoding]);
        unsigned int count = 0;
        objc_property_t *propertyList = class_copyPropertyList(cla, &count);
        for (NSInteger i = 0; i < count; i++) {
            objc_property_t property = propertyList[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            id value = [model valueForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [mtbDic setValue:value forKey:key];
            }else if ([value isKindOfClass:[NSDictionary class]]){
                [mtbDic setValue:[NSObject valueWithObject:value] forKey:key];
            }else if ([value isKindOfClass:[NSArray class]]){
                NSArray *ary = value;
                NSMutableArray *mtbAry = [NSMutableArray new];
                for (id va in ary) {
                    [mtbAry addObject:[NSObject valueWithObject:va]];
                }
                if (mtbAry.count > 0) [mtbDic setValue:mtbAry forKey:key];
            }else{ //自定义类型走这里
                [mtbDic setValue:[NSObject valueWithObject:value] forKey:key];
            }
        }
        free(propertyList);
        mtbDic = [NSObject judgeType:mtbDic];
        return mtbDic;
        
    }
    return nil;
}

+ (id)judgeType:(id)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [self nullDic:obj];
    }else if ([obj isKindOfClass:[NSArray class]]){
        return [self nullAry:obj];
    }else if ([obj isKindOfClass:[NSString class]]){
        return [self stringToString:obj];
    }else if ([obj isEqual:[NSNull null]] || [obj isKindOfClass:[NSNull class]]){
        return @"";
    }
    return obj;
}

- (NSDictionary *)nullDic:(NSDictionary *)dic
{
    NSMutableDictionary *mtbDic = [NSMutableDictionary new];
    for (NSInteger i = 0; i < [dic allKeys].count; i++) {
        [mtbDic setObject:[NSObject judgeType:[dic allValues][i]] forKey:[dic allKeys][i]];
    }
    return mtbDic;
}

- (NSArray *)nullAry:(NSArray *)ary
{
    NSMutableArray *mtbAry = [NSMutableArray new];
    for (NSInteger i = 0; i < ary.count; i++) {
        [mtbAry addObject:[NSObject judgeType:ary[i]]];
    }
    return mtbAry;
}

- (NSString *)stringToString:(NSString *)str
{
    if ([str isEqualToString:@"<nsnull>"] || [str isEqualToString:@"<NSNull>"] || [str isEqualToString:@"null"] || [str isEqualToString:@"NULL"] || [str isKindOfClass:[NSNull class]] || [str isEqual:[NSNull null]]) {
        return @"五竹";
    }
    return str;
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
