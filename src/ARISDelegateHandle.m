//
//  ARISDelegateHandle.m
//  ARIS
//
//  Created by Phil Dougherty on 3/4/14.
//
//

#import "ARISDelegateHandle.h"

@interface ARISDelegateHandle()
{
    id __unsafe_unretained delegate;
}

@end

@implementation ARISDelegateHandle

- (id) initWithDelegate:(id)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (id) delegate
{
    return delegate;
}

- (void) invalidate
{
    delegate = nil;
}

@end
