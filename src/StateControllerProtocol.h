//
//  StateControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 5/15/13.
//
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

//This is a separate protocol to allow state change requests to percolate up through all conforming VC's

@protocol StateControllerProtocol
- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s; //returns success
- (void) displayTab:(NSString *)t;
- (void) displayScannerWithPrompt:(NSString *)p;
@end
