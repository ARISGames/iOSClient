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
  NSURL *xmlURL;
  NSURL *datURL;
}

- (ARTarget *) arTargetForId:(long)ar_target_id;
- (void) requestARTargets;

@property (nonatomic, strong) NSURL *xmlURL;
@property (nonatomic, strong) NSURL *datURL;

@end

