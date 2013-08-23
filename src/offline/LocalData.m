//
//  LocalData.m
//  ARIS
//
//  Created by Miodrag Glumac on 2/22/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import "LocalData.h"
#import "NSURLConnection+block.h"
#import "ARISAppDelegate.h"
#import "MPlayer.h"
#import "MGame.h"
#import "MTab.h"
#import "MItem.h"
#import "MMedia.h"
#import "NSData+md5.h"
#import "MNpc.h"
#import "MLocation.h"
#import "MRequirement.h"
#import "MQuest.h"
#import "MPlayerLog.h"
#import "MComment.h"
#import "MNode.h"
#import "MPlayerItem.h"
#import "LocalMap.h"
#import "MMap.h"
#import "MNpcConversation.h"
#import "MQRCode.h"
#import "MPlayerStateChange.h"
#import "MMedia.h"
#import "MOverlay.h"
#import "MOverlayTile.h"
#import "AppModel.h"
#import "Reachability.h"

#import "AppModel.h"
#import "AppServices.h"

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC
#endif


// const
NSString * const kLOG_LOGIN = @"LOGIN";
NSString * const kLOG_MOVE = @"MOVE";
NSString * const kLOG_PICKUP_ITEM = @"PICKUP_ITEM";
NSString * const kLOG_DROP_ITEM = @"DROP_ITEM";
NSString * const kLOG_DESTROY_ITEM = @"DESTROY_ITEM";
NSString * const kLOG_VIEW_ITEM = @"VIEW_ITEM";
NSString * const kLOG_VIEW_NODE = @"VIEW_NODE";
NSString * const kLOG_VIEW_NPC = @"VIEW_NPC";
NSString * const kLOG_VIEW_WEBPAGE = @"VIEW_WEBPAGE";
NSString * const kLOG_VIEW_AUGBUBBLE = @"VIEW_AUGBUBBLE";
NSString * const kLOG_VIEW_MAP = @"VIEW_MAP";
NSString * const kLOG_VIEW_QUESTS = @"VIEW_QUESTS";
NSString * const kLOG_VIEW_INVENTORY = @"VIEW_INVENTORY";
NSString * const kLOG_ENTER_QRCODE = @"ENTER_QRCODE";
NSString * const kLOG_UPLOAD_MEDIA_ITEM = @"UPLOAD_MEDIA_ITEM";
NSString * const kLOG_UPLOAD_MEDIA_ITEM_IMAGE = @"UPLOAD_MEDIA_ITEM_IMAGE";
NSString * const kLOG_UPLOAD_MEDIA_ITEM_AUDIO = @"UPLOAD_MEDIA_ITEM_AUDIO";
NSString * const kLOG_UPLOAD_MEDIA_ITEM_VIDEO = @"UPLOAD_MEDIA_ITEM_VIDEO";

NSString * const kLOG_RECEIVE_WEBHOOK = @"RECEIVE_WEBHOOK";
NSString * const kLOG_COMPLETE_QUEST = @"COMPLETE_QUEST";

//constants for gameID_requirements table enums
NSString * const kREQ_PLAYER_HAS_ITEM = @"PLAYER_HAS_ITEM";
NSString * const kREQ_PLAYER_VIEWED_ITEM = @"PLAYER_VIEWED_ITEM";
NSString * const kREQ_PLAYER_VIEWED_NODE = @"PLAYER_VIEWED_NODE";
NSString * const kREQ_PLAYER_VIEWED_NPC = @"PLAYER_VIEWED_NPC";
NSString * const kREQ_PLAYER_VIEWED_WEBPAGE = @"PLAYER_VIEWED_WEBPAGE";
NSString * const kREQ_PLAYER_VIEWED_AUGBUBBLE = @"PLAYER_VIEWED_AUGBUBBLE";
NSString * const kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM = @"PLAYER_HAS_UPLOADED_MEDIA_ITEM";
NSString * const kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE = @"PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE";
NSString * const kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO = @"PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO";
NSString * const kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO = @"PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO";
NSString * const kREQ_PLAYER_HAS_COMPLETED_QUEST = @"PLAYER_HAS_COMPLETED_QUEST";
NSString * const kREQ_PLAYER_HAS_RECEIVED_INCOMING_WEBHOOK = @"PLAYER_HAS_RECEIVED_INCOMING_WEB_HOOK";

NSString * const kRESULT_DISPLAY_NODE = @"Node";
NSString * const kRESULT_DISPLAY_QUEST = @"QuestDisplay";
NSString * const kRESULT_COMPLETE_QUEST = @"QuestComplete";
NSString * const kRESULT_DISPLAY_LOCATION = @"Location";
NSString * const kRESULT_EXECUTE_WEBHOOK = @"OutgoingWebhook";

//NSString *ants for player_state_changes table enums
NSString * const kPSC_GIVE_ITEM = @"GIVE_ITEM";
NSString * const kPSC_TAKE_ITEM = @"TAKE_ITEM";	

@interface LocalData () {
    NSUInteger _gameId;
}

- (id)fetchForEntityName:(NSString *)entityName predicate:(NSPredicate*)predicate;
- (id)fetchForEntityName:(NSString *)entityName idName:(NSString*)idName idValue:(NSInteger)idValue;
- (NSManagedObjectContext*)managedObjectContext;
- (void)updateMedia:(MMedia *)media semaphore:(dispatch_semaphore_t)semaphore;

// server stuff
- (MGame*)storeGame:(NSDictionary*)gameDictionary medias:(NSMutableArray*)medias;
- (void)storeItems:(NSArray *)itemssDictionary game:(MGame*)game medias:(NSMutableArray*)medias;
- (void)storeQuests:(NSArray *)questsDictionary game:(MGame*)game player:(MPlayer *)player medias:(NSMutableArray*)medias;
- (void)storeNodes:(NSArray *)nodesDictionary game:(MGame*)game medias:(NSMutableArray*)medias;
- (void)storeNpcs:(NSArray *)ncsDictionary game:(MGame*)game medias:(NSMutableArray*)medias;
- (void)storeLocations:(NSArray *)locationsDictionary game:(MGame*)game player:(MPlayer *)player medias:(NSMutableArray*)medias;
- (void)storeOverlays:(NSArray *)overlaysArray game:(MGame*)game medias:(NSMutableArray*)medias;
- (BOOL)playerHasLog:(MPlayer*)player game:(MGame*)game eventType:(NSString*)eventType eventDetail:(NSString*)eventDetail;
- (BOOL)playerHasItem:(MPlayer*)player game:(MGame*)game itemId:(NSString*)itemId minQuantity:(NSString*)minQuantity;
- (BOOL)playerHasUploadedMediaItemWithinDistance:(MPlayer*)player game:(MGame*)game latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude distance:(CLLocationDistance)distance mediaType:(NSString*)mediaType;
- (NSDictionary*)dictionaryWithQuest:(MQuest*)mquest;
- (NSDictionary*)dictionaryWithGame:(MGame*)game;
- (NSMutableDictionary*)dictionaryWithItem:(MItem*)item;
- (NSDictionary*)dictionaryWithLocation:(MLocation*)location;
- (void)appendLogForPlayer:(MPlayer*)player game:(MGame*)game type:(NSString*)type detail1:(NSString*)detail1 detail2:(NSString*)detail2;
- (void)appendLogForPlayer:(MPlayer*)player game:(MGame*)game type:(NSString*)type detail1:(NSString*)detail1 detail2:(NSString*)detail2;
- (void)stateChangeForPlayer:(MPlayer*)player game:(MGame*)game type:(NSString*)type detail:(NSString*)detail;



@end

@implementation LocalData {
    BOOL _storingLocally;
}

- (id)init {
    if (self = [super init]) {
        _storingLocally = NO;
    }
    return self;
}

+(NSNumberFormatter *)numberFormatter {
    static dispatch_once_t pred;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&pred, ^{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    });
    return formatter;
}

+(NSDateFormatter *)dateFormatter {
    static dispatch_once_t pred;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&pred, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return formatter;
}

+(LocalData *)sharedLocal {
    static dispatch_once_t pred;
    static LocalData *local = nil;
    dispatch_once(&pred, ^{
        local = [[LocalData alloc] init];
    });
    return local;
}


#pragma mark - managed context

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"aris" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"offline.sqlite"];
    
//#warning debugging
//    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark 


- (MGame*)gameForId:(NSUInteger)gameId {
    return [self fetchForEntityName:@"Game" idName:@"gameId" idValue:gameId];   
}

- (MPlayer*)playerForId:(NSUInteger)playerId {
    return [self fetchForEntityName:@"Player" idName:@"playerId" idValue:playerId];
}

- (MItem*)itemForId:(NSUInteger)itemId {
    return [self fetchForEntityName:@"Item" idName:@"itemId" idValue:itemId];
}

- (MLocation*)locationForId:(NSUInteger)locationId {
    return [self fetchForEntityName:@"Location" idName:@"locationId" idValue:locationId];
}

- (MNpc*)npcForId:(NSUInteger)npcId {
    return [self fetchForEntityName:@"Npc" idName:@"npcId" idValue:npcId];    
}

- (MNode*)nodeForId:(NSUInteger)nodeId {
    return [self fetchForEntityName:@"Node" idName:@"nodeId" idValue:nodeId];
}

- (id)fetchForEntityName:(NSString *)entityName predicate:(NSPredicate*)predicate {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    
    id managedObject;
    if ([fetchedObjects count] > 0) {
        managedObject = [fetchedObjects lastObject];
    }
    else {
        managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    
    return managedObject;
}

- (id)fetchForEntityName:(NSString *)entityName idName:(NSString*)idName idValue:(NSInteger)idValue {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ = %%d", idName];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, idValue];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects lastObject];
    }
    else {
        return nil;
    }
}

- (void)appendLogForPlayer:(MPlayer*)player game:(MGame*)game type:(NSString*)type detail1:(NSString*)detail1 detail2:(NSString*)detail2 {
    MPlayerLog *playerLog = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerLog" inManagedObjectContext:self.managedObjectContext];
    playerLog.player = player;
    playerLog.game = game;
    playerLog.eventType = type;
    playerLog.timestamp = [NSDate date];
    playerLog.sync = [NSNumber numberWithBool:YES];
    if (detail1) {
        playerLog.eventDetail1 = detail1;
    }
    if (detail2) {
        playerLog.eventDetail2 = detail2;
    }
}

- (void)stateChangeForPlayer:(MPlayer*)player game:(MGame*)game type:(NSString*)type detail:(NSString*)detail {
    NSLog(@"state change");
    // get the status change
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerStateChange" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@ AND eventType = %@ AND eventDetail = %@", game, type, detail];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        //
    }
    
    if ([fetchedObjects count] > 0) {
        MPlayerStateChange *playerStateChange = [fetchedObjects lastObject];
        MItem *item = [self fetchForEntityName:@"Item" predicate:[NSPredicate predicateWithFormat:@"itemId = %@ AND game = %@", playerStateChange.actionDetail, game]];
        if ([playerStateChange.action isEqualToString:@"GIVE_ITEM"]) {
            [self adjustItem:item player:player amount:[playerStateChange.actionAmount intValue] game:game];
        }
        if ([playerStateChange.action isEqualToString:@"TAKE_ITEM"]) {
            [self adjustItem:item player:player amount:-[playerStateChange.actionAmount intValue] game:game];
        }       
        
    }
}


