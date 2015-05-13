//
//  ARISServiceGraveyard.h
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import <Foundation/Foundation.h>

@class ARISServiceResult;
@class ARISConnection;

@interface ARISServiceGraveyard : NSObject

- (id) initWithContext:(NSManagedObjectContext *)c;
- (void) addServiceResult:(ARISServiceResult *)sr;
- (void) reviveRequestsWithConnection:(ARISConnection *)c;
- (void) clearCache;

@end
