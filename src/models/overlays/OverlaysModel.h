//
//  OverlaysModel.h
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "Overlay.h"

@interface OverlaysModel : NSObject

- (Overlay *) overlayForId:(long)overlay_id;
- (NSArray *) playerOverlays;
- (void) requestOverlays;
- (void) requestPlayerOverlays;

- (void) clearPlayerData;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end

