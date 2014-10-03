//
//  StateControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 5/15/13.
//
//

#import <Foundation/Foundation.h>

//This is a separate protocol to allow state change requests to percolate up through all conforming VC's

@class Trigger;
@class Instance;
@class Instance;
@class Tab;
@protocol StateControllerProtocol
- (BOOL) displayTrigger:(Trigger *)t; //returns success
- (BOOL) displayTriggerId:(int)trigger_id; //returns success
- (BOOL) displayInstance:(Instance *)i; //returns success //for the cases where we display something without a trigger
- (BOOL) displayInstanceId:(int)instance_id; //returns success //for the cases where we display something without a trigger
- (BOOL) displayObject:(id)o; //returns success //for the case where we display something without an instance
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id; //returns success //for the case where we display something without an instance
- (void) displayTab:(Tab *)t;
- (void) displayTabId:(int)tab_id;
- (void) displayTabType:(NSString *)tab_type;
- (void) displayScannerWithPrompt:(NSString *)p;
@end
