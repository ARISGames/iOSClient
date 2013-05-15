//
//  NSDictionary+ValidParsers.m
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import "NSDictionary+ValidParsers.h"

@implementation NSDictionary (ValidParsers)

- (BOOL) validBoolForKey:(NSString *const)aKey
{
	id theObject = [self valueForKey:aKey];
	return [theObject respondsToSelector:@selector(boolValue)] ? [theObject boolValue] : NO;
}

- (NSInteger) validIntForKey:(NSString *const)aKey
{
	id theObject = [self valueForKey:aKey];
	return [theObject respondsToSelector:@selector(intValue)] ? [theObject intValue] : 0;
}

- (float) validFloatForKey:(NSString *const)aKey
{
	id theObject = [self valueForKey:aKey];
	return [theObject respondsToSelector:@selector(floatValue)] ? [theObject floatValue] : 0.0;
}

- (double) validDoubleForKey:(NSString *const)aKey
{
	id theObject = [self valueForKey:aKey];
	return [theObject respondsToSelector:@selector(doubleValue)] ? [theObject doubleValue] : 0.0;
}

- (id) validObjectForKey:(NSString *const)aKey
{
	id theObject = [self valueForKey:aKey];
	return (theObject == [NSNull null]) ? nil : theObject;
}

- (NSString *) validStringForKey:(NSString *const)aKey
{
    id theObject = [self valueForKey:aKey];
    return ([theObject respondsToSelector:@selector(isEqualToString:)]) ? theObject : @"";
}

@end
