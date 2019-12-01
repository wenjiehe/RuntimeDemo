//
//  RuntimeObject.m
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/11.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "RuntimeObject.h"

@implementation RuntimeObject

- (NSArray *)basicConceptsAry
{
    return @[@"Class", @"objc_class", @"super_class", @"metaClass", @"objc_object", @"objc_method", @"objc_ivar", @"objc_category", @"objc_property"];
}

- (NSArray *)methodListAry
{
    return @[
        @"OBJC_EXPORT id _Nullable object_copy(id _Nullable obj, size_t size)OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0) OBJC_ARC_UNAVAILABLE",
        @"OBJC_EXPORT id _Nullable object_dispose(id _Nullable obj) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0) OBJC_ARC_UNAVAILABLE;",
        @"OBJC_EXPORT Class _Nullable object_getClass(id _Nullable obj) OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT Class _Nullable object_setClass(id _Nullable obj, Class _Nonnull cls) OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT BOOL object_isClass(id _Nullable obj) OBJC_AVAILABLE(10.10, 8.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT id _Nullable object_getIvar(id _Nullable obj, Ivar _Nonnull ivar) OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT void object_setIvar(id _Nullable obj, Ivar _Nonnull ivar, id _Nullable value) OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT void object_setIvarWithStrongDefault(id _Nullable obj, Ivar _Nonnull ivar, id _Nullable value) OBJC_AVAILABLE(10.12, 10.0, 10.0, 3.0, 2.0);",
        @"OBJC_EXPORT Ivar _Nullable object_setInstanceVariable(id _Nullable obj, const char * _Nonnull name, void * _Nullable value) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0) OBJC_ARC_UNAVAILABLE;",
        @"OBJC_EXPORT Ivar _Nullable object_setInstanceVariableWithStrongDefault(id _Nullable obj, const char * _Nonnull name, void * _Nullable value) OBJC_AVAILABLE(10.12, 10.0, 10.0, 3.0, 2.0) OBJC_ARC_UNAVAILABLE;",
        @"OBJC_EXPORT Ivar _Nullable object_getInstanceVariable(id _Nullable obj, const char * _Nonnull name, void * _Nullable * _Nullable outValue) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0) OBJC_ARC_UNAVAILABLE;",
        @"OBJC_EXPORT Class _Nullable objc_getClass(const char * _Nonnull name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);",
        @"OBJC_EXPORT Class _Nullable objc_getMetaClass(const char * _Nonnull name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
        @"",
    ];
}

@end
