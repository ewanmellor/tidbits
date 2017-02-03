//
//  LoggingMacrosWrappers.h
//  Tidbits
//
//  Created by Ewan Mellor on 11/25/14.
//  Copyright (c) 2014-2015 Tipbit, Inc.
//  Copyright (c) 2016-     Ewan Mellor.
//

/*
 You may include this file at any point, in order to redefine all the NSLog* and DLog macros.
 In particular, you can do this to set a prefix for each log message, like this:

 #define LoggingMacrosPrefix @"SomePrefix"
 #include "LoggingMacrosWrappers.h"

 You can make the prefix stand out by wrapping it like this:

 #define LoggingMacrosPrefix LoggingMacrosTag(@"MyTag")
 #include "LoggingMacrosWrappers.h"

 This will give you a prefix like this: ⟦MyTag⟧

 */

#undef NSLog
#undef NSLogError
#undef NSLogWarn
#undef NSLogInfo
#undef NSLogUser
#undef DLog

#undef _LoggingMacrosPrefix
#ifdef LoggingMacrosPrefix
#define _LoggingMacrosPrefix LoggingMacrosPrefix @" "
#else
#define _LoggingMacrosPrefix
#endif

#define NSLogError(__fmt, ...) LOG_MAYBE(NO,   DDLogLevelAll, DDLogFlagError, 0, nil, __PRETTY_FUNCTION__, _LoggingMacrosPrefix __fmt, ##__VA_ARGS__)
#define NSLogWarn(__fmt, ...)  LOG_MAYBE(YES,  DDLogLevelAll, DDLogFlagWarning,  0, nil, __PRETTY_FUNCTION__, _LoggingMacrosPrefix __fmt, ##__VA_ARGS__)
#define NSLogInfo(__fmt, ...)  LOG_MAYBE(YES,  DDLogLevelAll, DDLogFlagInfo,  0, nil, __PRETTY_FUNCTION__, _LoggingMacrosPrefix __fmt, ##__VA_ARGS__)
#define NSLog(__fmt, ...)      LOG_MAYBE(YES,  DDLogLevelAll, DDLogFlagInfo,  0, nil, __PRETTY_FUNCTION__, _LoggingMacrosPrefix __fmt, ##__VA_ARGS__)

#if DEBUG
#define DLog(__fmt, ...) LOG_MAYBE(YES, DDLogLevelAll, DDLogFlagDebug, 0, nil, __PRETTY_FUNCTION__, _LoggingMacrosPrefix __fmt, ##__VA_ARGS__)
#else
#define DLog(...)
#endif
