//
//  StateControllerProtocol.h
//  ARIS
//
//  Created by Phil Dougherty on 5/15/13.
//
//

#import <Foundation/Foundation.h>

//This is a separate protocol to allow state change requests to percolate up through all conforming VC's

@protocol StateControllerProtocol
- (void) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s;
- (void) displayTab:(NSString *)t;
@end
