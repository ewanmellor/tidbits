//
//  MutableOrderedDictionary.m
//  Tidbits
//
//  Created by Ewan Mellor on 1/10/16.
//  Copyright © 2016 Tipbit, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MutableOrderedDictionary.h"

NS_ASSUME_NONNULL_BEGIN


@interface MutableOrderedDictionary<KeyType, ObjectType> ()

@property (nonatomic, readonly) NSMutableArray<KeyType> * keyArray;
@property (nonatomic, readonly) NSMutableDictionary<KeyType, ObjectType> * dict;

@end


@interface MutableOrderedDictionaryObjectEnumerator : NSEnumerator

@property (nonatomic, weak) MutableOrderedDictionary * mod;
@property (nonatomic) NSEnumerator * keyEnum;

-(instancetype)init:(MutableOrderedDictionary *)mod;

@end


@implementation MutableOrderedDictionary


+(MutableOrderedDictionary *)dictionary {
    return [[MutableOrderedDictionary alloc] init];
}


-(instancetype)init {
    self = [super init];
    if (self) {
        _keyArray = [NSMutableArray array];
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}


-(NSUInteger)count {
    return self.keyArray.count;
}


-(id)keyAtIndex:(NSUInteger)index {
    return self.keyArray[index];
}


-(id)objectAtIndex:(NSUInteger)index {
    return self.dict[self.keyArray[index]];
}

-(id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.dict[self.keyArray[idx]];
}


-(nullable id)objectForKey:(id)aKey {
    return self.dict[aKey];
}

-(nullable id)objectForKeyedSubscript:(id)key {
    return self.dict[key];
}


-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    [self setObject:anObject forKeyedSubscript:aKey];
}

-(void)setObject:(nullable id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (obj == nil) {
        [self.dict removeObjectForKey:key];
        [self.keyArray removeObject:key];
    }
    else {
        self.dict[key] = obj;
        if (![self.keyArray containsObject:key]) {
            [self.keyArray addObject:key];
        }
    }
}


-(void)removeAllObjects {
    [self.dict removeAllObjects];
    [self.keyArray removeAllObjects];
}


-(void)removeLastObject {
    [self removeObjectAtIndex:self.count - 1];
}


-(void)removeObjectAtIndex:(NSUInteger)index {
    id key = self.keyArray[index];
    [self.dict removeObjectForKey:key];
    [self.keyArray removeObjectAtIndex:index];
}


-(void)removeObjectForKey:(id)aKey {
    [self.dict removeObjectForKey:aKey];
    [self.keyArray removeObject:aKey];
}


-(void)removeObjectsForKeys:(NSArray *)keyArray {
    [self.dict removeObjectsForKeys:keyArray];
    [self.keyArray removeObjectsInArray:keyArray];
}


-(NSEnumerator *)keyEnumerator {
    return self.keyArray.objectEnumerator;
}


-(NSEnumerator *)objectEnumerator {
    return [[MutableOrderedDictionaryObjectEnumerator alloc] init:self];
}


@end


@implementation MutableOrderedDictionaryObjectEnumerator


-(instancetype)init:(MutableOrderedDictionary *)mod {
    self = [super init];
    if (self) {
        _mod = mod;
        _keyEnum = mod.keyEnumerator;
    }
    return self;
}


-(nullable id)nextObject {
    id __nullable nextKey = [self.keyEnum nextObject];
    return (nextKey == nil ? nil : self.mod[nextKey]);
}


@end


NS_ASSUME_NONNULL_END
