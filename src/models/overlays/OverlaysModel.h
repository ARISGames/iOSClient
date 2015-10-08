//
//  OverlaysModel.h
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Overlay.h"

@interface OverlaysModel : ARISModel

- (Overlay *) overlayForId:(long)overlay_id;
- (NSArray *) playerOverlays;
- (void) requestOverlays;
- (void) requestPlayerOverlays;

@end

