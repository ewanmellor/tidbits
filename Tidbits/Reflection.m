//
//  Reflection.m
//  Tidbits
//
//  Created by Ewan Mellor on 8/21/15.
//  Copyright (c) 2015 Tipbit, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "Reflection.h"

NS_ASSUME_NONNULL_BEGIN


static BOOL boolOfReflectionMatch(ReflectionMatch m);
static BOOL propertyMatchesPredicate(objc_property_t property, CStringGetBoolBlock __nullable predicate);
static NSString * propertyRawType(objc_property_t property);
static void reflectionGetPropertyNames_(Class cls, NSMutableArray * result, CStringGetBoolBlock __nullable predicate);
static void reflectionGetPropertyNamesSingle(Class cls, NSMutableArray * result, CStringGetBoolBlock __nullable predicate);
static void reflectionGetPropertyNamesAndTypes_(Class cls, NSMutableDictionary * result, CStringGetBoolBlock __nullable predicate);
static void reflectionGetPropertyNamesAndTypesSingle(Class cls, NSMutableDictionary * result, CStringGetBoolBlock __nullable predicate);


NSMutableArray * reflectionGetPropertyNames(Class cls, CStringGetBoolBlock __nullable predicate) {
    NSMutableArray * result = [NSMutableArray array];
    reflectionGetPropertyNames_(cls, result, predicate);
    return result;
}


static void reflectionGetPropertyNames_(Class cls, NSMutableArray * result, CStringGetBoolBlock __nullable predicate) {
    reflectionGetPropertyNamesSingle(cls, result, predicate);

    Class superclass = class_getSuperclass(cls);
    if (superclass != nil && superclass != [NSObject class]) {
        reflectionGetPropertyNames_(superclass, result, predicate);
    }
}


static void reflectionGetPropertyNamesSingle(Class cls, NSMutableArray * result, CStringGetBoolBlock __nullable predicate) {
    unsigned outCount;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    for (unsigned i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char * propertyName = property_getName(property);
        if (propertyName != NULL && (predicate == NULL || propertyMatchesPredicate(property, predicate))) {
            [result addObject:[NSString stringWithUTF8String:propertyName]];
        }
    }
    free(properties);
}


NSMutableDictionary<NSString *, NSString *> * reflectionGetPropertyNamesAndTypes(Class cls, CStringGetBoolBlock __nullable predicate) {
    NSMutableDictionary<NSString *, NSString *> * result = [NSMutableDictionary dictionary];
    reflectionGetPropertyNamesAndTypes_(cls, result, predicate);
    return result;
}


static void reflectionGetPropertyNamesAndTypes_(Class cls, NSMutableDictionary<NSString *, NSString *> * result, CStringGetBoolBlock __nullable predicate) {
    reflectionGetPropertyNamesAndTypesSingle(cls, result, predicate);

    Class superclass = class_getSuperclass(cls);
    if (superclass != nil && superclass != [NSObject class]) {
        reflectionGetPropertyNamesAndTypes_(superclass, result, predicate);
    }
}


static void reflectionGetPropertyNamesAndTypesSingle(Class cls, NSMutableDictionary<NSString *, NSString *> * result, CStringGetBoolBlock __nullable predicate) {
    unsigned outCount;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    for (unsigned i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char * propertyName = property_getName(property);
        if (propertyName != NULL && (predicate == NULL || propertyMatchesPredicate(property, predicate))) {
            NSString * name = [NSString stringWithUTF8String:propertyName];
            NSString * type = propertyRawType(property);
            result[name] = type;
        }
    }
    free(properties);
}


static BOOL propertyMatchesPredicate(objc_property_t property, CStringGetBoolBlock __nullable predicate) {
    const char * attrs = property_getAttributes(property);
    return predicate(attrs);
}


static NSString * propertyRawType(objc_property_t property) {
    unsigned count;
    objc_property_attribute_t * attrs = property_copyAttributeList(property, &count);
    for (unsigned i = 0; i < count; i++) {
        objc_property_attribute_t attr = attrs[i];

        if (attr.name[0] == 'T') {
            NSString * result = [NSString stringWithUTF8String:attr.value];
            free(attrs);
            return result;
        }
    }

    assert(false);
}


BOOL reflectionPropertyAttributeStringMatches(const char * attributeString, ReflectionMatch isObject, ReflectionMatch isReadonly, ReflectionMatch isWeak) {
    NSString * attrs_str = [NSString stringWithUTF8String:attributeString];
    NSArray * attrs_arr = [attrs_str componentsSeparatedByString:@","];

    if (isObject != ReflectionMatchDoNotCare) {
        NSString * typestr = attrs_arr[0];
        BOOL is_obj = [typestr hasPrefix:@"T@\""];
        if (is_obj != boolOfReflectionMatch(isObject)) {
            return NO;
        }
    }

    for (NSUInteger i = 1; i < attrs_arr.count; i++) {
        NSString * attr = attrs_arr[i];
        if ([attr isEqualToString:@"R"]) {
            if (isReadonly == ReflectionMatchRequireNo) {
                return NO;
            }
        }
        else if ([attr isEqualToString:@"W"]) {
            if (isReadonly == ReflectionMatchRequireYes) {
                return NO;
            }
        }
    }

    return YES;
}


static BOOL boolOfReflectionMatch(ReflectionMatch m) {
    assert(m != ReflectionMatchDoNotCare);
    return (m == ReflectionMatchRequireYes);
}


NS_ASSUME_NONNULL_END
