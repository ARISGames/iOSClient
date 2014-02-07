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

@protocol MapHUDDelegate
- (void) dismissHUD;
@end


@interface MapHUD : UIViewController
- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d withFrame:(CGRect)f withLocation:(Location *)l;
@end
