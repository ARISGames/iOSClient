//
//  MGame.m
//  ARIS
//
//  Created by Miodrag Glumac on 10/24/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import "MGame.h"
#import "MComment.h"
#import "MItem.h"
#import "MLocation.h"
#import "MMap.h"
#import "MMedia.h"
#import "MNode.h"
#import "MNpc.h"
#import "MPlayerLog.h"
#import "MQRCode.h"
#import "MQuest.h"
#import "MRequirement.h"
#import "MTab.h"


@implementation MGame

@dynamic calculatedScore;
@dynamic gameCompleteNodeId;
@dynamic gameDescription;
@dynamic allowPlayerCreatedLocations;
@dynamic name;
@dynamic gameId;
@dynamic numPlayers;
@dynamic isLocational;
@dynamic inventoryWeightCap;
@dynamic deletePlayerLocationsOnReset;
@dynamic completedQuests;
@dynamic totalQuests;
@dynamic rating;
@dynamic requirements;
@dynamic maps;
@dynamic quests;
@dynamic npcs;
@dynamic items;
@dynamic icon;
@dynamic tabs;
@dynamic media;
@dynamic logs;
@dynamic locations;
@dynamic nodes;
@dynamic gameCompleteNode;
@dynamic comments;
@dynamic medias;
@dynamic gameIcon;
@dynamic onLaunchNode;
@dynamic qrCodes;
@dynamic overlays;
@dynamic offline;
@dynamic hasBeenPlayed;

@end
