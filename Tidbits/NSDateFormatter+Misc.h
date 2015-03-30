//
//  NSDateFormatter+Misc.h
//  Tidbits
//
//  Created by Ewan Mellor on 3/29/15.
//  Copyright (c) 2015 Tipbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Misc)

+(NSDateFormatter *)tb_dateNumeric;
+(NSDateFormatter *)tb_dateShort;
+(NSDateFormatter *)tb_dayDateFull;
+(NSDateFormatter *)tb_dayDateYearFull;
+(NSDateFormatter *)tb_dayOfWeekFull;
+(NSDateFormatter *)tb_dayOfMonth;
+(NSDateFormatter *)tb_monthFull;
+(NSDateFormatter *)tb_monthYearFull;
+(NSDateFormatter *)tb_timeShort;

@end