- (void)updatePlayerLocation:(MPlayer*)player game:(MGame*)game latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    NSManagedObjectContext *context = [self managedObjectContext];
    // get the player, currently assuming it has only the current player
    player.latitude = [NSNumber numberWithDouble:latitude];
    player.longitude = [NSNumber numberWithDouble:longitude];
    NSError *error;
    if (![context save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)updateServer:(void (^)(BOOL success))block {
#warning not done yet
#warning remove
    if (block) {
        block(YES);
    }
    return;
    int gameId = [[AppModel sharedAppModel] currentGame].gameId;
    int playerId = [AppModel sharedAppModel].player.playerId;
    MGame *game = [self gameForId:gameId];
    if (!game) {
        if (block) {
            block(YES);
        }
        return;
    }
    MPlayer *player = [self playerForId:playerId];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:game.gameId forKey:@"gameId"];
    [data setObject:player.playerId forKey:@"playerId"];
    BOOL needsUpdate = NO;
    // update players log
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@ and player = %@ and sync = %@", game, player, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
    }
    if ([fetchedObjects count] > 0) {
        needsUpdate = YES;
        NSMutableArray *playerLogs = [[NSMutableArray alloc] init];
        for (MPlayerLog *playerLog in fetchedObjects) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[[[playerLog objectID] URIRepresentation] absoluteString] forKey:@"id"];
            [dictionary setValue:playerLog.player.playerId forKey:@"player_id"];
            [dictionary setValue:playerLog.game.gameId forKey:@"game_id"];
            [dictionary setValue:[NSNumber numberWithInt:[playerLog.timestamp timeIntervalSince1970]] forKey:@"timestamp"];
            [dictionary setValue:playerLog.eventType forKey:@"event_type"];
            [dictionary setValue:playerLog.eventDetail1 forKey:@"event_detail_1"];
            [dictionary setValue:playerLog.eventDetail2 forKey:@"event_detail_2"];
            [playerLogs addObject:dictionary];
        }
        [data setObject:playerLogs forKey:@"player_logs"];
    }
    
    // update players items
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"PlayerItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"game = %@ and player = %@ and sync = %@", game, player, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
    }
    if ([fetchedObjects count] > 0) {
        needsUpdate = YES;
        NSMutableArray *playerItems = [[NSMutableArray alloc] init];
        for (MPlayerItem *playerItem in fetchedObjects) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[[[playerItem objectID] URIRepresentation] absoluteString] forKey:@"id"];
            [dictionary setValue:playerItem.player.playerId forKey:@"player_id"];
            [dictionary setValue:playerItem.item.itemId forKey:@"item_id"];
            [dictionary setValue:playerItem.quantity forKey:@"qty"];
            [dictionary setValue:[NSNumber numberWithInt:[playerItem.timestamp timeIntervalSince1970]] forKey:@"timestamp"];
            [playerItems addObject:dictionary];
        }
        [data setObject:playerItems forKey:@"player_items"];
    }
    
    // update locations quantities
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"game = %@ and player = %@ and sync = %@", game, player, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:predicate];
    fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
    }
    if ([fetchedObjects count] > 0) {
        needsUpdate = YES;
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (MLocation *location in fetchedObjects) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:[[[location objectID] URIRepresentation] absoluteString] forKey:@"id"];
            [dictionary setValue:location.locationId forKey:@"location_id"];
            [dictionary setValue:location.itemQty forKey:@"item_qty"];
            [locations addObject:dictionary];
        }
        [data setObject:locations forKey:@"locations"];
    }
    
    NSString *json = [data JSONRepresentation];
    
    if (!needsUpdate) {
        if (block) {
            block(YES);
        }
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"server/sync/update.php" relativeToURL:[AppModel sharedAppModel].serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[json dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request finishBlock:^(NSData *data) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *result = [jsonString JSONValue];
        NSArray *playerLogIds = [result objectForKey:@"player_logs"];
        BOOL changed = NO;
        if (playerLogIds) {
            changed = YES;
            for (NSString *playerLogId in playerLogIds) {
                NSManagedObjectID *objectID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:playerLogId]];
                MPlayerLog *playerLog = (MPlayerLog*)[self.managedObjectContext objectWithID:objectID];
                playerLog.sync = [NSNumber numberWithBool:NO];
            }
        }
        NSArray *playerItemIds = [result objectForKey:@"player_items"];
        if (playerItemIds) {
            changed = YES;
            for (NSString *playerItemId in playerItemIds) {
                NSManagedObjectID *objectID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:playerItemId]];
                MPlayerItem *playerItem = (MPlayerItem*)[self.managedObjectContext objectWithID:objectID];
                playerItem.sync = [NSNumber numberWithBool:NO];
            }
        }
        NSArray *locationIds = [result objectForKey:@"locations"];
        if (locationIds) {
            changed = YES;
            for (NSString *locationId in locationIds) {
                NSManagedObjectID *objectID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:locationId]];
                MLocation *location = (MLocation*)[self.managedObjectContext objectWithID:objectID];
                location.sync = [NSNumber numberWithBool:NO];
            }
        }
        BOOL success = YES;
        NSError *error;
        if (changed) {
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"%@", [error userInfo]);
                success = NO;
            }
        }
        else {
            success = NO; // something had to change
        }
        if (block) {
            block(success);
        }
    } errorBlock:^(NSError *error) {
        if (block) {
            block(NO);
        }
        NSLog(@"error"); 
    }];
    if (!connection) {
        if (block) {
            block(NO);
        }
        NSLog(@"error");    
    }
}

- (void)storeGame:(Game*)game completion:(store_locally_block_t)block {
    if (_storingLocally) return;
    _storingLocally = YES;
    _gameId = game.gameId;
    
    NSString *urlString = @"server/sync/";
    NSString *str = [NSString stringWithFormat:@"action=get_all&id=%d&player_id=%d", _gameId, [AppModel sharedAppModel].player.playerId];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[AppModel sharedAppModel].serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request finishBlock:^(NSData *data){
        //NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        block(@"Storing Game", 0.0, NO);
        
        _managedObjectContext = nil;
        _managedObjectModel = nil;
        _persistentStoreCoordinator = nil;
        
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"aris.sqlite"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]] && ![[NSFileManager defaultManager] removeItemAtPath:[storeURL path] error:&error]) {
            NSLog(@"Error removing file");
            exit(0);
        }
         
        MPlayer *player = [self storePlayer:[info objectForKey:@"player"]];
        NSMutableArray *medias = [NSMutableArray array];
        MGame *game = [self storeGame:[info objectForKey:@"game"] medias:medias];
        [self storeTabs:[info objectForKey:@"tabs"] game:game];
        block(@"Storing Game", 1.0/13.0, NO);
        [self storeRequirements:[info objectForKey:@"requirements"] game:game];
        block(@"Storing Game", 2.0/13.0, NO);
        [self storeItems:[info objectForKey:@"items"] game:game medias:medias];
        block(@"Storing Game", 3.0/13.0, NO);
        [self storeQuests:[info objectForKey:@"quests"] game:game player:player medias:medias];
        block(@"Storing Game", 4.0/13.0, NO);
        [self storeNodes:[info objectForKey:@"nodes"] game:game medias:medias];
        block(@"Storing Game", 5.0/13.0, NO);
        [self storeNpcs:[info objectForKey:@"npcs"] game:game medias:medias];
        block(@"Storing Game", 6.0/13.0, NO);
        [self storeLocations:[info objectForKey:@"locations"] game:game player:player medias:medias];
        block(@"Storing Game", 7.0/13.0, NO);
        [self storePlayerLogs:[info objectForKey:@"player_logs"] game:game player:player];
        block(@"Storing Game", 8.0/13.0, NO);
        [self storePlayerItems:[info objectForKey:@"player_items"] game:game player:player];
        block(@"Storing Game", 9.0/13.0, NO);
        [self storeNpcConversations:[info objectForKey:@"npc_conversations"] game:game];
        block(@"Storing Game", 10.0/13.0, NO);
        [self storeQRCodes:[info objectForKey:@"qrcodes"] game:game];
        block(@"Storing Game", 11.0/13.0, NO);
        [self storePlayerStateChanges:[info objectForKey:@"player_state_changes"] game:game];
        block(@"Storing Game", 12.0/13.0, NO);
        [self storeOverlays:[info objectForKey:@"overlays"] game:game medias:medias];
        block(@"Storing Game", 13.0/13.0, NO);

        
        // save changes
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error userInfo]);
        }
        
        // update medias
        dispatch_queue_t q_update_media = dispatch_queue_create("edu.amherst.update_media", NULL);
        dispatch_semaphore_t fd_sema = dispatch_semaphore_create(1);
        size_t index = 0;
        for (MMedia *media in medias) {
            index++;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            dispatch_async(q_update_media, ^{
                dispatch_semaphore_wait(fd_sema, DISPATCH_TIME_FOREVER);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateMedia:media semaphore:fd_sema];
                    block([NSString stringWithFormat:@"Downloading media files: %ld / %d",  index, [medias count]], (float)index / (float)[medias count], NO);
                });
            });
        }
        index = 0;
        dispatch_async(q_update_media, ^{
            dispatch_semaphore_wait(fd_sema, DISPATCH_TIME_FOREVER);
            dispatch_async(dispatch_get_main_queue(), ^{
                /*
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Download" message: @"Download Finished" delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
                 [alert show];
                 */
                NSLog(@"sync finished");
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                dispatch_semaphore_signal(fd_sema);
                _storingLocally = NO;
                block(@"Finished", 1.0, YES);
            });
        });
    } errorBlock:^(NSError *error){} progressBlock:^(float progress){
        block(@"Downloading Game", progress, NO);
    }];
    if (!connection) {
        // handle error
    }    
}

- (MPlayer*)storePlayer:(NSDictionary*)playerDictionary {
    MPlayer *mplayer = [self fetchForEntityName:@"Player" predicate:[NSPredicate predicateWithFormat:@"playerId = %@", [playerDictionary objectForKey:@"player_id"]]];
    mplayer.playerId = [NSNumber numberWithInt:[[playerDictionary objectForKey:@"player_id"]intValue]];
    mplayer.userName = [playerDictionary objectForKey:@"user_name"];
    mplayer.latitude = [NSNumber numberWithDouble:[[playerDictionary objectForKey:@"latitude"] doubleValue] ];
    mplayer.longitude = [NSNumber numberWithDouble:[[playerDictionary objectForKey:@"longitude"] doubleValue] ];
    return mplayer;
}

