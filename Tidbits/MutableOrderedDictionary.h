//
//  MutableOrderedDictionary.h
//  Tidbits
//
//  Created by Ewan Mellor on 1/10/16.
//  Copyright © 2016 Tipbit, Inc. All rights reserved.
//

#import <Foundation/NSDictionary.h>

NS_ASSUME_NONNULL_BEGIN


/**
 * An NSMutableDictionary subclass that also records the insertion order of the keys and
 * returns keys and values in that order when enumerated or indexed.
 *
 * Note that this is distinct from MutableSortedDictionary, which sorts its keys based on
 * a given NSComparator rather than insertion order.
 */
@interface MutableOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSMutableDictionary<KeyType, ObjectType>

+(MutableOrderedDictionary *)dictionary;

-(KeyType)keyAtIndex:(NSUInteger)index;

-(ObjectType)objectAtIndex:(NSUInteger)index;
-(ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;

-(void)removeLastObject;
-(void)removeObjectAtIndex:(NSUInteger)index;

@end


NS_ASSUME_NONNULL_END
