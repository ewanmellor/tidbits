//
//  LogFormatter.m
//  Tidbits
//
//  Created by Ewan Mellor on 6/29/13.
//  Copyright (c) 2013 Tipbit, Inc. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <time.h>

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "LoggingMacros.h"

#import "LogFormatter.h"


// Set this to force the use of LogFormatter rather than
// LogFormatterTTY for the TTY logger (i.e. the one that
// shows in the Xcode console).
// This means that you get full date stamps in particular.
#define FORCE_LOGFORMATTER_ON_TTY 0

// Set this to include the thread ID in the TTY logger.
// This is 6-7% slower and is only of value if you've got
// a nasty threading problem so it's off by default.
#define INCLUDE_THREAD_ID_ON_TTY 0

// Set this to include the filename in the log output.
// This is ~0.8% slower.  It is just included in DEBUG
// builds by default because it's probably just bloat
// in a production log file.  It's useful in Xcode for
// use with https://github.com/krzysztofzablocki/KZLinkedConsole
#if DEBUG
#define INCLUDE_FILENAME 1
#else
#define INCLUDE_FILENAME 0
#endif


#if INCLUDE_FILENAME

static const char * filenameOfPath(const char * const file) {
    const char * filename = strrchr(file, '/');
    return (filename == NULL ? file : filename + 1);
}

#endif


@implementation LogFormatter


+(LogFormatter*)formatterRegisteredAsDefaultASLAndTTY {
    return [LogFormatter formatterRegisteredAsDefaultASLAndTTYUsingTTYFormatter:YES];
}


+(LogFormatter *)formatterRegisteredAsDefaultASLAndTTYUsingTTYFormatter:(BOOL)useTtyFormatter {
    LogFormatter * aslFormatter = [LogFormatter formatterRegisteredAsDefaultASL];
#if FORCE_LOGFORMATTER_ON_TTY
    useTtyFormatter = NO;
#endif
    NSObject<DDLogFormatter> * ttyFormatter = useTtyFormatter ? [[LogFormatterTTY alloc] init] : [[LogFormatter alloc] init];
    [LogFormatter registerDefaultTTYLogger:ttyFormatter];
    return aslFormatter;
}


+(LogFormatter*)formatterRegisteredAsDefaultASL {
    LogFormatter* aslFormatter = [[LogFormatter alloc] init];
    DDASLLogger* aslLogger = [DDASLLogger sharedInstance];
    aslLogger.logFormatter = aslFormatter;
    [DDLog addLogger:aslLogger];

    return aslFormatter;
}


+(void)registerDefaultTTYLogger:(NSObject<DDLogFormatter> *)formatter {
    DDTTYLogger* ttyLogger = [DDTTYLogger sharedInstance];
    ttyLogger.logFormatter = formatter;
    [DDLog addLogger:ttyLogger];

    [ttyLogger setColorsEnabled:YES];
#if TARGET_OS_IOS
#define COLOR UIColor
#else
#define COLOR NSColor
#endif
    [ttyLogger setForegroundColor:[COLOR redColor] backgroundColor:nil forFlag:DDLogFlagError];
    [ttyLogger setForegroundColor:[COLOR purpleColor] backgroundColor:nil forFlag:DDLogFlagWarning];
    [ttyLogger setForegroundColor:[COLOR blueColor] backgroundColor:nil forFlag:DDLogFlagInfo];
    [ttyLogger setForegroundColor:[COLOR darkGrayColor] backgroundColor:nil forFlag:DDLogFlagDebug];
#undef COLOR
}


-(NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    char time_level_str[30];
    struct tm tm;
    NSTimeInterval ts = [logMessage.timestamp timeIntervalSince1970];
    time_t ts_whole = (time_t)ts;
    int ts_frac = (int)round(((ts - (double)ts_whole) * 1000.0));
    gmtime_r(&ts_whole, &tm);
    // Using snprintf for the fixed-length fields is 26-29% faster than putting it all in the stringWithFormat call.
    snprintf(time_level_str, 30, "%4d-%02d-%02d %02d:%02d:%02d.%03d %5s", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, ts_frac, logFlagToStr(logMessage.flag));
    return [NSString stringWithFormat:
            @"%s"
#if INCLUDE_FILENAME
            " %@ %s:%u"
#else
            " %@:%u"
#endif
            " | %@",
            time_level_str,
            logMessage.function,
#if INCLUDE_FILENAME
            filenameOfPath(logMessage.file.UTF8String),
#endif
            (unsigned)logMessage.line,
            logMessage.message];
}


