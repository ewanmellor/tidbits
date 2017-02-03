//
//  LoggingMacros.h
//  Tidbits
//
//  Created by Ewan Mellor on 5/10/13.
//  Copyright (c) 2013-2015 Tipbit, Inc.
//  Copyright (c) 2016-     Ewan Mellor.
//

#ifndef Tidbits_LoggingMacros_h
#define Tidbits_LoggingMacros_h

#import <CocoaLumberjack/CocoaLumberjack.h>

#import "NSThread+Misc.h"


#if DEBUG
#define CALLSTACK [NSThread callStackSymbols]
#define CALLEDBY [NSThread callingFunction]
#else
#define CALLSTACK @""
#define CALLEDBY @""
#endif


#define LoggingMacrosTag(__s) @"⟦" __s @"⟧"


#include "LoggingMacrosWrappers.h"

#endif
