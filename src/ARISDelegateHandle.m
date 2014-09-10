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
    // NOTE- Might be stale (doesn't get invalidated). For debugging purposes only.
    id __unsafe_unretained original_delegate; // DO NOT ACCESS THIS EVER
    
    id __unsafe_unretained delegate;
}

@end

@implementation ARISDelegateHandle

- (id) initWithDelegate:(id)d
{
    if(self = [super init])
    {
        original_delegate = d;
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
