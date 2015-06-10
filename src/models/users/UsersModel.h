//
//  UsersModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UsersModel : NSObject

- (User *) userForId:(long)user_id;
- (void) requestUsers;

- (void) clearData;
- (void) clearGameData;
- (BOOL) gameInfoRecvd;

@end
