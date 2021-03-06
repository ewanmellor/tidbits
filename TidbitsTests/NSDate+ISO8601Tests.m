//
//  NSDate+ISO8601Tests.m
//  Tidbits
//
//  Created by Ewan Mellor on 1/2/14.
//  Copyright (c) 2014 Tipbit, Inc. All rights reserved.
//

#import "NSDate+ISO8601.h"

#import "TBTestCaseBase.h"
#import "TBTestHelpers.h"


@interface NSDate_ISO8601Tests : TBTestCaseBase

@end


@implementation NSDate_ISO8601Tests


-(void)testDateFromIso8601Empty {
    XCTAssertNil([NSDate dateFromIso8601:@""]);
}


-(void)testDateFromIso8601Nil {
    XCTAssertNil([NSDate dateFromIso8601:nil]);
}


-(void)testDateFromIso8601Garbage {
    XCTAssertNil([NSDate dateFromIso8601:@"121212"]);
}


-(void)testDateFromIso8601TimeOnly {
    XCTAssertNil([NSDate dateFromIso8601:@"12:12:12Z"]);
}


-(void)testDateFromIso8601Millis {
    NSString* input = @"2013-04-01T20:42:33.388Z";
    NSDate* expected = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.388];
    NSDate* output = [NSDate dateFromIso8601:input];
    XCTAssertEqualObjects(output, expected);
}


-(void)testDateFromIso8601Millis001 {
    NSString* input = @"2013-04-01T20:42:33.001Z";
    NSDate* expected = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.001];
    NSDate* output = [NSDate dateFromIso8601:input];
    XCTAssertEqualObjects(output, expected);
}


-(void)testDateFromIso8601Millis999 {
    NSString* input = @"2013-04-01T20:42:33.999Z";
    NSDate* expected = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.999];
    NSDate* output = [NSDate dateFromIso8601:input];
    XCTAssertEqualObjects(output, expected);
}


-(void)testDateFromIso8601NoMillis {
    NSString* input = @"2013-04-01T20:42:33Z";
    NSDate* expected = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.0];
    NSDate* output = [NSDate dateFromIso8601:input];
    XCTAssertEqualObjects(output, expected);
}


-(void)testIso8601StringMillis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.401];
    NSString* expected = @"2013-04-01T20:42:33"; // Note millis and Z are dropped because iso8601String outputs the 19 char form.
    XCTAssertEqualObjects([input iso8601String], expected);
}


-(void)testIso8601StringNoMillis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.0];
    NSString* expected = @"2013-04-01T20:42:33"; // Note no Z because iso8601String outputs the 19 char form.
    XCTAssertEqualObjects([input iso8601String], expected);
}


-(void)testIso8601String_16Millis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.401];
    NSString* expected = @"2013-04-01T20:42";
    XCTAssertEqualObjects([input iso8601String_16], expected);
}


-(void)testIso8601String_16NoMillis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.0];
    NSString* expected = @"2013-04-01T20:42";
    XCTAssertEqualObjects([input iso8601String_16], expected);
}


-(void)testIso8601String_24Millis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.401];
    NSString* expected = @"2013-04-01T20:42:33.401Z";
    XCTAssertEqualObjects([input iso8601String_24], expected);
}


-(void)testIso8601String_24NoMillis {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.0];
    NSString* expected = @"2013-04-01T20:42:33.000Z";
    XCTAssertEqualObjects([input iso8601String_24], expected);
}


/**
 * We used to have a bug here, where the single msec would be lost because this
 * NSTimeInterval value is represented as 455331750.00099999 and we would render
 * that as 000 msec instead of rounding up to 001.
 */
-(void)testIso8601String_24SingleMilli {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:455331750.001];
    NSString* expected = @"2015-06-07T01:02:30.001Z";
    XCTAssertEqualObjects([input iso8601String_24], expected);
}


-(void)testIso8601String_24Milli500 {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:455331750.500];
    NSString* expected = @"2015-06-07T01:02:30.500Z";
    XCTAssertEqualObjects([input iso8601String_24], expected);
}


-(void)testIso8601String_24Milli499 {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:455331750.501];
    NSString* expected = @"2015-06-07T01:02:30.501Z";
    XCTAssertEqualObjects([input iso8601String_24], expected);
}


-(void)testIso8601String_local_23 {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.401];
    NSInteger offset = [[NSTimeZone localTimeZone] secondsFromGMTForDate:input];
    if (offset != -25200) {
        NSLog(@"Test is not running in Pacific timezone; skipping");
    }
    NSString* expected = @"2013-04-01T13:42:33.401"; // 2013-04-01T20:42:33Z, so 2013-04-01T13:42:33 in PDT.
    XCTAssertEqualObjects([input iso8601String_local_23], expected);
}


-(void)testIso8601String_24PerformanceComparison {
    NSDate* input = [NSDate dateWithTimeIntervalSinceReferenceDate:386541753.0];

    comparePerformanceAndLogResult(^{
        [input iso8601String_24];
    }, ^{
        [input iso8601String_24_B];
    });
}


//
// This test is derived from a test in CBLJSON.m in http://github.com/couchbase/couchbase-lite-ios
// Copyright (c) 2012-2013 Couchbase, Inc and licensed under the Apache License 2.0.
//
-(void)testDateFromIso8601Performance {
    const NSUInteger count = 100000;
    NSArray* dates;
    @autoreleasepool {
        dates = generateSampleDates(count);
    }

    NSTimeInterval baseline = benchmarkNSDateFormatter(dates);
    NSTimeInterval result = benchmarkDateFromIso8601(dates);
    NSLog(@"dateFromIso8601 x %lu: %0.6f sec, %0.6f ratio.", (unsigned long)count, result, result / baseline);
}


static NSTimeInterval benchmarkDateFromIso8601(NSArray* dates) {
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    for (NSString *date in dates)
        [NSDate dateFromIso8601:date];

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    return end - start;
}


static NSTimeInterval benchmarkNSDateFormatter(NSArray* dates) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    for (NSString *date in dates)
        [dateFormatter dateFromString:date];

    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    return end - start;
}


static NSArray* generateSampleDates(NSUInteger count) {
    NSMutableArray *dates = [NSMutableArray array];

    for (NSUInteger i = 0; i < count; i++)
        [dates addObject:generateSampleDate()];

    return dates;
}


static NSString* generateSampleDate() {
    unsigned year = randomNumberInRange(1980, 2013);
    unsigned month = randomNumberInRange(1, 12);
    unsigned date = randomNumberInRange(1, 28);
    unsigned hour = randomNumberInRange(0, 23);
    unsigned minute = randomNumberInRange(0, 59);
    unsigned second = randomNumberInRange(0, 59);
    return [NSString stringWithFormat:@"%u-%02u-%02uT%02u:%02u:%02uZ",
            year, month, date, hour, minute, second];
}


static unsigned randomNumberInRange(unsigned start, unsigned end) {
    unsigned span = end - start;
    return start + (unsigned)arc4random_uniform(span);
}


@end
