//
//  NSLayoutConstraint+Misc.m
//  Tidbits
//
//  Created by Ewan Mellor on 12/3/15.
//  Copyright © 2015 Tipbit, Inc. All rights reserved.
//

#import "NSLayoutConstraint+Misc.h"

NS_ASSUME_NONNULL_BEGIN


@implementation NSLayoutConstraint (Misc)


+(void)activateConstraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat views:(NSDictionary<NSString *,id> *)views {
    [NSLayoutConstraint activateConstraintsWithHorizontalFormat:hFormat verticalFormat:vFormat options:(NSLayoutFormatOptions)0 metrics:nil views:views];
}


+(void)activateConstraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views {
    NSArray * c = [NSLayoutConstraint constraintsWithHorizontalFormat:hFormat verticalFormat:vFormat options:opts metrics:metrics views:views];
    [NSLayoutConstraint activateConstraints:c];
}


+(NSArray<NSLayoutConstraint *> *)constraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views {
    NSArray * h = [NSLayoutConstraint constraintsWithVisualFormat:hFormat options:opts metrics:metrics views:views];
    NSArray * v = [NSLayoutConstraint constraintsWithVisualFormat:vFormat options:opts metrics:metrics views:views];
    return [h arrayByAddingObjectsFromArray:v];
}


@end


NS_ASSUME_NONNULL_END
