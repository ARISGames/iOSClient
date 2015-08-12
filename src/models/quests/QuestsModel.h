//
//  QuestsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Quest.h"

@interface QuestsModel : ARISModel

- (Quest *) questForId:(long)quest_id;
- (NSArray *) visibleActiveQuests;
- (NSArray *) visibleCompleteQuests;
- (void) requestQuests;
- (void) requestPlayerQuests;
- (void) logAnyNewlyCompletedQuests;

@end

