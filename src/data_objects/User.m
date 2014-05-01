//
//  User.m
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "User.h"
#import "NSDictionary+ValidParsers.h"

@implementation User

@synthesize user_id;
@synthesize user_name;
@synthesize display_name;
@synthesize email;
@synthesize media_id;
@synthesize read_write_key;
@synthesize location;

- (id) init
{
    if(self = [super init])
    {
        self.user_id        = 0; 
        self.user_name      = @"Unknown Player";
        self.display_name   = @"Unknown Player";
        self.email          = @""; 
        self.media_id       = 0;
        self.read_write_key = @"";  
        self.location = [[CLLocation alloc] initWithLatitude:0.0 longitude:0.0]; 
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.user_id        = [dict validIntForKey:@"user_id"]; 
        self.user_name      = [dict validStringForKey:@"user_name"];
        self.display_name   = [dict validStringForKey:@"display_name"];
        self.email          = [dict validStringForKey:@"email"]; 
        self.media_id       = [dict validIntForKey:@"media_id"];
        self.read_write_key = [dict validStringForKey:@"read_write_key"];   
        if([dict validFloatForKey:@"latitude"] && [dict validFloatForKey:@"longitude"])
            self.location = [[CLLocation alloc] initWithLatitude:[dict validFloatForKey:@"latitude"] longitude:[dict validFloatForKey:@"longitude"]];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectPlayer;
}

- (int) compareTo:(User *)ob
{
    return self.user_id == ob.user_id;
}

- (NSString *) name
{
    return self.display_name;
}

- (int) iconMediaId
{
    return 126853;
}

- (GameObjectViewController *) viewControllerForDelegate:(id<GameObjectViewControllerDelegate>)d fromSource:(id)s
{
    return nil;
}

@end
