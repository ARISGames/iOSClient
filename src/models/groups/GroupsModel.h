//
//  GroupsModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupsModel : NSObject
{
    Group *playerGroup;
}

- (Group *) groupForId:(long)group_id;
- (Group *) playerGroup;
- (void) setPlayerGroup:(Group *)g;
- (void) requestGroups;
- (void) touchPlayerGroup;
- (void) requestPlayerGroup;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;
- (void) clearPlayerData;

@end
