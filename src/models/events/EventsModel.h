//
//  EventsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "EventPackage.h"
#import "Event.h"

@interface EventsModel : ARISModel

- (NSArray *) events;
- (Event *) eventForId:(long)event_id;
- (EventPackage *) eventPackageForId:(long)event_package_id; //joke function
- (NSArray *) eventsForEventPackageId:(long)event_package_id;
- (void) runEventPackageId:(long)event_package_id;
- (void) requestEvents;

@end

