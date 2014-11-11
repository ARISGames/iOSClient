//
//  UsersModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "UsersModel.h"
#import "AppServices.h"
#import "AppModel.h"

@interface UsersModel()
{
    NSMutableDictionary *users;

    NSMutableDictionary *blacklist; //list of ids attempting / attempted and failed to load
}
@end

@implementation UsersModel

- (id) init
{
    if(self = [super init])
    {
        [self clearData];

        _ARIS_NOTIF_LISTEN_(@"SERVICES_USERS_RECEIVED",self,@selector(usersReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_USER_RECEIVED",self,@selector(userReceived:),nil);
    }
    return self;
}

- (void) clearData
{
    users  = [[NSMutableDictionary alloc] init];
    blacklist = [[NSMutableDictionary alloc] init];
}

- (void) usersReceived:(NSNotification *)notif
{
    [self updateUsers:notif.userInfo[@"users"]];
}

- (void) userReceived:(NSNotification *)notif
{
    [self updateUsers:@[notif.userInfo[@"user"]]];
}

- (void) updateUsers:(NSArray *)newUsers
{
    User *newUser;
    NSNumber *newUserId;
    for(int i = 0; i < newUsers.count; i++)
    {
      newUser = [newUsers objectAtIndex:i];
      newUserId = [NSNumber numberWithInt:newUser.user_id];
      if(![users objectForKey:newUserId])
      {
        [users setObject:newUser forKey:newUserId];
        [blacklist removeObjectForKey:[NSNumber numberWithInt:newUserId]];
      }
      else
        [[users objectForKey:newUserId] mergeDataFromUser:newUser];
    }
    _ARIS_NOTIF_SEND_(@"MODEL_USERS_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil); //weird... not "game" piece. whatever.
}

- (NSArray *) conformUsersListToFlyweight:(NSArray *)newUsers
{
    NSMutableArray *conformingUsers = [[NSMutableArray alloc] init];
    User *u;
    for(int i = 0; i < newUsers.count; i++)
    {
        if((u = [self userForId:((User *)newUsers[i]).user_id]))
            [conformingUsers addObject:u];
    }
    return conformingUsers;
}

- (void) requestUsers       { [_SERVICES_ fetchUsers]; }
- (void) requestUser:(int)t { [_SERVICES_ fetchUserById:t]; }

// null user (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (User *) userForId:(int)user_id
{
  User *t = [users objectForKey:[NSNumber numberWithInt:user_id]];
  if(!t)
  {
    [blacklist setObject:@"true" forKey:[NSNumber numberWithInt:user_id]];
    [self requestUser:user_id];
    return [[User alloc] init];
  }
  return t;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end

