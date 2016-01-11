//
//  NSString+JSON.m
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import "NSString+JSON.h"

@implementation NSString (JSON)

+ (NSString *) JSONPairFromKey:(NSString *)k value:(NSString *)v
{
  NSString *escapedV = [v        stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
            escapedV = [escapedV stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            escapedV = [escapedV stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            escapedV = [escapedV stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
            escapedV = [escapedV stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
  return [NSString stringWithFormat:@"\"%@\":\"%@\"",k,escapedV];
}

+ (NSString *) JSONFromFlatStringDict:(NSDictionary *)d
{
  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{"];
  NSArray *keys = [d allKeys];
  for(long i = 0; i < keys.count; i++)
  {
    NSString *key = keys[i];
    NSString *val = [d objectForKey:key];
    [r appendString:[NSString JSONPairFromKey:key value:val]];
    if(i != keys.count-1) [r appendString:@","];
  }
  [r appendString:@"}"];
  return r;
}

@end
