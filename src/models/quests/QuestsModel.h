//
//  QuestsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Quest.h"

@interface QuestsModel : NSObject

- (Quest *) questForId:(int)quest_id;
- (NSArray *) visibleActiveQuests;
- (NSArray *) visibleCompleteQuests;
- (void) requestQuests;
- (void) requestPlayerQuests;

- (void) clearPlayerData;
- (void) clearGameData;

@end
