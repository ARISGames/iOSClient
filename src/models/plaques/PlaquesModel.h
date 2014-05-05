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

- (Plaque *) plaqueForId:(int)plaque_id;
- (void) clearGameData;

@end