- (MGame*)storeGame:(NSDictionary*)gameDictionary medias:(NSMutableArray*)medias {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSNumberFormatter *f = [LocalData numberFormatter];
    MGame *mgame = [self fetchForEntityName:@"Game" predicate:[NSPredicate predicateWithFormat:@"gameId = %@", [gameDictionary objectForKey:@"game_id"]]];
    mgame.name = [gameDictionary objectForKey:@"name"];
    mgame.gameId = [f numberFromString:[gameDictionary objectForKey:@"game_id"]];
    mgame.gameDescription = [gameDictionary objectForKey:@"description"];
    int iconMediaId = [[gameDictionary objectForKey:@"icon_media_id"] intValue];
    if (iconMediaId) {
        MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", iconMediaId]];
        mmedia.mediaId = [NSNumber numberWithInt:iconMediaId];
        mgame.icon = mmedia;
        [medias addObject:mmedia];
    }
    int mediaId = [[gameDictionary objectForKey:@"media_id"] intValue];
    if (mediaId) {
        MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", mediaId]];
        mmedia.mediaId = [NSNumber numberWithInt:mediaId];
        mgame.media = mmedia;
        [medias addObject:mmedia];
    }
    mgame.allowPlayerCreatedLocations = [f numberFromString:[gameDictionary objectForKey:@"allow_player_created_locations"]];
    mgame.deletePlayerLocationsOnReset = [f numberFromString:[gameDictionary objectForKey:@"delete_player_locations_on_reset"]];
    mgame.isLocational = [f numberFromString:[gameDictionary objectForKey:@"is_locational"]];
    // TODO: nodes
    /*
     [on_launch_node_id] => 0
     [game_complete_node_id] => 0
     */
    if ([[gameDictionary objectForKey:@"rating"] isKindOfClass:[NSNumber class]]) {
        mgame.rating = [gameDictionary objectForKey:@"rating"];
    }
    else {
        mgame.rating = [f numberFromString:[gameDictionary objectForKey:@"rating"]];        
    }
    if ([[gameDictionary objectForKey:@"calculatedScore"] isKindOfClass:[NSNumber class]]) {
        mgame.calculatedScore = [gameDictionary objectForKey:@"calculatedScore"];
    }
    else {
        mgame.calculatedScore = [f numberFromString:[gameDictionary objectForKey:@"calculatedScore"]];
    }
    mgame.offline = @([gameDictionary[@"offline"] boolValue]);
    mgame.hasBeenPlayed = @([gameDictionary[@"has_been_played"] boolValue]);
    for (MComment *comment in mgame.comments) {
        [context deleteObject:comment];
    }
    for (NSDictionary *commentDictionary in [gameDictionary objectForKey:@"comments"]) {
        NSNumber *playerId = [f numberFromString:[commentDictionary objectForKey:@"playerId"]];
        MPlayer *player = [self playerForId:[playerId intValue]];
        MComment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
        comment.player = player;
        comment.game = mgame;
        comment.rating = [f numberFromString:[commentDictionary objectForKey:@"rating"]];
        comment.text = [commentDictionary objectForKey:@"text"];
    }

    return mgame;
}

- (void)storeTabs:(NSArray *)tabsDictionary game:(MGame*)mgame {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tab = $TAB"];
    NSNumberFormatter *f = [LocalData numberFormatter];
    NSIndexSet *indexesToCreate = [tabsDictionary indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *tabDictionary = (NSDictionary*)obj;
        NSDictionary *variables = [NSDictionary dictionaryWithObject:[tabDictionary objectForKey:@"tab"] forKey:@"TAB"];
        NSSet *filteredSet = [mgame.tabs filteredSetUsingPredicate:[predicate predicateWithSubstitutionVariables:variables]];
        if ([filteredSet count] > 0) {
            return NO;
        }
        return  YES;
    }];
    
    [indexesToCreate enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSDictionary *tabDictionary = [tabsDictionary objectAtIndex:idx];
        MTab *mtab = [NSEntityDescription insertNewObjectForEntityForName:@"Tab" inManagedObjectContext:context];
        mtab.tab = [tabDictionary valueForKey:@"tab"];
        mtab.index = [f numberFromString:[tabDictionary valueForKey:@"tab_index"]];
        mtab.game = mgame;
    }];
}

- (void)storeRequirements:(NSArray *)requirementsDictionary game:(MGame*)game{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    NSManagedObjectContext *context = [self managedObjectContext];
    // sort requriements
    [requirementsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"requirement_id"] compare:[obj2 objectForKey:@"requirement_id"] options:NSNumericSearch];
    }];
    NSArray *ids = [requirementsDictionary valueForKey:@"requirement_id"];
    // get the requirements
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Requirement" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"requirementId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"requirementId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MRequirement *requirement = [enumerator nextObject];
    for (NSDictionary *requirementDictionary in requirementsDictionary) {
        int requirementId = [[requirementDictionary objectForKey:@"requirement_id"] intValue];
        // get the requirements
        if (requirement && [requirement.requirementId intValue] == requirementId) {
            requirement = [enumerator nextObject];
        }
        else {
            // create
            MRequirement *newRequirement = [NSEntityDescription insertNewObjectForEntityForName:@"Requirement" inManagedObjectContext:context];
            newRequirement.requirementId = [f numberFromString:[requirementDictionary objectForKey:@"requirement_id"]];
            newRequirement.booleanOperator = [requirementDictionary objectForKey:@"boolean_operator"];
            newRequirement.contentType = [requirementDictionary objectForKey:@"content_type"];
            newRequirement.contentId = [NSNumber numberWithInt:[[requirementDictionary objectForKey:@"content_id"] intValue]];
            newRequirement.requirement = [requirementDictionary objectForKey:@"requirement"];
            newRequirement.requirementDetail1 = [requirementDictionary objectForKey:@"requirement_detail_1"];
            newRequirement.requirementDetail2 = [requirementDictionary objectForKey:@"requirement_detail_2"];
            newRequirement.requirementDetail3 = [requirementDictionary objectForKey:@"requirement_detail_3"];
            newRequirement.notOperator = [requirementDictionary objectForKey:@"not_operator"];
            newRequirement.groupOperator = [requirementDictionary objectForKey:@"group_operator"];
            newRequirement.game = game;
        }
    }
}

- (void)storeItems:(NSArray *)itemsDictionary game:(MGame *)game medias:(NSMutableArray*)medias {
    NSManagedObjectContext *context = [self managedObjectContext];
    // process items
    itemsDictionary = [itemsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"item_id"] compare:[obj2 objectForKey:@"item_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [itemsDictionary valueForKey:@"item_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"itemId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MItem *mitem = [enumerator nextObject];
    for (NSDictionary *itemDictionary in itemsDictionary) {
        int itemId = [[itemDictionary objectForKey:@"item_id"] intValue];
        if (mitem && [mitem.itemId intValue] == itemId) {
            mitem = [enumerator nextObject];
        }
        else {
            Item *item = [[Item alloc] initWithDictionary:itemDictionary];
            MItem *newMItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:context];
            newMItem.name = item.name;
            newMItem.itemId = [NSNumber numberWithInt:item.itemId];
            newMItem.game = game;
            
            newMItem.itemDescription = item.description;
            newMItem.destroyable = [NSNumber numberWithBool:item.destroyable];
            newMItem.dropable = [NSNumber numberWithBool:item.dropable];
            newMItem.maxQtyInInventory = [NSNumber numberWithInt:item.maxQty];
            newMItem.kind = [NSNumber numberWithInt:item.itemType];
            newMItem.url = item.url;
            newMItem.weight = [NSNumber numberWithInt:item.weight];
            if (item.iconMediaId > 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", item.iconMediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:item.iconMediaId];
                mmedia.game = game;
                newMItem.icon = mmedia;
                [medias addObject:mmedia];
            }
            if (item.mediaId > 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", item.mediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:item.mediaId];
                mmedia.game = game;
                newMItem.media = mmedia;
                [medias addObject:mmedia];
            }
        }
    }
}

