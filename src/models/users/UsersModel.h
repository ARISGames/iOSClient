//
//  UsersModel.h
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "User.h"

@interface UsersModel : ARISModel

- (User *) userForId:(long)user_id;
- (void) requestUsers;

- (void) clearData;

@end

