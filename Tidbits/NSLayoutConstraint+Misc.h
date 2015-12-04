//
//  NSLayoutConstraint+Misc.h
//  Tidbits
//
//  Created by Ewan Mellor on 12/3/15.
//  Copyright © 2015 Tipbit, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSLayoutConstraint (Misc)

+(void)activateConstraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat views:(NSDictionary<NSString *,id> *)views;

+(void)activateConstraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views;

+(NSArray<NSLayoutConstraint *> *)constraintsWithHorizontalFormat:(NSString *)hFormat verticalFormat:(NSString *)vFormat options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *,id> *)views;

@end


NS_ASSUME_NONNULL_END