- (void)storeQuests:(NSArray *)questsDictionary game:(MGame *)game player:(MPlayer *)player medias:(NSMutableArray*)medias {
    NSManagedObjectContext *context = [self managedObjectContext];
    questsDictionary = [questsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"quest_id"] compare:[obj2 objectForKey:@"quest_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quest" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"questId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [questsDictionary valueForKey:@"quest_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"questId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MQuest *mquest = [enumerator nextObject];
    for (NSDictionary *questDictionary in questsDictionary) {
        int questId = [[questDictionary objectForKey:@"quest_id"] intValue];
        if (mquest && [mquest.questId intValue] == questId) {
            mquest = [enumerator nextObject];
        }
        else {
            MQuest *newMQuest = [NSEntityDescription insertNewObjectForEntityForName:@"Quest" inManagedObjectContext:context];
            newMQuest.name = [questDictionary objectForKey:@"name"];
            newMQuest.questId = [NSNumber numberWithInt:[[questDictionary objectForKey:@"quest_id"] intValue]];
            newMQuest.questDescription = [questDictionary objectForKey:@"description"];
            newMQuest.textWhenComplete = [questDictionary objectForKey:@"text_when_complete"];
            newMQuest.sortIndex = [NSNumber numberWithInt:[[questDictionary objectForKey:@"sort_index"] intValue]];
            newMQuest.game = game;
            newMQuest.player = player;
            // TODO: others
            int iconMediaId = [[questDictionary objectForKey:@"icon_media_id"] intValue];
            if (iconMediaId != 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", iconMediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:iconMediaId];
                mmedia.game = game;
                newMQuest.icon = mmedia;
                [medias addObject:mmedia];
            }
        }
    }
}

- (void)storeNodes:(NSArray *)nodesDictionary game:(MGame *)game medias:(NSMutableArray*)medias {
    NSManagedObjectContext *context = [self managedObjectContext];
    nodesDictionary = [nodesDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"node_id"] compare:[obj2 objectForKey:@"node_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"nodeId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [nodesDictionary valueForKey:@"node_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"nodeId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MNode *mnode = [enumerator nextObject];
    for (NSDictionary *nodeDictionary in nodesDictionary) {
        int nodeId = [[nodeDictionary objectForKey:@"node_id"] intValue];
        if (mnode && [mnode.nodeId intValue] == nodeId) {
            mnode = [enumerator nextObject];
        }
        else {
            MNode *newMNode = [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:context];
            if ([nodeDictionary objectForKey:@"name"] != [NSNull null]) {
                newMNode.name = [nodeDictionary objectForKey:@"name"];;
            }
            newMNode.nodeId = [[LocalData numberFormatter] numberFromString:[nodeDictionary objectForKey:@"node_id"]];
            newMNode.game = game;
            if ([nodeDictionary objectForKey:@"npc_id"] != [NSNull null]) {
                int npcId = [[nodeDictionary objectForKey:@"npc_id"] intValue];
                if (npcId > 0) {
                    MNpc *npc = [self fetchForEntityName:@"Npc" idName:@"npcId" idValue:npcId];
                    if (npc) {
                        newMNode.npc = npc;
                    }
                }
            }
            NSDictionary *optNodea = [NSDictionary dictionaryWithObjectsAndKeys:[nodeDictionary objectForKey:@"opt1_node_id"], @"opt1Node", 
                                      [nodeDictionary objectForKey:@"opt2_node_id"], @"opt2Node",
                                      [nodeDictionary objectForKey:@"opt3_node_id"], @"opt3Node", nil];
            for (NSString *optNodeStr in optNodea) {
                int optNodeId = [optNodeStr intValue];
                if (optNodeId > 0) {
                    MNode *optNode = [self fetchForEntityName:@"Node" idName:@"nodeId" idValue:optNodeId];
                    if (optNode) {
                        [newMNode setValue:optNode forKey:[optNodea objectForKey:optNodeStr]];
                    }  
                }
            }            
            if ([[nodeDictionary objectForKey:@"opt1_text"] isMemberOfClass:[NSString class]]) {
                newMNode.opt1Text = [nodeDictionary objectForKey:@"opt1_text"];
            }
            if ([[nodeDictionary objectForKey:@"opt2_text"] isMemberOfClass:[NSString class]]) {
                newMNode.opt2Text = [nodeDictionary objectForKey:@"opt2_text"];
            }
            if ([[nodeDictionary objectForKey:@"opt3_text"] isMemberOfClass:[NSString class]]) {
                newMNode.opt3Text = [nodeDictionary objectForKey:@"opt3_text"];
            }
            newMNode.text = [nodeDictionary objectForKey:@"text"];
            newMNode.title = [nodeDictionary objectForKey:@"title"];
            newMNode.game = game;
            int mediaId = [[nodeDictionary objectForKey:@"media_id"] intValue];
            if (mediaId != 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", mediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:mediaId];
                mmedia.game = game;
                newMNode.media = mmedia;
                [medias addObject:mmedia];
            }            
            int iconMediaId = [[nodeDictionary objectForKey:@"icon_media_id"] intValue];
            if (iconMediaId != 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", iconMediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:iconMediaId];
                mmedia.game = game;
                newMNode.icon = mmedia;
                [medias addObject:mmedia];
            }
            int correctNodeId = [[nodeDictionary objectForKey:@"require_answer_correct_node_id"] intValue]; 
            if (correctNodeId > 0) {
                MNode *correctNode = [self fetchForEntityName:@"Node" idName:@"nodeId" idValue:correctNodeId];
                if (correctNode) {
                    newMNode.requireAnswerCorrectNode = correctNode;
                }
            }
            int incorrectNodeId = [[nodeDictionary objectForKey:@"require_answer_incorrect_node_id"] intValue];
            if (incorrectNodeId > 0) {
                MNode *incorrectNode = [self fetchForEntityName:@"Node" idName:@"nodeId" idValue:correctNodeId];
                if (incorrectNode) {
                    newMNode.requireAnswerCorrectNode = incorrectNode;
                }
            }
        }
    }
}

- (void)storeNpcs:(NSArray *)npcsDictionary game:(MGame *)game medias:(NSMutableArray*)medias {
    NSManagedObjectContext *context = [self managedObjectContext];
    npcsDictionary = [npcsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"npc_id"] compare:[obj2 objectForKey:@"npc_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Npc" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"npcId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [npcsDictionary valueForKey:@"npc_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"npcId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MNpc *mnpc = [enumerator nextObject];
    for (NSDictionary *npcDictionary in npcsDictionary) {
        int npcId = [[npcDictionary objectForKey:@"npc_id"] intValue];
        if (mnpc && [mnpc.npcId intValue] == npcId) {
            mnpc = [enumerator nextObject];
        }
        else {
            MNpc *newMNpc = [NSEntityDescription insertNewObjectForEntityForName:@"Npc" inManagedObjectContext:context];
            Npc *npc = [[Npc alloc] initWithDictionary:npcDictionary];
            newMNpc.npcId = [NSNumber numberWithInt:npcId];
            newMNpc.name = npc.name;
            newMNpc.npcDescription = npc.description;
            newMNpc.text = npc.greeting;
            newMNpc.closing = npc.closing;
            newMNpc.game = game;
            // TODO: others
            if (npc.mediaId != 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", npc.mediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:npc.mediaId];
                mmedia.game = game;
                newMNpc.media = mmedia;
                [medias addObject:mmedia];
            }
            if (npc.iconMediaId != 0) {
                MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", npc.iconMediaId]];
                mmedia.mediaId = [NSNumber numberWithInt:npc.iconMediaId];
                mmedia.game = game;
                newMNpc.icon = mmedia;
                [medias addObject:mmedia];
            }
        }
    }
    
    //{"npc_id":"1","name":"Character 1","description":"","text":"Hello","closing":"By","media_id":"0","icon_media_id":"1"}
}

- (void)storeLocations:(NSArray *)locationsDictionary game:(MGame *)game player:(MPlayer*)player medias:(NSMutableArray *)medias{
    NSManagedObjectContext *context = [self managedObjectContext];
    locationsDictionary = [locationsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"location_id"] compare:[obj2 objectForKey:@"location_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"locationId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [locationsDictionary valueForKey:@"location_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"locationId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MLocation *mlocation = [enumerator nextObject];
    for (NSDictionary *locationDictionary in locationsDictionary) {
        int locationId = [[locationDictionary objectForKey:@"location_id"] intValue];
        Location *location = [[Location alloc] initWithDictionary:locationDictionary];
        if (mlocation && [mlocation.locationId intValue] == locationId) {
            mlocation.error = [NSNumber numberWithDouble:location.errorRange];
            mlocation.itemQty = [NSNumber numberWithInt:location.qty];
            mlocation = [enumerator nextObject];
        }
        else {
            MLocation *mNewLocation = [self fetchForEntityName:@"Location" predicate:[NSPredicate predicateWithFormat:@"locationId = %d", location.locationId]];
            mNewLocation.locationId = [NSNumber numberWithInt:location.locationId];
            mNewLocation.allowsQuickTravel = [NSNumber numberWithBool:location.allowsQuickTravel];
            // mNewLocation.locationDescription = location.description;
            mNewLocation.error = [NSNumber numberWithDouble:location.errorRange];
            mNewLocation.hidden = [NSNumber numberWithBool:location.hidden];
            mNewLocation.itemQty = [NSNumber numberWithInt:location.qty];
            mNewLocation.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
            mNewLocation.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
            mNewLocation.name = location.name;
            mNewLocation.type = locationDictionary[@"type"];
            mNewLocation.typeId = [NSNumber numberWithInt:[locationDictionary[@"type_id"] intValue]];
            mNewLocation.game = game;
            mNewLocation.player = player;
            int iconMediaId = [[locationDictionary objectForKey:@"icon_media_id"] intValue];
            if (iconMediaId) {
                MMedia *media = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", iconMediaId]];
                media.mediaId = [NSNumber numberWithInt:iconMediaId];
                media.game = game;
                mNewLocation.icon = media;
                [medias addObject:media];
            }        
        }
    }
}


- (void)storePlayerLogs:(NSArray *)logsDictionary game:(MGame *)game player:(MPlayer *)player {
    NSManagedObjectContext *context = [self managedObjectContext];
    logsDictionary = [logsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"id"] compare:[obj2 objectForKey:@"id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerLogId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [logsDictionary valueForKey:@"id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playerLogId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSDateFormatter* dateFormatter = [LocalData dateFormatter];
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MPlayerLog *mplayerLog = [enumerator nextObject];
    for (NSDictionary *logDictionary in logsDictionary) {
        int logId = [[logDictionary objectForKey:@"id"] intValue];
        if (mplayerLog && [mplayerLog.playerLogId intValue] == logId) {
            mplayerLog = [enumerator nextObject];
        }
        else {
            MPlayerLog *mNewPlayerLog = [self fetchForEntityName:@"PlayerLog" predicate:[NSPredicate predicateWithFormat:@"playerLogId = %d", logId]];
            mNewPlayerLog.playerLogId = [NSNumber numberWithInt:[[logDictionary objectForKey:@"id"] intValue]];
            mNewPlayerLog.playerId = [NSNumber numberWithInt:[[logDictionary objectForKey:@"player_id"] intValue]];
            mNewPlayerLog.timestamp = [dateFormatter dateFromString:[logDictionary objectForKey:@"timestamp"]];
            mNewPlayerLog.eventType = [logDictionary objectForKey:@"event_type"];
            mNewPlayerLog.eventDetail1 = [logDictionary objectForKey:@"event_detail_1"];
            mNewPlayerLog.eventDetail2 = [logDictionary objectForKey:@"event_detail_2"];
            mNewPlayerLog.sync = [NSNumber numberWithBool:NO];
            mNewPlayerLog.game = game;
            mNewPlayerLog.player = player;
        }
    }
    
    //"id":"5504","player_id":"98","game_id":"2","timestamp":"2011-09-22 16:40:57","event_type":"VIEW_QUESTS","event_detail_1":"","event_detail_2":"","deleted":"0"
}

- (void)storePlayerItems:(NSArray *)playerItemsDictionary game:(MGame*)game player:(MPlayer*)player {
    NSManagedObjectContext *context = [self managedObjectContext];
    // process items
    playerItemsDictionary = [playerItemsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"item_id"] compare:[obj2 objectForKey:@"item_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item.itemId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [playerItemsDictionary valueForKey:@"item_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"item.itemId in %@ AND player = %@ AND game = %@", ids, player, game]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MPlayerItem *playerItem = [enumerator nextObject];
    for (NSDictionary *playerItemDictionary in playerItemsDictionary) {
        int itemId = [[playerItemDictionary objectForKey:@"item_id"] intValue];
        if (playerItem && [playerItem.item.itemId intValue] == itemId) {
            playerItem = [enumerator nextObject];
        }
        else {
            MPlayerItem *newMPlayerItem = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerItem" inManagedObjectContext:context];
            MItem *item = [self fetchForEntityName:@"Item" idName:@"itemId" idValue:[[playerItemDictionary objectForKey:@"item_id"] intValue]];
            newMPlayerItem.item = item;
            newMPlayerItem.player = player;
            newMPlayerItem.game = game;
            newMPlayerItem.quantity = [[LocalData numberFormatter] numberFromString:[playerItemDictionary objectForKey:@"qty"]];
            newMPlayerItem.sync = [NSNumber numberWithBool:NO];
        }
    }
}

- (void)storeNpcConversations:(NSArray *)npcConversationsDictionary game:(MGame*)game {
    // process items
    npcConversationsDictionary = [npcConversationsDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"conversation_id"] compare:[obj2 objectForKey:@"conversation_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NpcConversation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"conversationId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [npcConversationsDictionary valueForKey:@"conversation_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"conversationId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MNpcConversation *conversation = [enumerator nextObject];
    for (NSDictionary *npcConversationDictionary in npcConversationsDictionary) {
        int conversationId = [[npcConversationDictionary objectForKey:@"conversation_id"] intValue];
        if (conversation && [conversation.conversationId intValue] == conversationId) {
            conversation = [enumerator nextObject];
        }
        else {
            MNpcConversation *newMNpcConversation = [NSEntityDescription insertNewObjectForEntityForName:@"NpcConversation" inManagedObjectContext:self.managedObjectContext];
            MNode *node = [self fetchForEntityName:@"Node" idName:@"nodeId" idValue:[[npcConversationDictionary objectForKey:@"node_id"] intValue]];
            MNpc *npc = [self fetchForEntityName:@"Npc" idName:@"npcId" idValue:[[npcConversationDictionary objectForKey:@"npc_id"] intValue]];
            newMNpcConversation.conversationId = [[LocalData numberFormatter] numberFromString:[npcConversationDictionary objectForKey:@"conversation_id"]];
            newMNpcConversation.node = node;
            newMNpcConversation.npc = npc;
            newMNpcConversation.text = [npcConversationDictionary objectForKey:@"text"];
            newMNpcConversation.sortIndex = [[LocalData numberFormatter] numberFromString:[npcConversationDictionary objectForKey:@"sort_index"]];
        }
    }
}

- (void)storeQRCodes:(NSArray *)qrCodesDictionary game:(MGame*)game {
    // process items
    qrCodesDictionary = [qrCodesDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"qrcode_id"] compare:[obj2 objectForKey:@"qrcode_id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QRCode" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"qrCodeId" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [qrCodesDictionary valueForKey:@"qrcode_id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"qrCodeId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MQRCode *qrCode = [enumerator nextObject];
    for (NSDictionary *qrCodeDictionary in qrCodesDictionary) {
        int qrCodeId = [[qrCodeDictionary objectForKey:@"conversation_id"] intValue];
        if (qrCode && [qrCode.qrCodeId intValue] == qrCodeId) {
            qrCode = [enumerator nextObject];
        }
        else {
            MQRCode *newMQRCode = [NSEntityDescription insertNewObjectForEntityForName:@"QRCode" inManagedObjectContext:self.managedObjectContext];
            newMQRCode.qrCodeId = [[LocalData numberFormatter] numberFromString:[qrCodeDictionary objectForKey:@"qrcode_id"]];
            newMQRCode.linkType = [qrCodeDictionary objectForKey:@"link_type"];
            newMQRCode.linkId =  [[LocalData numberFormatter] numberFromString:[qrCodeDictionary objectForKey:@"link_id"]];
            newMQRCode.matchMediaId =  [[LocalData numberFormatter] numberFromString:[qrCodeDictionary objectForKey:@"match_media_id"]];
            newMQRCode.code =  [qrCodeDictionary objectForKey:@"code"];
            newMQRCode.game = game;
        }
    }
    
}

- (void)storePlayerStateChanges:(NSArray *)playerStateChangesDictionary game:(MGame*)game {
    if (playerStateChangesDictionary == nil) {
        return;
    }
    playerStateChangesDictionary = [playerStateChangesDictionary sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 objectForKey:@"id"] compare:[obj2 objectForKey:@"id"] options:NSNumericSearch];
    }];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerStateChange" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerStateChangeId" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *ids = [playerStateChangesDictionary valueForKey:@"id"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"playerStateChangeId in %@", ids]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // handler error
    }
    
    NSEnumerator *enumerator = [fetchedObjects objectEnumerator];
    MPlayerStateChange *playerStateChange = [enumerator nextObject];
    NSNumberFormatter *formatter = [LocalData numberFormatter];
    for (NSDictionary *playerStateChangeDictionary in playerStateChangesDictionary) {
        int playerStateChangeId = [[playerStateChangeDictionary objectForKey:@"id"] intValue];
        if (playerStateChange && [playerStateChange.playerStateChangeId intValue] == playerStateChangeId) {
            playerStateChange = [enumerator nextObject];
        }
        else {
            MPlayerStateChange *newPlayerStateChange = [NSEntityDescription insertNewObjectForEntityForName:@"PlayerStateChange" inManagedObjectContext:self.managedObjectContext];
            newPlayerStateChange.playerStateChangeId = [formatter numberFromString:[playerStateChangeDictionary objectForKey:@"id"]];
            newPlayerStateChange.eventType = [playerStateChangeDictionary objectForKey:@"event_type"];
            newPlayerStateChange.eventDetail = [formatter numberFromString:[playerStateChangeDictionary objectForKey:@"event_detail"]];
            newPlayerStateChange.action = [playerStateChangeDictionary objectForKey:@"action"];
            newPlayerStateChange.actionDetail = [formatter numberFromString:[playerStateChangeDictionary objectForKey:@"action_detail"]];
            newPlayerStateChange.actionAmount = [formatter numberFromString:[playerStateChangeDictionary objectForKey:@"action_amount"]];
            newPlayerStateChange.game = game;
        }
    }
}

- (void)storeOverlays:(NSArray *)overlaysArray game:(MGame*)game medias:(NSMutableArray*)medias {
    NSFetchRequest *fetchOverlays = [NSFetchRequest fetchRequestWithEntityName:@"Overlay"];
    fetchOverlays.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"overlayId" ascending:YES]];
    fetchOverlays.predicate = [NSPredicate predicateWithFormat:@"game = %@", game];
    NSError *error;
    NSArray *fetchedOverlays = [_managedObjectContext executeFetchRequest:fetchOverlays error:&error];
    NSEnumerator *overlayEnumerator = [fetchedOverlays objectEnumerator];
    
    MOverlay *overlay = [overlayEnumerator nextObject];
    for (NSDictionary *overlayDictionary in overlaysArray) {
        // does it exist
        int overlayId = [overlayDictionary[@"overlay_id"] intValue];
        if (overlay && overlay.overlayId == overlayId) {
            [self storeOVerlayTiles:overlayDictionary[@"tiles"] game:game overlay:overlay medias:medias];
            overlay = [overlayEnumerator nextObject];
        }
        else {
            MOverlay *newOverlay = [NSEntityDescription insertNewObjectForEntityForName:@"Overlay" inManagedObjectContext:_managedObjectContext];
            newOverlay.game = game;
            newOverlay.overlayId = [overlayDictionary[@"overlay_id"] intValue];
            newOverlay.sortOrder = [overlayDictionary[@"sort_index"] intValue];
            if (overlayDictionary[@"alpha"] != [NSNull null]) {
                newOverlay.alpha = [overlayDictionary[@"alpha"] floatValue];
            }
            else {
                newOverlay.alpha = 1.0;
            }
            if (overlayDictionary[@"num_tiles"] != [NSNull null]) {
                newOverlay.numTiles = [overlayDictionary[@"num_tiles"] intValue];
            }
            newOverlay.name = overlayDictionary[@"name"];
            if (overlayDictionary[@"description"] != [NSNull null]) {
                newOverlay.overlayDescription = overlayDictionary[@"description"];
            }
            [self storeOVerlayTiles:overlayDictionary[@"tiles"] game:game overlay:newOverlay medias:medias];
        }
    }
    
    
    return;
}

- (void)storeOVerlayTiles:(NSArray*)tilesArray game:(MGame*)game overlay:(MOverlay*)overlay medias:(NSMutableArray*)medias {
    NSFetchRequest *fetchTiles = [NSFetchRequest fetchRequestWithEntityName:@"OverlayTile"];
    fetchTiles.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"zoom" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"x" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES]];
    fetchTiles.predicate = [NSPredicate predicateWithFormat:@"overlay = %@", overlay];
    NSError *error;
    NSArray *fetchedTiles = [_managedObjectContext executeFetchRequest:fetchTiles error:&error];
    NSEnumerator *tileEnumerator = [fetchedTiles objectEnumerator];
    MOverlayTile *tile = [tileEnumerator nextObject];
    for (NSDictionary *tileDictionary in tilesArray) {
        int zoom = [tileDictionary[@"zoom"] intValue];
        int x = [tileDictionary[@"x"] intValue];
        int y = [tileDictionary[@"y"] intValue];
        if (tile && tile.zoom == zoom && tile.x == x && tile.y == y) {
            tile = [tileEnumerator nextObject];
        }
        else {
            MOverlayTile *newTile = [NSEntityDescription insertNewObjectForEntityForName:@"OverlayTile" inManagedObjectContext:_managedObjectContext];
            newTile.overlay = overlay;
            newTile.zoom = [tileDictionary[@"zoom"] intValue];
            newTile.x = [tileDictionary[@"x"] intValue];
            newTile.y = [tileDictionary[@"y"] intValue];
            if (tileDictionary[@"x_max"] != [NSNull null]) {
                newTile.xMax = [tileDictionary[@"x_max"] intValue];
            }
            if (tileDictionary[@"y_max"] != [NSNull null]) {
                newTile.yMax = [tileDictionary[@"y_max"] intValue];
            }
            int mediaId = [tileDictionary[@"media_id"] intValue];
            MMedia *mmedia = [self fetchForEntityName:@"Media" predicate:[NSPredicate predicateWithFormat:@"mediaId = %d", mediaId]];
            mmedia.mediaId = @(mediaId);
            mmedia.game = game;
            newTile.media = mmedia;
            [medias addObject:mmedia];
        }
    }
}

- (void)updateMedia:(MMedia *)media semaphore:(dispatch_semaphore_t)semaphore {
    // first get the info
    NSString *urlString = @"server/sync/";
    NSString *str = [NSString stringWithFormat:@"action=get_media_info&id=%@&gameId=%lu", media.mediaId, (unsigned long)_gameId];
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[AppModel sharedAppModel].serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request finishBlock:^(NSData *data){
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *mediaInfo = [jsonString JSONValue];
        NSDictionary *mediaData = [mediaInfo objectForKey:@"data"];
        if (mediaData == (id)[NSNull null]) {
            return;
        }
        // see if there is a file 
        NSString *documentsDirectory =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSNumber *isDefault = [mediaData objectForKey:@"is_default"];
        NSString *filePath = [mediaData objectForKey:@"file_path"];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:filePath];
        
        BOOL downloaded = NO;
        if ([media.filePath isEqualToString:filePath] && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *fileData = [NSData dataWithContentsOfFile:path];
            NSString *md5 = [fileData md5];
            if ([md5 isEqualToString:[mediaInfo objectForKey:@"md5"]]) {
                downloaded = YES;
            }
            else {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
        else {
        }
        if (!downloaded) {
            // TODO: synchronize??
            NSURL *mediaURL = [NSURL URLWithString:filePath relativeToURL:[NSURL URLWithString:[mediaData objectForKey:@"url_path"]]];
            //NSLog(@"%@", mediaURL);
            NSURLConnection *mediaConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:mediaURL] finishBlock:^(NSData *data){
                // save to file
                // create directory if it does not exist
                NSError *error = nil;
                NSString *dirName = [isDefault boolValue] ? @"0" : [NSString stringWithFormat:@"%lu", (unsigned long)_gameId];
                if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:dirName]]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:dirName] withIntermediateDirectories:NO attributes:nil error:&error];
                }
                BOOL result = [data writeToFile:path atomically:NO];
                if (result) {                    
                    NSManagedObjectContext *context = [self managedObjectContext];
                    media.filePath = filePath;
                    media.md5 = [mediaInfo objectForKey:@"md5"];
                    media.defaultMedia = isDefault;
                    //media.type = [mediaData objectForKey:@"type"];
                    media.type = mediaData[@"type"];
                    //NSLog(@"******name: %@ and id: %@", media.fileName, media.mediaId);
                    error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Error: %@", [error localizedDescription]);
                    }
                }
                else {
                    NSLog(@"Error: %@", [error localizedDescription]);                    
                }
                dispatch_semaphore_signal(semaphore);
            } errorBlock:^(NSError *error){
                dispatch_semaphore_signal(semaphore);
            }];
            if (!mediaConnection) {
                // TODO: report error
                dispatch_semaphore_signal(semaphore);
            }
        }
        else {
            dispatch_semaphore_signal(semaphore);
        }
    } errorBlock:^(NSError *error){
        dispatch_semaphore_signal(semaphore);
    }];
    if (!connection) {
        // TODO: report error
        dispatch_semaphore_signal(semaphore);
    }   
}

