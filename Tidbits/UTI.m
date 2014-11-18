//
//  UTI.m
//  Tidbits
//
//  Created by Ewan Mellor on 6/23/13.
//  Copyright (c) 2013 Tipbit, Inc. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "NSString+Misc.h"

#import "UTI.h"


NSString* utiFilenameToMIME(NSString* fname) {
    if ([fname isNotWhitespace]) {
        NSString * ext = fname.pathExtension;
        CFStringRef pathExtension = (__bridge CFStringRef)ext;
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);

        if (type != NULL) {
            NSString* result = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
            CFRelease(type);
            if (result != nil) {
                return result;
            }
        }
    }

    return @"application/octet-stream";
}


NSString* utiMIMEToExtension(NSString* mime) {
    // rfc822 is not in the iOS UTI DB, so we treat it specially.
    if ([mime isEqualToString:@"message/rfc822"]) {
        return @"eml";
    }
    else if ([mime isNotWhitespace]) {
        CFStringRef c_mime = (__bridge CFStringRef)mime;
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, c_mime, NULL);

        if (type != NULL) {
            NSString* result = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension);
            CFRelease(type);
            return result;
        }
    }

    return nil;
}


NSString * utiHumanReadableDescription(NSString * uti) {
    CFStringRef uti_ref = (__bridge CFStringRef)uti;
    return (__bridge_transfer NSString *)UTTypeCopyDescription(uti_ref);
}
