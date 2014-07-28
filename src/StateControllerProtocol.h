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
@protocol StateControllerProtocol
- (BOOL) displayTrigger:(Trigger *)t; //returns success
- (BOOL) displayInstance:(Instance *)i; //returns success //for the cases where we display something without a trigger
- (BOOL) displayObjectType:(NSString *)type id:(int)type_id; //returns success //for the case where we display something without an instance
- (void) displayTab:(NSString *)t;
- (void) displayScannerWithPrompt:(NSString *)p;
@end
