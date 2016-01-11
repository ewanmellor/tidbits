//
//  MutableSortedDictionaryTests.m
//  Tidbits
//
//  Created by Ewan Mellor on 12/2/15.
//  Copyright © 2015 Tipbit, Inc. All rights reserved.
//

#import "MutableSortedDictionary.h"

#import "TBTestCaseBase.h"


@interface MutableSortedDictionaryTests : TBTestCaseBase

@end


@implementation MutableSortedDictionaryTests

static NSComparator Comparator;

+(void)initialize {
    Comparator = ^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2];
    };
}


-(void)testEmpty {
    MutableSortedDictionary * d = [[MutableSortedDictionary alloc] initWithComparator:Comparator];

    XCTAssertNil(d[@"A"]);
    XCTAssertEqual(d.count, 0U);
}


-(void)testInserts {
    MutableSortedDictionary * d = [[MutableSortedDictionary alloc] initWithComparator:Comparator];
    d[@"A"] = @1;
    d[@"C"] = @2;
    d[@"B"] = @3;
    d[@"A"] = @4;

    XCTAssertEqual(d.count, 3U);
    XCTAssertEqualObjects(d[0], @4);
    XCTAssertEqualObjects(d[1], @3);
    XCTAssertEqualObjects(d[2], @2);
    XCTAssertEqualObjects(d[@"A"], @4);
    XCTAssertEqualObjects(d[@"B"], @3);
    XCTAssertEqualObjects(d[@"C"], @2);
    XCTAssertEqualObjects(d.allValues, (@[@4, @3, @2]));
}


-(void)testRemoves {
    MutableSortedDictionary * d = [[MutableSortedDictionary alloc] initWithComparator:Comparator];
    d[@"A"] = @1;
    d[@"B"] = @2;
    d[@"C"] = @3;
    d[@"D"] = @4;
    d[@"E"] = @5;
    d[@"F"] = @6;

    [d removeObjectForKey:@"B"];
    [d removeObjectAtIndex:4];

    XCTAssertEqual(d.count, 4U);
    XCTAssertEqualObjects(d[0], @1);
    XCTAssertEqualObjects(d[1], @3);
    XCTAssertEqualObjects(d[2], @4);
    XCTAssertEqualObjects(d[3], @5);
    XCTAssertEqualObjects(d[@"A"], @1);
    XCTAssertNil(d[@"B"]);
    XCTAssertEqualObjects(d[@"C"], @3);
    XCTAssertEqualObjects(d[@"D"], @4);
    XCTAssertEqualObjects(d[@"E"], @5);
    XCTAssertNil(d[@"F"]);
    XCTAssertEqualObjects(d.allValues, (@[@1, @3, @4, @5]));
}


-(void)testEnumerate {
    MutableSortedDictionary * d = [[MutableSortedDictionary alloc] initWithComparator:Comparator];
    d[@"A"] = @1;
    d[@"C"] = @0;
    d[@"B"] = @2;
    d[@"E"] = @5;
    d[@"D"] = @4;

    NSMutableArray * keys = [NSMutableArray array];
    for (NSString * k in d) {
        [keys addObject:k];
    }
    XCTAssertEqualObjects(keys, (@[@"A", @"B", @"C", @"D", @"E"]));

    NSMutableArray * keys2 = [NSMutableArray array];
    NSEnumerator * keyEnum = d.keyEnumerator;
    NSString * k;
    while (nil != (k = [keyEnum nextObject])) {
        [keys2 addObject:k];
    }
    XCTAssertEqualObjects(keys, keys2);

    NSMutableArray * objs = [NSMutableArray array];
    NSEnumerator * objEnum = d.objectEnumerator;
    NSNumber * o;
    while (nil != (o = [objEnum nextObject])) {
        [objs addObject:o];
    }
    XCTAssertEqualObjects(objs, (@[@1, @2, @0, @4, @5]));
}


@end
