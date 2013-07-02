//
//  NSData+md5.m
//  ARIS
//
//  Created by Miodrag Glumac on 9/16/11.
//  Copyright 2012 Amherst College. All rights reserved.
//

#import "NSData+md5.h"
#import <CommonCrypto/CommonDigest.h>

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif

@implementation NSData (NSData_md5)

- (NSString*)md5 {
    unsigned char result[16];
    CC_MD5( self.bytes, self.length, result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
