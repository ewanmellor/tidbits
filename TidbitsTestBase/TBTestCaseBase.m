//
//  TBTestCaseBase.m
//  Tidbits
//
//  Created by Ewan Mellor on 10/9/13.
//  Copyright (c) 2013 Tipbit, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "TBTestCaseBase.h"


#define TIMEOUT 10


bool WaitFor(bool (^block)(void))
{
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= TIMEOUT)
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    return block();
}


bool isReachable(NSString* hostname)
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    SCNetworkReachabilityFlags flags;
    Boolean ok = SCNetworkReachabilityGetFlags(reachability, &flags);
    bool result;
    if (!ok)
        result = false;
    else
        result = (0 != (flags & kSCNetworkReachabilityFlagsReachable));
    CFRelease(reachability);
    return result;
}


@implementation TBTestCaseBase

extern void __gcov_flush(void);

-(void)tearDown {
    [super tearDown];
    // Xcode 5 / iOS 7 simulator fails to call this, which means that code coverage doesn't work.
    // We have to do it ourselves.
    // http://www.bubblefoundry.com/blog/2013/09/generating-ios-code-coverage-reports/
    // http://stackoverflow.com/questions/18394655/xcode5-code-coverage-from-cmd-line-for-ci-builds
    __gcov_flush();
}

@end
