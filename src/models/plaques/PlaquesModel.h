//
//  PlaquesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Plaque.h"

@interface PlaquesModel : NSObject
{
}

- (Plaque *) plaqueForId:(long)plaque_id;
- (void) requestPlaques;
- (void) clearGameData;

@end
