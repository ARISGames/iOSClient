//
//  ARTargetsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "ARTarget.h"

@interface ARTargetsModel : ARISModel
{
}

- (ARTarget *) arTargetForId:(long)ar_target_id;
- (void) requestARTargets;

@end

