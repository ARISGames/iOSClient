//
//  NSDictionary+ValidParsers.h
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSDictionary (ValidParsers)

- (BOOL)         validBoolForKey:  (NSString *const)aKey;
- (long)          validIntForKey:   (NSString *const)aKey;
- (float)        validFloatForKey: (NSString *const)aKey;
- (double)       validDoubleForKey:(NSString *const)aKey;
- (id)           validObjectForKey:(NSString *const)aKey;
- (NSString *)   validStringForKey:(NSString *const)aKey;
- (NSDate *)     validDateForKey:  (NSString *const)aKey;
- (CLLocation *) validLocationForLatKey:(NSString *const)latKey lonKey:(NSString *const)lonKey;

@end
