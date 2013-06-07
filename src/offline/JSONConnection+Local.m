//
//  JSONConnection+Local.m
//  ARIS
//
//  Created by Miodrag Glumac on 8/23/11.
//  Copyright 2011 Amherst College. All rights reserved.
//

#import "JSONConnection+Local.h"
#import "ARISAppDelegate.h"
#import "LocalData.h"
#import "Reachability.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif


static BOOL needsSync = NO;

@implementation JSONConnection (Local)

/*
- (BOOL)offlineMode {
    for (id argument in self.arguments) {
        if (argument isKindOfClass:[Game class]) {
            return [argument offlineMode];
        }
    }
    return NO;
}
 */


- (BOOL)localCall {
    // testing
    //return YES;

    LocalData *local = [LocalData sharedLocal];
    
    // game if offline
    Game *game = [AppModel sharedAppModel].currentGame;
    if (game && game.offlineMode) {
        NSArray *remoteCalls = [NSArray arrayWithObjects:@"getGamesForPlayerAtLocation", @"startOverGameForPlayer", @"loginPlayer", @"createPlayer", nil];
        NSArray *remoteServices = @[];
        
        if ([remoteCalls containsObject:methodName]) {
            return NO;
        }
        if ([remoteServices containsObject:serviceName]) {
            return NO;
        }
        return YES;
    }
    else {
        // special cases
        if ([methodName isEqualToString:@"getMediaObject"]) {
            NSNumber *mediaId = @([[arguments objectAtIndex:1] intValue]);
            if ([local offlineURLForMediaId:[mediaId integerValue] gameId:0]) {
                return YES;
            }
        }
    }
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [[self.completeRequestURL host] UTF8String]);
    SCNetworkReachabilityFlags flags;
    BOOL reachabilityResult = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
    BOOL reachable = NO;
    if (reachabilityResult && flags != 0) {
        reachable = YES;
    }
    if (reachabilityRef != NULL) {
		CFRelease(reachabilityRef);
	}
	
    if (!reachable) {
        return YES;
    }
    
    return NO;
}

- (BOOL) performAsynchronousLocalRequestWithHandler: (SEL)requestHandler {
    if ([methodName isEqualToString:@"startOverGameForPlayer"]) {
        LocalData *local = [LocalData sharedLocal];
        MGame *game = [local gameForId:[[arguments objectAtIndex:0] intValue]];
        MPlayer *player = [local playerForId:[[arguments objectAtIndex:1] intValue]];
        [local startOverGameForPlayer:player game:game];
    }
    
    if ([self localCall]) {
        dispatch_async(dispatch_get_current_queue(), ^{
            ServiceResult *jsonResult = [self requestLocal];
            if (requestHandler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [[AppServices sharedAppServices] performSelector:requestHandler withObject:jsonResult];
            }
#pragma clang diagnostic pop
        });
        return YES;
    }
    
    return NO;
}

- (ServiceResult*) performSynchronousRequestLocal{
    
	
	//Get the ServiceResult here
    if ([self localCall]) {
        return [self requestLocal];
    }
    return nil;
}

- (ServiceResult *)requestLocal{
    needsSync = YES;
    
    BOOL processed = NO;
    ServiceResult *jsonResult = nil;
    LocalData *localData = [LocalData sharedLocal];
    NSNumberFormatter *numberFormater = [LocalData  numberFormatter];
    if ([serviceName isEqualToString:@"players"]) {
        if ([methodName isEqualToString:@"updatePlayerLocation"]) {
            if ([AppModel sharedAppModel].currentGame) {
                MPlayer *player = [localData playerForId:[[arguments objectAtIndex:0] intValue]];
                MGame *game = [localData gameForId:[[arguments objectAtIndex:1] intValue]];
                NSNumberFormatter *f = [LocalData numberFormatter];
                CLLocationDegrees latitude = [[f numberFromString:[[self arguments] objectAtIndex:2]] doubleValue];
                CLLocationDegrees longitude = [[f numberFromString:[[self arguments] objectAtIndex:2]] doubleValue];
                [localData updatePlayerLocation:player game:game latitude:latitude longitude:longitude];
            }
            processed = YES;
        }
        else if ([methodName isEqualToString:@"updatePlayerLastGame"]) {
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:0] intValue]];
            MGame *game = [localData gameForId:[[arguments objectAtIndex:1] intValue]];
            [localData updatePlayer:player game:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"pickupItemFromLocation"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            MItem *item = [localData itemForId:[[arguments objectAtIndex:2] intValue]];
            MLocation *location = [localData locationForId:[[arguments objectAtIndex:3] intValue]];
            NSNumber *qty = [numberFormater numberFromString:[arguments objectAtIndex:4]];
            [localData pickupItem:item player:player game:game location:location qty:qty];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"mapViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            [localData mapViewedByPlayer:player game:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"itemViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            MItem *item = [localData itemForId:[[arguments objectAtIndex:2] intValue]];
            [localData itemViewedByPlayer:player game:game item:item];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"nodeViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            MNode *node = [localData nodeForId:[[arguments objectAtIndex:2] intValue]];
            [localData nodeViewedByPlayer:player game:game node:node];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"npcViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            MNpc *npc = [localData npcForId:[[arguments objectAtIndex:2] intValue]];
            [localData npcViewedByPlayer:player game:game npc:npc];
            processed = YES;
        }
        else if([methodName isEqualToString:@"questsViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            [localData questsViewedByPlayer:player game:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"inventoryViewed"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            [localData inventoryViewedByPlayer:player game:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"startOverGameForPlayer"]) {
            processed = YES;
        }
        else if ([methodName isEqualToString:@"dropItem"]) {
            MGame *game = [localData gameForId:[arguments[0] intValue]];
            MPlayer *player = [localData playerForId:[arguments[1] intValue]];
            MItem *item = [localData itemForId:[arguments[2] intValue]];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[arguments[3] doubleValue] longitude:[arguments[4] doubleValue]];
            NSNumber *qty = [numberFormater numberFromString:arguments[5]];
            [localData dropItem:item player:player game:game location:location qty:qty];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"setShowPlayerOnMap"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"games"]) {
        if ([methodName isEqualToString:@"getGamesForPlayerAtLocation"]) {
            jsonResult = [localData gamesForPlayer:[[[self arguments] objectAtIndex:0] intValue] latitude:[[[self arguments] objectAtIndex:1] doubleValue] longitude:[[[self arguments] objectAtIndex:2] doubleValue] distance:[[[self arguments] objectAtIndex:3] doubleValue] locational:[[[self arguments] objectAtIndex:4] boolValue]  includeGamesInDevelopment:[[[self arguments] objectAtIndex:5] boolValue]];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getTabBarItemsForGame"]) {
            NSUInteger gameId = [[self.arguments objectAtIndex:0] intValue];
            MGame *game = [localData gameForId:gameId];
            jsonResult = [localData tabBarItemsForGame:game];
            processed = YES;
        }
        else if([methodName isEqualToString:@"getRecentGamesForPlayer"]) {
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:0] intValue]];
            double latitude = [[arguments objectAtIndex:1] doubleValue];
            double longitude = [[arguments objectAtIndex:2] doubleValue];
            BOOL showGamesInDevelopment = [[arguments objectAtIndex:3] boolValue];
            jsonResult = [localData recentGamesForPlayer:player latitude:latitude longitude:longitude _Bool:showGamesInDevelopment];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getPopularGames"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getOneGame"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
