//
//  NSArray+Map.m
//  TBClientLib
//
//  Created by Ewan Mellor on 5/5/13.
//  Copyright (c) 2013 Tipbit, Inc. All rights reserved.
//

#import "SynthesizeAssociatedObject.h"

#import "NSArray+Map.h"


@interface NSArray ()

/**
 * This instance retains itself through this property for the duration of map_async.
 */
@property (nonatomic, strong) NSArray* tb_thisSelf;

@end


@implementation NSArray (Map)


-(NSMutableArray*)filter:(predicate_t)filter {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if (filter(obj))
            [result addObject:obj];
    }

    // If the result is noticably smaller than the input, then shrink the memory consumption of the result by copying to a new array.
    if (result.count < 2 * self.count / 3) {
        result = [result mutableCopy];
    }

    return result;
}


-(NSMutableArray*) map:(id_to_id_t)mapper {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        id new_obj = mapper(obj);
        if (new_obj != nil)
            [result addObject: new_obj];
    }
    return result;
}


-(NSMutableArray *)mapRemoveDuplicates:(id_to_id_t)mapper {
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:self.count];
    NSMutableSet * seen = [NSMutableSet setWithCapacity:self.count];
    for (id obj in self) {
        id new_obj = mapper(obj);
        if (new_obj != nil && ![seen containsObject:new_obj]) {
            [result addObject:new_obj];
            [seen addObject:new_obj];
        }
    }
    return result;
}


-(void) map_async:(id_to_id_async_t)mapper onSuccess:(NSMutableArrayBlock)onSuccess {
    self.tb_thisSelf = self;
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    [self map_async:mapper onSuccess:onSuccess idx:0 result:result];
}

-(void) map_async:(id_to_id_async_t)mapper onSuccess:(NSMutableArrayBlock)onSuccess idx:(NSUInteger)idx result:(NSMutableArray*)result {
    if (idx >= self.count) {
        self.tb_thisSelf = nil;
        onSuccess(result);
        return;
    }
    id obj = self[idx];
    NSArray* __weak weak_self = self;
    mapper(obj, ^(id mapped_obj) {
        if (mapped_obj != nil)
            [result addObject:mapped_obj];
        [weak_self map_async:mapper onSuccess:onSuccess idx:idx+1 result:result];
    });
}


-(NSMutableDictionary *)dictionaryWithKeysAndMappedValues:(id_to_id_t)mapper {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self) {
        id val = mapper(key);
        if (val != nil)
            result[key] = val;
    }
    return result;
}


-(NSMutableDictionary *)dictionaryWithMappedKeysAndMappedValues:(id_to_id_t)keyMapper valueMapper:(id_to_id_t)valueMapper {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    for (id key in self) {
        id mapped_key = keyMapper(key);
        if (mapped_key == nil) {
            continue;
        }
        id mapped_val = valueMapper(key);
        if (mapped_val == nil) {
            continue;
        }
        result[mapped_key] = mapped_val;
    }
    return result;
}


-(NSMutableDictionary *)dictionaryWithValuesAndMappedKeys:(id_to_id_t)mapper {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id val in self) {
        id key = mapper(val);
        if (key != nil) {
            NSMutableArray* arr = result[key];
            if (arr == nil) {
                arr = [NSMutableArray array];
                result[key] = arr;
            }
            [arr addObject:val];
        }
    }
    return result;
}


-(NSMutableDictionary *)dictionaryWithValuesAndUniqueMappedKeys:(id_to_id_t)mapper {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (id val in self) {
        id key = mapper(val);
        if (key != nil)
            result[key] = val;
    }
    return result;
}


SYNTHESIZE_ASSOCIATED_OBJECT(tb_thisSelf, NSArray*, tb_thisSelf, setTb_thisSelf, OBJC_ASSOCIATION_RETAIN_NONATOMIC)


@end
