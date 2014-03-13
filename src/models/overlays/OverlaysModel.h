//
//  OverlaysModel.h
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

#import <Foundation/Foundation.h>
#import "CustomMapOverlay.h"

@interface OverlaysModel : NSObject
{
    NSDictionary *allOverlays;
    NSArray *overlayIds;
}

@property (nonatomic, strong) NSArray *overlayIds;

- (void) clearData;
- (CustomMapOverlay *) overlayForOverlayId:(int)overlayId;

@end
