//
//  JSONConnection+Local.h
//  ARIS
//
//  Created by Miodrag Glumac on 8/23/11.
//  Copyright 2012 Amherst College. All rights reserved.
//

#import "JSONConnection.h"

@interface JSONConnection (Local)

- (BOOL) performAsynchronousLocalRequestWithHandler: (SEL)handler;
- (ServiceResult*) performSynchronousRequestLocal;
- (ServiceResult*) requestLocal;

@end
