//
//  NSDictionary+ValidParsers.h
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ValidParsers)

- (BOOL)       validBoolForKey:  (NSString *const)aKey;
- (int)        validIntForKey:   (NSString *const)aKey;
- (float)      validFloatForKey: (NSString *const)aKey;
- (double)     validDoubleForKey:(NSString *const)aKey;
- (id)         validObjectForKey:(NSString *const)aKey;
- (NSString *) validStringForKey:(NSString *const)aKey;

@end
