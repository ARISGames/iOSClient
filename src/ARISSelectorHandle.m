//
//  ARISSelectorHandle.m
//  ARIS
//
//  Created by Phil Dougherty on 3/7/14.
//
//

#import "ARISSelectorHandle.h"
@interface ARISSelectorHandle()
{
    SEL selector;
    id __unsafe_unretained handler;
}
@end

@implementation ARISSelectorHandle
- (id) initWithHandler:(id)h selector:(SEL)s
{
    if(self = [super init])
    {
        handler = h;
        selector = s;
    }
    return self;
}
- (void) go
{
    [handler performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
}
@end