/*
- (void)updateFile:(NSDictionary*)fileDictionary semaphore:(dispatch_semaphore_t)semaphore {
    // create directory if it does not exist
    NSURL *cacheDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *dirURL = [[cacheDirectory URLByAppendingPathComponent:[@(_gameId) stringValue]] URLByAppendingPathComponent:[fileDictionary objectForKey:@"path"]];
    // now download the file
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"server/gamedata/%lu/%@/%@", (unsigned long)_gameId, [fileDictionary objectForKey:@"path"], [fileDictionary objectForKey:@"filename"]] relativeToURL:[AppModel sharedAppModel].serverURL];
    NSURL *path = [dirURL URLByAppendingPathComponent:[fileDictionary objectForKey:@"filename"]];
    NSURLConnection *fileConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:fileURL] finishBlock:^(NSData *data){
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[dirURL path]]) {
            if (![[NSFileManager defaultManager] createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"Error creating file dir");
                exit(0);
            }
        }
        [data writeToURL:path atomically:NO];
        dispatch_semaphore_signal(semaphore);
    } errorBlock:^(NSError *error){
        dispatch_semaphore_signal(semaphore);
    }];
    if (!fileConnection) {
        dispatch_semaphore_signal(semaphore);
    }
}
 */

// implementation of server stuff
- (BOOL)meetsRequirementsForId:(NSNumber *)objectId objectType:(NSString*)objectType game:(MGame*)game player:(MPlayer*)player {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Requirement" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@ AND contentType = %@ AND contentId = %@", game, objectType, objectId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *requirements = [context executeFetchRequest:fetchRequest error:&error];
    if (requirements == nil) {
        //
    }
    
    BOOL andsMet = NO;
    BOOL requirementsExist = NO;
    for (MRequirement *requirement in requirements) {
        requirementsExist = YES;
        BOOL requirementMet = NO;
        if ([kREQ_PLAYER_VIEWED_ITEM isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_VIEW_ITEM eventDetail:requirement.requirementDetail1]; 
        }
        else if ([kREQ_PLAYER_VIEWED_NODE isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_VIEW_NODE eventDetail:requirement.requirementDetail1];        
        }
        else if ([kREQ_PLAYER_VIEWED_NPC isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_VIEW_NPC eventDetail:requirement.requirementDetail1];
        }
        else if ([kREQ_PLAYER_VIEWED_WEBPAGE isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_VIEW_WEBPAGE eventDetail:requirement.requirementDetail1];
        }
        else if ([kREQ_PLAYER_VIEWED_AUGBUBBLE isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_VIEW_AUGBUBBLE eventDetail:requirement.requirementDetail1];
        }
        else if ([kREQ_PLAYER_HAS_RECEIVED_INCOMING_WEBHOOK isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_RECEIVE_WEBHOOK eventDetail:requirement.requirementDetail1];
        }
        //Inventory related	
        else if ([kREQ_PLAYER_HAS_ITEM isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasItem:player game:game itemId:requirement.requirementDetail1 minQuantity:requirement.requirementDetail2];
        }
        //Data Collection
        else if ([kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasUploadedMediaItemWithinDistance:player game:game latitude:[requirement.requirementDetail1 doubleValue] longitude:[requirement.requirementDetail2 doubleValue] distance:[requirement.requirementDetail3 doubleValue] mediaType:kLOG_UPLOAD_MEDIA_ITEM];
        }
        else if ([kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_AUDIO isEqualToString:requirement.requirement]) {
            requirementMet =[self playerHasUploadedMediaItemWithinDistance:player game:game latitude:[requirement.requirementDetail1 doubleValue] longitude:[requirement.requirementDetail2 doubleValue] distance:[requirement.requirementDetail3 doubleValue] mediaType:kLOG_UPLOAD_MEDIA_ITEM_AUDIO];
        }
        else if ([kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_VIDEO isEqualToString:requirement.requirement]) {
            requirementMet =[self playerHasUploadedMediaItemWithinDistance:player game:game latitude:[requirement.requirementDetail1 doubleValue] longitude:[requirement.requirementDetail2 doubleValue] distance:[requirement.requirementDetail3 doubleValue] mediaType:kLOG_UPLOAD_MEDIA_ITEM_VIDEO];
        }
        else if ([kREQ_PLAYER_HAS_UPLOADED_MEDIA_ITEM_IMAGE isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasUploadedMediaItemWithinDistance:player game:game latitude:[requirement.requirementDetail1 doubleValue] longitude:[requirement.requirementDetail2 doubleValue] distance:[requirement.requirementDetail3 doubleValue] mediaType:kLOG_UPLOAD_MEDIA_ITEM_IMAGE];
        }
        else if ([kREQ_PLAYER_HAS_COMPLETED_QUEST isEqualToString:requirement.requirement]) {
            requirementMet = [self playerHasLog:player game:game eventType:kLOG_COMPLETE_QUEST eventDetail:requirement.requirementDetail1];
        }	
        
        //Account for the 'NOT's
        if ([requirement.notOperator isEqualToString:@"NOT"]) {
            requirementMet = !requirementMet;
        }
        
        if ([requirement.booleanOperator isEqualToString:@"AND"] && requirementMet == NO) {
            return NO;
        }
        
        if ([requirement.booleanOperator isEqualToString:@"AND"] && requirementMet == YES) {
            andsMet = YES;
        }
        
        if ([requirement.booleanOperator isEqualToString:@"OR"] && requirementMet == YES){
            return TRUE;
        }
        /*
         if ([requirement.booleanOperator isEqualToString:@"OR"] && requirementMet == NO){
         requirementsMet = NO;
         }
         */
    }
    if (!requirementsExist) {
        //NetDebug::trace("No requirements exist. Requirements Passed.");
        return YES;
    }
    if (andsMet) {
        //NetDebug::trace("All AND requirements exist. Requirements Passed.");
        return YES;
    }
    else {
        //NetDebug::trace("At end. Requirements Not Passed.");			
        return NO;
    }
}

