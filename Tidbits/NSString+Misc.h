//
//  NSString+Misc.h
//  Tipbit
//
//  Created by Ewan Mellor on 5/23/13.
//  Copyright (c) 2013 Tipbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Misc)

-(bool) contains:(NSString*)substring;

-(bool) containsCaseInsensitive:(NSString*)substring;

-(bool) hasSuffixCaseInsensitive:(NSString *)comparand;

-(bool) hasSuffixChar:(unichar)c;

-(bool) isEqualToStringCaseInsensitive:(NSString*)comparand;

-(bool) hasPrefixCaseInsensitive:(NSString*)comparand;

-(bool) hasPrefixChar:(unichar)c;

-(bool) isEarlierVersionThan:(NSString*)comparand;

-(NSString*)trim;

-(NSData*)UTF8Data;

/*!
 * @return A copy of this string, with characters escaped so that it is suitable for inclusion in a Javascript
 * single-quoted string literal.
 */
-(NSString*)stringForJavascriptSingleQuotes;

/**
 * @return A copy of this string, with double quotes and backslashes escaped so that it is suitable for inclusion
 * in a double-quoted string literal.
 * @discussion This doesn't do anything with line breaks or any other characters, so you'd best have a plan for those.
 */
-(NSString*)stringForDoubleQuotes;

+(NSString*)stringWithUTF8Data:(NSData*)data;

@end
