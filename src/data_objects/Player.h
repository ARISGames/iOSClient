//
//  Player.h
//  ARIS
//
//  Created by David Gagnon on 5/30/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Player : NSObject
{
	NSString *username;
	NSString *displayname;
    int playerId;
    int playerMediaId;
    NSString *groupname;
    int groupGameId;
	CLLocation *location;
	BOOL hidden;
}

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *displayname;
@property(nonatomic, assign) int playerId;
@property(nonatomic, assign) int playerMediaId;
@property(nonatomic, strong) NSString *groupname;
@property(nonatomic, assign) int groupGameId;
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, assign) BOOL hidden;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