//            BOOL locationInfo = [[arguments objectAtIndex:2] boolValue];
//            int skipAtDistance = [[arguments objectAtIndex:3] intValue];
            double latitude = [[arguments objectAtIndex:4] doubleValue];
            double longitude = [[arguments objectAtIndex:5] doubleValue];
            jsonResult = [localData game:game player:player latitude:latitude longitude:longitude includeGamesInDevelopment:YES];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"items"]) {
        if ([methodName isEqualToString:@"getItems"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            jsonResult = [localData itemsForGame:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getItemsForPlayer"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            jsonResult = [localData itemsForPlayer:player game:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"createItemAndGiveToPlayer"]) {
            
        }
    }
    else if ([serviceName isEqualToString:@"npcs"]) {
        if ([methodName isEqualToString:@"getNpcs"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            jsonResult = [localData npcsForGame:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getNpcConversationsForPlayerAfterViewingNode"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MNpc *npc = [localData npcForId:[[arguments objectAtIndex:1] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:2] intValue]];
            MNode *node = [localData nodeForId:[[arguments objectAtIndex:3] intValue]];
            
            jsonResult = [localData conversationsForPlayer:player afterViewingNode:node npc:npc game:game];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"nodes"]) {
        if ([methodName isEqualToString:@"getNodes"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            jsonResult = [localData nodesForGame:game];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"media"]) {
        if ([methodName isEqualToString:@"getMedia"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            jsonResult = [localData mediasForGame:game];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getMediaObject"]) {
            //MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            NSNumber *mediaId = @([[arguments objectAtIndex:1] intValue]);
            jsonResult = [localData mediaForId:mediaId];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"locations"]) {
        if ([methodName isEqualToString:@"getLocationsForPlayer"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            jsonResult = [localData locationsForPlayer:player game:game];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"quests"]) {
        if ([methodName isEqualToString:@"getQuestsForPlayer"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            jsonResult = [localData questsForPlayer:player game:game];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"qrcodes"]) {
        if ([methodName isEqualToString:@"getQRCodeNearbyObjectForPlayer"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            NSString *code = [arguments objectAtIndex:1];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:2] intValue]];
            jsonResult = [localData qrCodeForCode:code player:player game:game];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"notes"]) {
        if ([methodName isEqualToString:@"getNotesForGame"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
        else if ([methodName isEqualToString:@"getNotesForPlayer"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"augbubbles"]) {
        if ([methodName isEqualToString:@"getAugBubbles"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"webpages"]) {
        if ([methodName isEqualToString:@"getWebPages"]) {
#warning TODO
            NSDictionary *result =  @{@"data" : @[]};
            jsonResult =  [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
            processed = YES;
        }
    }
    else if ([serviceName isEqualToString:@"overlays"]) {
        if ([methodName isEqualToString:@"getCurrentOverlaysForPlayer"]) {
            MGame *game = [localData gameForId:[[arguments objectAtIndex:0] intValue]];
            MPlayer *player = [localData playerForId:[[arguments objectAtIndex:1] intValue]];
            jsonResult =  [localData currentOverlaysForPlayer:player game:game];
            processed = YES;
        }
    }
    
    if (processed) {
        return jsonResult;
    }
	
	// inform the user
    NSError *error = [NSError errorWithDomain:@"offline" code:1 userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
	// inform the user
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[[AppServices sharedAppServices]  resetCurrentlyFetchingVars];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    return jsonResult;
}

@end
