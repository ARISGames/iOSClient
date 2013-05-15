//
//  NPC.h
//  ARIS
//
//  Created by David J Gagnon on 9/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface Npc : NSObject  <GameObjectProtocol>
{
	int npcId;
	NSString *name;
	NSString *greeting;
	NSString *closing;
	int	mediaId;
	int iconMediaId;
}

@property(nonatomic, assign) int npcId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *greeting;
@property(nonatomic, strong) NSString *closing;
@property(nonatomic, assign) int mediaId;
@property(nonatomic, assign) int iconMediaId;

@end
