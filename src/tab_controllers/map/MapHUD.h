//
//  MapHUD.h
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import <UIKit/UIKit.h>
#import "ARISWebView.h"
#import "Location.h"
#import "ARISCollapseView.h"

@protocol MapHUDDelegate
@end

@interface MapHUD : UIViewController
- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d;
- (void) setLocation:(Location *)l;
- (void) open;
- (void) dismiss;
@end
