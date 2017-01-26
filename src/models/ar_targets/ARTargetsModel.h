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
  NSMutableDictionary *ar_targets;
  NSURL *xmlURL;
  NSURL *datURL;
}

- (ARTarget *) arTargetForId:(long)ar_target_id;
- (void) requestARTargets;
- (void) cacheARData;

@property (nonatomic, strong) NSMutableDictionary *ar_targets;
@property (nonatomic, strong) NSURL *xmlURL;
@property (nonatomic, strong) NSURL *datURL;

@end