- (BOOL)playerHasLog:(MPlayer*)player game:(MGame*)game eventType:(NSString*)eventType eventDetail:(NSString*)eventDetail {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"player = %@ AND game = %@ AND eventType = %@ AND eventDetail1 = %@", player, game, eventType, eventDetail];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        //
    }
    return [fetchedObjects count] > 0;
}
- (BOOL)playerHasItem:(MPlayer*)player game:(MGame*)game itemId:(NSString*)itemId minQuantity:(NSString*)minQuantity {
    NSNumber *quantity = [NSNumber numberWithInt:1];
    if ([minQuantity length] > 0) {
        NSNumber *newQuantity = [[LocalData numberFormatter] numberFromString:minQuantity];
        if (newQuantity != nil) {
            quantity = newQuantity;
        }
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"player = %@ AND game = %@ AND item.itemId = %@ AND quantity >= %@", player, game, [[LocalData numberFormatter] numberFromString:itemId], quantity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        //
        return NO;
    }
    if ([fetchedObjects count] > 0) {
        return YES;
    }
    return NO;
}


- (BOOL)playerHasUploadedMediaItemWithinDistance:(MPlayer*)player game:(MGame*)game latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude distance:(CLLocationDistance)distance mediaType:(NSString*)mediaType {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // get the possible ids for the media
    NSFetchRequest *fetchRequestLog = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityLog = [NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:context];
    [fetchRequestLog setEntity:entityLog];
    
    
    // first get the item ids that are uploaded
    NSPredicate *predicateLog = [NSPredicate predicateWithFormat:@"player = %@ AND game = %@ AND eventType = %@ AND deleted = 0", player, game, mediaType];
    [fetchRequestLog setPredicate:predicateLog];
    
    NSError *error = nil;
    NSArray *fetchedLogs = [context executeFetchRequest:fetchRequestLog error:&error];
    if (fetchedLogs == nil) {
        //
    }
    // now get the items
    NSArray *itemIds = [fetchedLogs valueForKey:@"event_detail_1"];
    NSFetchRequest *fetchRequestItem = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityItem = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [fetchRequestItem setEntity:entityItem];
    
    NSPredicate *predicateItem = [NSPredicate predicateWithFormat:@"itemId in %@", itemIds];
    [fetchRequestItem setPredicate:predicateItem];
    
    NSArray *fetchedItems = [context executeFetchRequest:fetchRequestItem error:&error];
    if (fetchedItems == nil) {
        //
    }
    
    // now calculate distance
    for (MItem *mitem in fetchedItems) {
        CLLocationDegrees origin_latitude = [mitem.originLatitude doubleValue];
        CLLocationDegrees origin_longitude = [mitem.originLongitude doubleValue];
        double itemDistance = (((acos(sin((latitude*M_PI/180)) * sin((origin_latitude*M_PI/180))+cos((latitude*M_PI/180)) * 
                                      cos((origin_latitude*M_PI/180)) * 
                                      cos(((longitude - origin_longitude)*M_PI/180))))*180/M_PI)*60*1.1515*1.609344*1000);
        if (itemDistance < distance) {
            return YES;
        }
    }
    
    return NO;
}


