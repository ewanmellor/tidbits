//
//  BackgroundTaskHandler.m
//  Tidbits
//
//  Created by Ewan Mellor on 12/25/13.
//  Copyright (c) 2013 Tipbit, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Dispatch.h"
#import "FeatureMacros.h"
#import "LoggingMacros.h"

#import "BackgroundTaskHandler.h"


@interface BackgroundTaskHandler ()

@property (nonatomic, copy) NSString* taskName;

@property (nonatomic, copy) TaskBlock taskBlock;

/**
 * The number of times that the app has come into the foreground.
 * This is used to tell us to stop the background cleanup tasks if the counter changes.
 * I've seen situations where onBackground queued the task but they didn't run in the timeslice before the app was suspended
 * so they ran after we had resumed to foreground instead.
 */
@property (nonatomic, assign) int foregroundCounter;

@end


@implementation BackgroundTaskHandler


-(id)init:(NSString*)taskName taskBlock:(TaskBlock)taskBlock {
    NSParameterAssert(taskName);
    NSParameterAssert(taskBlock);

    self = [super init];
    if (self) {
        _taskName = taskName;
        _taskBlock = taskBlock;
        _foregroundCounter = 1;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(onBackground)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:nil];

        [center addObserver:self
                   selector:@selector(onForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:nil];
    }
    return self;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)onForeground {
    self.foregroundCounter++;
}


-(void) onBackground {
    int thisForegroundCounter = self.foregroundCounter;
    BackgroundTaskHandler* __weak weakSelf = self;

    UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:self.taskName expirationHandler:^{
        NSLog(@"Background task %@ ran out of time!  This should never happen if we're watching for this in the background task.", self.taskName);
    }];

    dispatchAsyncBackgroundThread(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
        [weakSelf onBackground_:thisForegroundCounter task:task];
    });
}


-(void)onBackground_:(int)thisForegroundCounter task:(UIBackgroundTaskIdentifier)task {
    BackgroundTaskHandler* __weak weakSelf = self;
    self.taskBlock(^bool{
        return [weakSelf gameOver:thisForegroundCounter];
    });
    NSTimeInterval remaining = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"Background task %@ complete with %lf remaining.", self.taskName, remaining > 1e10 ? -1.0 : remaining);
    if (task != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:task];
}


-(bool)gameOver:(int)thisForegroundCounter {
    if (self.foregroundCounter != thisForegroundCounter) {
        NSLog(@"Background task %@ did not run to completion; we're foregrounded again.", self.taskName);
        return true;
    }
    if ([[UIApplication sharedApplication] backgroundTimeRemaining] < 0.1) {
        NSLog(@"Background task %@ did not run to completion; we ran out of time.", self.taskName);
        return true;
    }
    return false;
}


@end
