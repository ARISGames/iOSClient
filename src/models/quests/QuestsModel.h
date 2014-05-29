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
- (void) requestQuests;
- (NSArray *) visibleActiveQuests;
- (NSArray *) visibleCompleteQuests;

- (void) clearPlayerData;
- (void) clearGameData;

@end
