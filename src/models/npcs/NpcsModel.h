//
//  NpcsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Npc.h"

@interface NpcsModel : NSObject
{
}

- (Npc *) npcForId:(int)npc_id;
- (void) clearGameData;

@end