///    
- (ServiceResult*)gamesForPlayer:(int)playerId latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude distance:(CLLocationDistance)distance locational:(BOOL)locational includeGamesInDevelopment:(BOOL)includeGamesInDevelopment {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Game" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocational = %d", locational];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        //
    }
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    // TODO:
    
    NSMutableArray *games = [[NSMutableArray alloc] init];
    for (MGame *mgame in fetchedObjects) {
        // use location
        [games addObject:[self dictionaryWithGame:mgame]];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:games forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)game:(MGame*)game player:(MPlayer*)player latitude:(double)latitude longitude:(double)longitude includeGamesInDevelopment:(BOOL)includeGamesInDevelopment {
    NSArray *games = @[[self dictionaryWithGame:game]];
    NSDictionary *result = [NSDictionary dictionaryWithObject:games forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (MPlayer*)playerWithId:(NSInteger)playerid {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playerId = %d", playerid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        //
    }
    if ([fetchedObjects count] > 0) {
        return [fetchedObjects lastObject];
    }
    return nil;
}

- (NSDictionary*) dictionaryWithGame:(MGame*)game
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //NSNumberFormatter *f = [AppServices formatter];
    [dictionary setObject:game.gameId forKey:@"game_id"];
    [dictionary setObject:game.name forKey:@"name"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *cacheURL = [[[fileManager URLsForDirectory:NSCachesDirectory  inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[game.gameId stringValue]];
    if (game.icon) {
        [dictionary setObject:game.icon.mediaId forKey:@"icon_media_id"];
        dictionary[@"icon_media_url"] = [[cacheURL URLByAppendingPathComponent:game.icon.filePath] absoluteString];
    }
    if (game.media) {
        [dictionary setObject:game.media.mediaId forKey:@"media_id"];
        dictionary[@"media_url"] = [[cacheURL URLByAppendingPathComponent:game.media.filePath] absoluteString];
    }
    [dictionary setObject:game.allowPlayerCreatedLocations forKey:@"allow_player_created_locations"];
    [dictionary setObject:game.deletePlayerLocationsOnReset forKey:@"delete_player_locations_on_reset"];
    [dictionary setObject:game.isLocational forKey:@"locational"];
    [dictionary setObject:game.inventoryWeightCap forKey:@"inventory_weight_cap"];
    [dictionary setObject:[NSNumber numberWithInt:[game.quests count]] forKey:@"totalQuests"];
    // completed qeusts
    NSMutableArray *comments = [[NSMutableArray array] init];
    for (MComment *comment in game.comments) {
        
        [comments addObject:[NSDictionary dictionaryWithObjectsAndKeys:comment.player.playerId, @"playerId",
                             comment.player.userName, @"username",
                             comment.rating, @"rating",
                             comment.text, @"text", nil]];
    }
    [dictionary setObject:game.calculatedScore forKey:@"calculatedScore"];
    [dictionary setObject:[NSNumber numberWithInt:[game.comments count]] forKey:@"numComments"];
    [dictionary setObject:game.rating forKey:@"rating"];
    [dictionary setValue:game.gameDescription forKey:@"description"];
    dictionary[@"offline"] = game.offline;
    dictionary[@"has_been_played"] = game.hasBeenPlayed;
    return dictionary;
}

- (ServiceResult*)tabBarItemsForGame:(MGame*)game {
    NSArray *tabs = [game.tabs allObjects];
    [tabs sortedArrayUsingSelector:@selector(index)];
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[tabs count]];
    for (MTab *mtab in tabs) {
        [data addObject:[NSDictionary dictionaryWithObjectsAndKeys:mtab.tab, @"tab",
                         mtab.index, @"tab_index", nil]];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (void)updatePlayer:(MPlayer*)player game:(MGame*)game {
    player.lastGame = game;
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (ServiceResult*)itemsForGame:(MGame*)game {
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[game.items count]];
    for (MItem *item in game.items) {
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
        [itemDictionary setObject:item.itemId forKey:@"item_id"];
        [itemDictionary setValue:item.itemDescription forKey:@"description"];
        [itemDictionary setValue:item.dropable forKey:@"dropable"];
        [itemDictionary setValue:item.destroyable forKey:@"destroyable"];
        [itemDictionary setValue:item.originLatitude forKey:@"origin_latitude"];
        [itemDictionary setValue:item.originLongitude forKey:@"origin_longitude"];
        [itemDictionary setValue:item.originTimestamp forKey:@"origin_timestamp"];
        if (item.icon) {
            [itemDictionary setObject:item.icon.mediaId forKey:@"icon_media_id"];
        }
        if (item.media) {
            [itemDictionary setObject:item.media.mediaId forKey:@"media_id"];
        }
        [itemDictionary setValue:item.maxQtyInInventory forKey:@"max_qty_in_inventory"];
        [data addObject:[self dictionaryWithItem:item]];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)npcsForGame:(MGame*)game {
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[game.npcs count]];
    for (MNpc *npcs in game.npcs) {
        NSMutableDictionary *npcsDictionary = [[NSMutableDictionary alloc] init];
        [npcsDictionary setValue:npcs.npcId forKey:@"npc_id"];
        [npcsDictionary setValue:npcs.name forKey:@"name"];
        [npcsDictionary setValue:npcs.npcDescription forKey:@"description"];
        [npcsDictionary setValue:npcs.closing forKey:@"closing"];
        [npcsDictionary setValue:npcs.text forKey:@"text"];
        if (npcs.icon) {
            [npcsDictionary setValue:npcs.icon.mediaId forKey:@"icon_media_id"];
        }
        if (npcs.media) {
            [npcsDictionary setValue:npcs.media.mediaId forKey:@"media_id"];
        }
        [data addObject:npcsDictionary];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)nodesForGame:(MGame *)game {
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[game.nodes count]];
    for (MNode *node in game.nodes) {
        NSMutableDictionary *nodeDictionary = [[NSMutableDictionary alloc] init];
        [nodeDictionary setObject:node.nodeId forKey:@"node_id"];
        [nodeDictionary setValue:node.title forKey:@"title"];
        [nodeDictionary setValue:node.text forKey:@"text"];
        [nodeDictionary setValue:node.name forKey:@"name"];
        [nodeDictionary setValue:node.npc.npcId forKey:@"npc_id"];
        if (node.media) {
            [nodeDictionary setObject:node.media.mediaId forKey:@"media_id"];
        }
        if (node.icon) {
            [nodeDictionary setObject:node.icon.mediaId forKey:@"icon_media_id"];
        }
        if (node.opt1Node) {
            [nodeDictionary setObject:node.opt1Node.nodeId forKey:@"opt1_node_id"];
        }
        if (node.opt2Node) {
            [nodeDictionary setObject:node.opt1Node.nodeId forKey:@"opt2_node_id"];
        }        
        if (node.opt3Node) {
            [nodeDictionary setObject:node.opt1Node.nodeId forKey:@"opt3_node_id"];
        }
        [nodeDictionary setValue:node.opt1Text forKey:@"opt1_text"];
        [nodeDictionary setValue:node.opt2Text forKey:@"opt1_text"];
        [nodeDictionary setValue:node.opt3Text forKey:@"opt2_text"];
        if (node.requireAnswerCorrectNode) {
            [nodeDictionary setObject:node.requireAnswerCorrectNode.nodeId forKey:@"require_answer_correct_node_id"];
        }
        if (node.requireAnswerIncorrectNode) {
            [nodeDictionary setObject:node.requireAnswerIncorrectNode forKey:@"require_answer_incorrect_node_id"];
        }
        [data addObject:nodeDictionary];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)mediasForGame:(MGame *)game {
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[game.medias count]];
    for (MMedia *media in game.medias) {
        // check if valid, this should never happen
        if (media.md5 == nil) {
            return nil;
        }
        NSMutableDictionary *mediaDictionary = [[NSMutableDictionary alloc] init];
        [mediaDictionary setObject:media.filePath forKey:@"file_path"];
        [mediaDictionary setObject:media.defaultMedia forKey:@"is_default"];
        [mediaDictionary setObject:media.mediaId forKey:@"media_id"];
        [mediaDictionary setObject:media.type forKey:@"type"];
        NSString *cacheDirectory =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *path = [NSURL fileURLWithPath:cacheDirectory];
        [mediaDictionary setObject:[path absoluteString] forKey:@"url_path"];
        [data addObject:mediaDictionary];
    }
    
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)locationsForPlayer:(MPlayer*)player game:(MGame*)game {
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[game.medias count]];
    NSSet *locations = game.locations; // [game.locations filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"player = %@", player]];
    for (MLocation *location in locations) {
        if ([self meetsRequirementsForId:location.locationId objectType:@"Location" game:game player:player]) {
            [data addObject:[self dictionaryWithLocation:location]];
        }
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    
    
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
    
}

- (ServiceResult*)questsForPlayer:(MPlayer*)player game:(MGame*)game {
    NSMutableArray *activeQuests = [[NSMutableArray alloc] init];
    NSMutableArray *completedQuests = [[NSMutableArray alloc] init];
    
    // get quests
    for (MQuest *quest in game.quests) {
        BOOL display = [self meetsRequirementsForId:quest.questId objectType:kRESULT_DISPLAY_QUEST game:game player:player];
        BOOL complete = [self meetsRequirementsForId:quest.questId objectType:kRESULT_COMPLETE_QUEST game:game player:player];
        if (display && !complete) {
            [activeQuests addObject:[self dictionaryWithQuest:quest]];
        }
        if (display && complete) {
            //
            if (![self playerHasLog:player game:game eventType:kLOG_COMPLETE_QUEST eventDetail:[NSString stringWithFormat:@"%@", quest.questId]]) {
                [self appendLogForPlayer:player game:game type:kLOG_COMPLETE_QUEST detail1:[NSString stringWithFormat:@"%@", quest.questId] detail2:@"N/A"];
            }
            
            [completedQuests addObject:[self dictionaryWithQuest:quest]];
        }
    }
    
    NSUInteger count = [game.quests count];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:[NSNumber numberWithInt:count] forKey:@"totalQuests"];
    [data setObject:activeQuests forKey:@"active"];
    [data setObject:completedQuests forKey:@"complete"];
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (NSDictionary*)dictionaryWithQuest:(MQuest*)quest {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setValue:quest.questId forKey:@"quest_id"];
    [dictionary setValue:quest.name forKey:@"name"];
    [dictionary setValue:quest.questDescription forKey:@"description"];
    [dictionary setValue:quest.sortIndex forKey:@"sort_index"];
    if (quest.icon) {
        [dictionary setValue:quest.icon.mediaId forKey:@"icon_media_id"];
    }
    return dictionary;
}

- (NSMutableDictionary*)dictionaryWithItem:(MItem*)item {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:item.itemId forKey:@"item_id"];
    [dictionary setValue:item.itemDescription forKey:@"description"];
    [dictionary setValue:item.dropable forKey:@"dropable"];
    [dictionary setValue:item.destroyable forKey:@"destroyable"];
    [dictionary setValue:item.originLatitude forKey:@"origin_latitude"];
    [dictionary setValue:item.originLongitude forKey:@"origin_longitude"];
    [dictionary setValue:item.originTimestamp forKey:@"origin_timestamp"];
    if (item.icon) {
        [dictionary setObject:item.icon.mediaId forKey:@"icon_media_id"];
    }
    if (item.media) {
        [dictionary setObject:item.media.mediaId forKey:@"media_id"];
    }
    [dictionary setValue:item.maxQtyInInventory forKey:@"max_qty_in_inventory"];
    dictionary[@"name"] = item.name;
    return dictionary;
}

- (NSDictionary*)dictionaryWithLocation:(MLocation*)location {
    NSMutableDictionary *locationDictionary = [[NSMutableDictionary alloc] init];
    [locationDictionary setValue:location.locationId forKey:@"location_id"];
    [locationDictionary setValue:location.allowsQuickTravel forKey:@"allow_quick_travel"];
    [locationDictionary setValue:location.locationDescription forKey:@"description"];
    [locationDictionary setValue:location.error forKey:@"error"];
    [locationDictionary setValue:location.force_view forKey:@"force_view"];
    if (location.icon) {
        [locationDictionary setValue:location.icon.mediaId forKey:@"icon_media_id"];
    }
    else {
        if ([location.type isEqualToString:@"Node"]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Node"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"nodeId = %@", location.typeId]];
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil) {
            }
            MNode *node = [fetchedObjects lastObject];
            [locationDictionary setValue:node.icon.mediaId forKey:@"icon_media_id"];
        }
        else if([location.type isEqualToString:@"Npc"]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Npc"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"npcId = %@", location.typeId]];
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil) {
            }
            MNpc *npc = [fetchedObjects lastObject];
            [locationDictionary setValue:npc.icon.mediaId forKey:@"icon_media_id"];
        }
        else if([location.type isEqualToString:@"Item"]) {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"itemId = %@", location.typeId]];
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil) {
            }
            MItem *item = [fetchedObjects lastObject];
            [locationDictionary setValue:item.icon.mediaId forKey:@"icon_media_id"];
        }
    }
    [locationDictionary setValue:location.itemQty forKey:@"item_qty"];
    [locationDictionary setValue:location.latitude forKey:@"latitude"];
    [locationDictionary setValue:location.longitude forKey:@"longitude"];
    [locationDictionary setValue:location.name forKey:@"name"];
    [locationDictionary setValue:location.type forKey:@"type"];
    [locationDictionary setValue:location.typeId forKey:@"type_id"];
    return locationDictionary;
}

