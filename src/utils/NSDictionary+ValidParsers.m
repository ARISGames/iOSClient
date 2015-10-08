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

- (int) validIntForKey:(NSString *const)aKey
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

- (NSDate *) validDateForKey:(NSString *const)aKey
{
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSDate *d = [df dateFromString:[self validStringForKey:aKey]];
  if(!d) return [df dateFromString:@"0001-01-01 00:00:00"];
  return d;
}

- (CLLocation *) validLocationForLatKey:(NSString *const)latKey lonKey:(NSString *const)lonKey
{
    return [[CLLocation alloc] initWithLatitude:[self validDoubleForKey:latKey] longitude:[self validDoubleForKey:lonKey]];
}

@end
