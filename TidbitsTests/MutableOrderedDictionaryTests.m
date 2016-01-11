//
//  MutableOrderedDictionaryTests.m
//  Tidbits
//
//  Created by Ewan Mellor on 1/10/16.
//  Copyright © 2016 Tipbit, Inc. All rights reserved.
//

#import "MutableOrderedDictionary.h"

#import "TBTestCaseBase.h"


@interface MutableOrderedDictionaryTests : TBTestCaseBase

@end


@implementation MutableOrderedDictionaryTests


-(void)testEmpty {
    MutableOrderedDictionary * d = [[MutableOrderedDictionary alloc] init];

    XCTAssertNil(d[@"A"]);
    XCTAssertEqual(d.count, 0U);
}


-(void)testInserts {
    MutableOrderedDictionary * d = [[MutableOrderedDictionary alloc] init];
    d[@"A"] = @1;
    d[@"C"] = @2;
    d[@"B"] = @3;
    d[@"A"] = @4;

    XCTAssertEqual(d.count, 3U);
    XCTAssertEqualObjects(d[0], @4);
    XCTAssertEqualObjects(d[1], @2);
    XCTAssertEqualObjects(d[2], @3);
    XCTAssertEqualObjects([d keyAtIndex:0], @"A");
    XCTAssertEqualObjects([d keyAtIndex:1], @"C");
    XCTAssertEqualObjects([d keyAtIndex:2], @"B");
    XCTAssertEqualObjects(d[@"A"], @4);
    XCTAssertEqualObjects(d[@"B"], @3);
    XCTAssertEqualObjects(d[@"C"], @2);
    XCTAssertEqualObjects(d.allValues, (@[@4, @2, @3]));
}


-(void)testRemoves {
    MutableOrderedDictionary * d = [MutableOrderedDictionary dictionary];
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
    XCTAssertEqualObjects([d keyAtIndex:0], @"A");
    XCTAssertEqualObjects([d keyAtIndex:1], @"C");
    XCTAssertEqualObjects([d keyAtIndex:2], @"D");
    XCTAssertEqualObjects([d keyAtIndex:3], @"E");
    XCTAssertEqualObjects(d[@"A"], @1);
    XCTAssertNil(d[@"B"]);
    XCTAssertEqualObjects(d[@"C"], @3);
    XCTAssertEqualObjects(d[@"D"], @4);
    XCTAssertEqualObjects(d[@"E"], @5);
    XCTAssertNil(d[@"F"]);
    XCTAssertEqualObjects(d.allValues, (@[@1, @3, @4, @5]));
}


-(void)testEnumerate {
    MutableOrderedDictionary * d = [MutableOrderedDictionary dictionary];
    d[@"A"] = @1;
    d[@"B"] = @0;
    d[@"C"] = @3;

    NSMutableArray * keys = [NSMutableArray array];
    for (NSString * k in d) {
        [keys addObject:k];
    }
    XCTAssertEqualObjects(keys, (@[@"A", @"B", @"C"]));

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
    XCTAssertEqualObjects(objs, (@[@1, @0, @3]));
}


@end