static const char * logFlagToStr(DDLogFlag flag) {
    switch (flag) {
        case DDLogFlagError:
            return "error";

        case DDLogFlagWarning:
            return "warn ";

        case DDLogFlagInfo:
            return "info ";

        case DDLogFlagDebug:
            return "debug";

        default:
            return "?????";
    }
}


-(NSString *)formatLogMessageB:(DDLogMessage *)logMessage {
    char time_level_str[30];
    struct tm tm;
    NSTimeInterval ts = [logMessage.timestamp timeIntervalSince1970];
    time_t ts_whole = (time_t)ts;
    int ts_frac = (int)round((ts - (double)ts_whole) * 1000.0);
    gmtime_r(&ts_whole, &tm);
    snprintf(time_level_str, sizeof(time_level_str), "%4d-%02d-%02d %02d:%02d:%02d.%03d %5s", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, ts_frac, logFlagToStr(logMessage.flag));
    return [NSString stringWithFormat:@"%s %@:%lu | %@", time_level_str, logMessage.function, logMessage.line, logMessage.message];
}


@end


@implementation LogFormatterTTY


-(NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    char time_level_str[15];
    struct tm tm;
    NSTimeInterval ts = [logMessage.timestamp timeIntervalSince1970];
    time_t ts_whole = (time_t)ts;
    int ts_frac = (int)round((ts - (double)ts_whole) * 1000.0);
    localtime_r(&ts_whole, &tm);
    // Using snprintf for the fixed-length fields is 26-29% faster than putting it all in the stringWithFormat call.
    snprintf(time_level_str, sizeof(time_level_str), "%c %02d:%02d:%02d.%03d", logFlagToChar(logMessage.flag), tm.tm_hour, tm.tm_min, tm.tm_sec, ts_frac);
    return [NSString stringWithFormat:@"%s"
#if INCLUDE_THREAD_ID_ON_TTY
            " %-4x"
#endif
#if INCLUDE_FILENAME
            " %@ %s:%u"
#else
            " %@:%u"
#endif
            " | %@",
            time_level_str,
#if INCLUDE_THREAD_ID_ON_TTY
            logMessage->machThreadID,
#endif
            logMessage.function,
#if INCLUDE_FILENAME
            filenameOfPath(logMessage.file.UTF8String),
#endif
            (unsigned)logMessage.line,
            logMessage.message];
}


static char logFlagToChar(DDLogFlag flag) {
    switch (flag) {
        case DDLogFlagError:
            return 'E';

        case DDLogFlagWarning:
            return 'W';

        case DDLogFlagInfo:
            return 'I';

        case DDLogFlagDebug:
            return 'D';

        default:
            return '?';
    }
}


#if DEBUG || RELEASE_TESTING

-(NSString *)formatLogMessageB:(DDLogMessage *)logMessage {
    char time_level_str[15];
    struct tm tm;
    NSTimeInterval ts = [logMessage.timestamp timeIntervalSince1970];
    time_t ts_whole = (time_t)ts;
    int ts_frac = (int)round((ts - (double)ts_whole) * 1000.0);
    localtime_r(&ts_whole, &tm);
    // Using snprintf for the fixed-length fields is 26-29% faster than putting it all in the stringWithFormat call.
    snprintf(time_level_str, sizeof(time_level_str), "%c %02d:%02d:%02d.%03d", logFlagToChar(logMessage.flag), tm.tm_hour, tm.tm_min, tm.tm_sec, ts_frac);
    return [NSString stringWithFormat:@"%s"
#if INCLUDE_THREAD_ID_ON_TTY
            " %-4x"
#endif
            " %@:%lu | %@",
            time_level_str,
#if INCLUDE_THREAD_ID_ON_TTY
            logMessage->machThreadID,
#endif
            logMessage.function,
            logMessage.line,
            logMessage.message];
}

#endif


@end
