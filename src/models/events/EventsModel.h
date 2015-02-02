//
//  EventsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface EventsModel : NSObject

- (NSArray *) events;
- (Event *) eventForId:(long)event_id;
- (NSArray *) eventsForEventPackageId:(long)event_package_id;
- (void) runEventPackageId:(long)event_package_id;
- (void) requestEvents;
- (void) clearGameData;

@end
