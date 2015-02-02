//
//  ARISSelectorHandle.h
//  ARIS
//
//  Created by Phil Dougherty on 3/7/14.
//
//

#import <Foundation/Foundation.h>

@interface ARISSelectorHandle : NSObject
- (id) initWithHandler:(id)h selector:(SEL)s;
- (void) go;
@end
