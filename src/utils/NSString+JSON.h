//
//  NSString+JSON.h
//  ARIS
//
//  Created by Phil Dougherty on 3/19/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NSString (JSON)

+ (NSString *) JSONPairFromKey:(NSString *)k value:(NSString *)v;
+ (NSString *) JSONFromFlatStringDict:(NSDictionary *)d;

@end