- (ServiceResult*)itemsForPlayer:(MPlayer*)player game:(MGame*)game {
    NSSet *playerItems = [player.playerItems filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"game = %@", game]];
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:[playerItems count]];
    for (MPlayerItem *playerItem in playerItems) {
        NSMutableDictionary *playerItemDictionary = [self dictionaryWithItem:playerItem.item];
        [playerItemDictionary setValue:playerItem.quantity forKey:@"qty"];
        [data addObject:playerItemDictionary];
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (void)pickupItem:(MItem *)item player:(MPlayer *)player game:(MGame*)game location:(MLocation *)location qty:(NSNumber *)qty {
    NSManagedObjectContext *context = [self managedObjectContext];
    MPlayerItem * playerItem = [self fetchForEntityName:@"PlayerItem" predicate:[NSPredicate predicateWithFormat:@"item = %@ AND player = %@", item, player]];
    if ([playerItem.objectID isTemporaryID]) {
        playerItem.item = item;
        playerItem.player = player;
        playerItem.quantity = [NSNumber numberWithInt:0];
        playerItem.game = game;
    }
    int oldQty = [playerItem.quantity intValue];
    int newQty = oldQty + [qty intValue];
    if ([item.maxQtyInInventory intValue] != -1 && newQty > [item.maxQtyInInventory intValue]) {
        newQty = [item.maxQtyInInventory intValue];
    }
    playerItem.quantity = [NSNumber numberWithInt:newQty];
    playerItem.sync = [NSNumber numberWithBool:YES];
    
    // decrement location quantity
    int locationQty = [location.itemQty intValue];
    if (locationQty > 0) {
        int newLocationQty = locationQty - [qty intValue];
        if (newLocationQty < 0) {
            newLocationQty = 0;
        }
        location.itemQty = [NSNumber numberWithInt:newLocationQty];
        location.sync = [NSNumber numberWithBool:YES];
    }
    
    [self appendLogForPlayer:player game:game type:kLOG_PICKUP_ITEM detail1:[NSString stringWithFormat:@"%@",item.itemId]  detail2:[NSString stringWithFormat:@"%d",(newQty - oldQty)]];
    
    NSError *error;
    if (![context save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)dropItem:(MItem*)item player:(MPlayer*)player game:(MGame*)game location:(CLLocation*)location qty:(NSNumber*)qty {
#warning TODO
    NSError *error = nil;

    // find location
    NSSet *mLocations = [game.locations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        MLocation *mLocation = obj;
        CLLocation *cLocation = [[CLLocation alloc] initWithLatitude:[mLocation.latitude doubleValue] longitude:[mLocation.longitude doubleValue]];
        return [location distanceFromLocation:cLocation] < 10 && [mLocation.type isEqualToString:@"Item"] && [mLocation.typeId isEqualToNumber:item.itemId];
    }];
    
    MLocation *mLocation = [mLocations anyObject];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"PlayerItem"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item = %@", item];
    [fetchRequest setPredicate:predicate];

    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
    }
    MPlayerItem *playerItem = [fetchedObjects lastObject];
    if (playerItem) {
        int newQuantity = [playerItem.quantity intValue] - [qty intValue];
        if (newQuantity > 0) {
            playerItem.quantity = @(newQuantity);
        }
        else {
            [_managedObjectContext deleteObject:playerItem];
        }
    }
    if ([mLocation.itemQty intValue] > -1) {
        mLocation.itemQty = @([mLocation.itemQty intValue] + [qty intValue]);
    }
    if (![_managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
    [self appendLogForPlayer:player game:game type:kLOG_DROP_ITEM detail1:[item.itemId stringValue] detail2:[qty stringValue]];
}

- (void)mapViewedByPlayer:(MPlayer*)player game:(MGame*)game {
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_MAP detail1:nil detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)itemViewedByPlayer:(MPlayer*)player game:(MGame*)game item:(MItem*)item{
    NSString *detail = [NSString stringWithFormat:@"%@",item.itemId];
    [self stateChangeForPlayer:player game:game type:kLOG_VIEW_ITEM detail:detail];
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_ITEM detail1:detail detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)npcViewedByPlayer:(MPlayer*)player game:(MGame*)game npc:(MNpc*)npc {
    NSString *detail = [NSString stringWithFormat:@"%@",npc.npcId];
    [self stateChangeForPlayer:player game:game type:kLOG_VIEW_NPC detail:detail];
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_NPC detail1:detail detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)nodeViewedByPlayer:(MPlayer*)player game:(MGame*)game node:(MNode *)node {
    NSString *detail = node ? [NSString stringWithFormat:@"%@", node.nodeId] : @"0";
    [self stateChangeForPlayer:player game:game type:kLOG_VIEW_NODE detail:detail];
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_NODE detail1:detail detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}
-(void)questsViewedByPlayer:(MPlayer *)player game:(MGame *)game {
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_QUESTS detail1:nil detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)inventoryViewedByPlayer:(MPlayer*)player game:(MGame*)game {
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_INVENTORY detail1:nil detail2:nil];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}


- (ServiceResult*)conversationsForPlayer:(MPlayer*)player afterViewingNode:(MNode*)node npc:(MNpc*)npc game:(MGame*)game {
    [self nodeViewedByPlayer:player game:game node:node];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableOrderedSet *conversations = [npc.conversations mutableCopy];
    [conversations sortUsingComparator:^(MNpcConversation *conv1, MNpcConversation *conv2) {
        //NSComparisonResult
        return [[conv1 sortIndex] compare:[conv2 sortIndex]];
    }];
    for (MNpcConversation *conversation in npc.conversations) {
        if ([self meetsRequirementsForId:conversation.node.nodeId objectType:@"Node" game:game player:player]) {
            // get logs
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            // TODO: deleted
            NSString *detail = node ? [NSString stringWithFormat:@"%@", node.nodeId] : @"0";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@ AND player = %@ AND eventType = %@ AND eventDetail1 = %@", game, player, kLOG_VIEW_NODE, detail];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil) {
            }
            BOOL nodeViewed = [fetchedObjects count] > 0;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObject:conversation.conversationId forKey:@"conversation_id"];
            [dictionary setObject:conversation.npc.npcId forKey:@"npc_id"];
            [dictionary setObject:conversation.node.nodeId forKey:@"node_id"];
            [dictionary setObject:conversation.text forKey:@"text"];
            [dictionary setObject:conversation.sortIndex forKey:@"sort_index"];
            [dictionary setObject:[NSNumber numberWithBool:nodeViewed] forKey:@"has_viewed"];
            [data addObject:dictionary];
        }
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)recentGamesForPlayer:(MPlayer*)player latitude:(double)latitude longitude:(double)longitude bool:(BOOL)showGamesInDevelopment {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)qrCodeForCode:(NSString*)code player:(MPlayer*)player game:(MGame*)game {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QRCode" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"game = %@ AND code = %@", game, code];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if ([fetchedObjects count] > 0) {
        MQRCode * qrCode = [fetchedObjects lastObject];
        // check requirements
        if ([self meetsRequirementsForId:qrCode.qrCodeId objectType:qrCode.linkType game:game player:player]) {
            [self appendLogForPlayer:player game:game type:kLOG_ENTER_QRCODE detail1:code detail2:@"INVALID"];
            NSMutableDictionary *qrCodeDictionary = [[NSMutableDictionary alloc] init];
            [qrCodeDictionary setValue:qrCode.qrCodeId forKey:@"qrcode_id"];
            [qrCodeDictionary setValue:qrCode.code forKey:@"code"];
            [qrCodeDictionary setValue:qrCode.linkType forKey:@"link_type"];
            [qrCodeDictionary setValue:qrCode.linkId forKey:@"link_id"];
            if ([qrCode.linkType isEqualToString:@"Location"]) {
                MLocation *location = [self locationForId:[qrCode.linkId intValue]];
                [qrCodeDictionary setObject:[self dictionaryWithLocation:location] forKey:@"object"];
            }
            [result setObject:qrCodeDictionary forKey:@"data"];
        }
        else {
            [self appendLogForPlayer:player game:game type:kLOG_ENTER_QRCODE detail1:code detail2:@"REQS_OR_QTY_NOT_MET"];
        }
    }
    else {
        [self appendLogForPlayer:player game:game type:kLOG_ENTER_QRCODE detail1:code detail2:@"INVALID"];
    }
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (void)startOverGameForPlayer:(MPlayer*)player game:(MGame*)game {
    NSFetchRequest *deleteLogs = [[NSFetchRequest alloc] init];
    [deleteLogs setEntity:[NSEntityDescription entityForName:@"PlayerLog" inManagedObjectContext:self.managedObjectContext]];
    [deleteLogs setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * logs = [self.managedObjectContext executeFetchRequest:deleteLogs error:&error];
    //error handling goes here
    for (NSManagedObject * log in logs) {
        [self.managedObjectContext deleteObject:log];
    }
    
    NSFetchRequest *deleteItems = [[NSFetchRequest alloc] init];
    [deleteItems setEntity:[NSEntityDescription entityForName:@"PlayerItem" inManagedObjectContext:self.managedObjectContext]];
    [deleteItems setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSArray * items = [self.managedObjectContext executeFetchRequest:deleteItems error:&error];
    //error handling goes here
    for (NSManagedObject * item in items) {
        [self.managedObjectContext deleteObject:item];
    }
    
    
    NSError *saveError = nil;
    if(![self.managedObjectContext save:&saveError]) {
        NSLog(@"%@", [saveError localizedDescription]);
    }
}

- (void)giveItem:(MItem*)item toPlayer:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game {
    [self adjustItem:item player:player amount:amount game:game];
}
- (void)takeItem:(MItem*)item fromPlayer:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game {
    [self adjustItem:item player:player amount:amount game:game];
}

- (void)adjustItem:(MItem*)item player:(MPlayer*)player amount:(NSInteger)amount game:(MGame*)game {
    NSManagedObjectContext *context = [self managedObjectContext];
    MPlayerItem * playerItem = [self fetchForEntityName:@"PlayerItem" predicate:[NSPredicate predicateWithFormat:@"item = %@ AND player = %@", item, player]];
    if ([playerItem.objectID isTemporaryID]) {
        if (amount < 0) {
            // nothing to do
            return;
        }
        playerItem.item = item;
        playerItem.player = player;
        playerItem.quantity = [NSNumber numberWithInt:0];
        playerItem.game = game;
    }
    
    int oldQty = [playerItem.quantity intValue];
    int newQty = oldQty + amount;
    if ([item.maxQtyInInventory intValue] != -1 && newQty > [item.maxQtyInInventory intValue]) {
        newQty = [item.maxQtyInInventory intValue];
    }
    if (newQty <= 0) {
        // remove item
        
    }
    else {
        playerItem.quantity = [NSNumber numberWithInt:newQty];
        playerItem.sync = [NSNumber numberWithBool:YES];
    }
    
    [self appendLogForPlayer:player game:game type:kLOG_VIEW_ITEM detail1:[NSString stringWithFormat:@"%@",item.itemId]  detail2:nil];
    
    NSError *error;
    if (![context save:&error]) {
        // handle error
        NSLog(@"%@", [error localizedDescription]);
    }
}


- (ServiceResult*)currentOverlaysForPlayer:(MPlayer*)player game:(MGame*)game {
#warning TODO: check conditions
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSArray *overlays = [game.overlays sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
    for (MOverlay *overlay in overlays) {
        NSArray *tiles = [overlay.tiles sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"zoom" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"x" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES]]];
        for (MOverlayTile *tile in tiles) {
            NSDictionary *dictionary = @{@"alpha":@(overlay.alpha), @"file_name":@"", @"file_path":@"", @"media_id":tile.media.mediaId, @"sort_order":@(overlay.sortOrder), @"x":@(tile.x), @"y":@(tile.y), @"zoom":@(tile.zoom)};
            [data addObject:dictionary];
        }
    }
    NSDictionary *result = [NSDictionary dictionaryWithObject:data forKey:@"data"];
    return [[ServiceResult alloc] initWithJSONString:[result JSONRepresentation] andUserData:nil];
}

- (ServiceResult*)mediaForId:(NSNumber*)mediaId {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"mediaId = %@", mediaId];
    NSArray *fetchedMedia = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSDictionary *result;
    if ([fetchedMedia count] > 0) {
        MMedia *media = fetchedMedia[0];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        dictionary[@"media_id"] = media.mediaId;
        if (media.name) {
            dictionary[@"name"] = media.name;
        }
        dictionary[@"file_name"] = media.filePath;
        dictionary[@"file_path"] = media.filePath;
        dictionary[@"type"] = media.type;
        dictionary[@"is_default"] = media.defaultMedia;
        NSString *cacheDirectory =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        dictionary[@"url_path"]  = [[NSURL fileURLWithPath:cacheDirectory isDirectory:YES] absoluteString];
        result = @{@"data":dictionary};
    }
    else {
        result = @{};
    }
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [[ServiceResult alloc] initWithJSONString:jsonString andUserData:nil];
}

- (NSURL*)offlineURLForMediaId:(NSUInteger)mediaId gameId:(NSUInteger)gameId{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"mediaId = %d", mediaId];
    NSError *error;
    NSArray *fetchedMedia = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedMedia count] == 0) {
        return nil;
    }
    MMedia *media = fetchedMedia[0];
    NSString *cacheDirectory =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *filePath = [NSURL fileURLWithPath:[cacheDirectory stringByAppendingPathComponent:media.filePath]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[filePath path]]) {
        return filePath;
    }
    else {
        return nil;
    }
}



@end
