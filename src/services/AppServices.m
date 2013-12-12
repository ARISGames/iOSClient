//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"
#import "NSDictionary+ValidParsers.h"
#import "NpcScriptOption.h"
#import "ARISAlertHandler.h"
#import "ARISMediaView.h"
#import "UploadMan.h"
#import "Player.h"
#import "Overlay.h"
#import "MediaCache.h"

@interface AppServices()
{
    ARISConnection *connection;
    ARISMediaLoader *mediaLoader; 
}

@end

BOOL currentlyFetchingLocationList;
BOOL currentlyFetchingOverlayList;
BOOL currentlyFetchingNoteList;
BOOL currentlyFetchingInventory;
BOOL currentlyFetchingQuestList;
BOOL currentlyFetchingOneGame;
BOOL currentlyFetchingNearbyGamesList;
BOOL currentlyFetchingAnywhereGamesList;
BOOL currentlyFetchingPopularGamesList;
BOOL currentlyFetchingSearchGamesList;
BOOL currentlyFetchingRecentGamesList;
BOOL currentlyUpdatingServerWithPlayerLocation;
BOOL currentlyUpdatingServerWithMapViewed;
BOOL currentlyUpdatingServerWithQuestsViewed;
BOOL currentlyUpdatingServerWithInventoryViewed;

@implementation AppServices

+ (id) sharedAppServices
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
        connection = [[ARISConnection alloc] initWithServer:[[AppModel sharedAppModel].serverURL absoluteString]];
        mediaLoader = [[ARISMediaLoader alloc] init]; 
    }
    return self;
}

- (void) resetCurrentlyFetchingVars
{
    currentlyFetchingNearbyGamesList           = NO;
    currentlyFetchingAnywhereGamesList         = NO;
    currentlyFetchingSearchGamesList           = NO;
    currentlyFetchingPopularGamesList          = NO;
    currentlyFetchingRecentGamesList           = NO;
    currentlyFetchingInventory                 = NO;
    currentlyFetchingLocationList              = NO;
    currentlyFetchingOverlayList               = NO;
    currentlyFetchingQuestList                 = NO;
    currentlyFetchingNoteList = NO; 
    currentlyUpdatingServerWithInventoryViewed = NO;
    currentlyUpdatingServerWithMapViewed       = NO;
    currentlyUpdatingServerWithPlayerLocation  = NO;
    currentlyUpdatingServerWithQuestsViewed    = NO;
}

#pragma mark Communication with Server
- (void) loginUserName:(NSString *)username password:(NSString *)password userInfo:(NSMutableDictionary *)dict
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          username,@"username",
                          password,@"password", 
                          nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"getLoginPlayerObject" arguments:args handler:self successSelector:@selector(parseLoginResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:dict];
}

- (void) parseLoginResponseFromJSON:(ServiceResult *)result
{
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [responseDict setObject:result forKey:@"result"];
    NSLog(@"NSNotification: LoginResponseReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LoginResponseReady" object:nil userInfo:responseDict]];
}

- (void) registerNewUser:(NSString*)userName password:(NSString*)pass firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             userName,  @"username",
                             pass,      @"password",
                             firstName, @"firstname",
                             lastName,  @"lastname",
                             email,     @"email",
                             nil]; 
    [AppModel sharedAppModel].player.username = userName;
    [connection performAsynchronousRequestWithService:@"players" method:@"createPlayer" arguments:args handler:self successSelector:@selector(parseSelfRegistrationResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) parseSelfRegistrationResponseFromJSON:(ServiceResult *)result
{
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [responseDict setObject:result forKey:@"result"];
    NSLog(@"NSNotification: RegistrationResponseReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RegistrationResponseReady" object:nil userInfo:responseDict]];
}

- (void) createUserAndLoginWithGroup:(NSString *)groupName
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             groupName,@"groupName",
                             nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"createPlayerAndGetLoginPlayerObject" arguments:args handler:self successSelector:@selector(parseLoginResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setValue:@"PHOTO" forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"object", @"key",
                          nil];
    
    [connection performAsynchronousRequestWithService:@"?" method:@"?" arguments:args handler:self successSelector:@selector(playerPicUploadDidFinish:) failSelector:@selector(playerPicUploadDidFail:) userInfo:userInfo];
}

- (void) updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid
{
    if(playerId != 0)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",playerId], @"playerId",
                                 name,                                       @"name",
                                 [NSString stringWithFormat:@"%d",mid],      @"mediaId", 
                                 nil]; 
        [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerNameMedia" arguments:args handler:self successSelector:@selector(updatedPlayer:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
    else
        NSLog(@"Tried updating non-existent player! (playerId = 0)");
}

- (void) resetAndEmailNewPassword:(NSString *)email
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             email,@"email",
                             nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"resetAndEmailNewPassword" arguments:args handler:self successSelector:@selector(parseResetAndEmailNewPassword:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) setShowPlayerOnMap
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId], @"playerId",
                             [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].showPlayerOnMap], @"showPlayerOnMap",
                             nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"setShowPlayerOnMap" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchNearbyGameListWithDistanceFilter:(int)distanceInMeters
{
    if(currentlyFetchingNearbyGamesList)
    {
        NSLog(@"Skipping Request: already fetching nearby games");
        return;
    }
    
    currentlyFetchingNearbyGamesList = YES;
    
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
                     [NSString stringWithFormat:@"%d",distanceInMeters],                                              @"distance",
                     [NSString stringWithFormat:@"%d",YES],                                                           @"question",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],              @"showGamesInDevel",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getGamesForPlayerAtLocation" arguments:args handler:self successSelector:@selector(parseNearbyGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchAnywhereGameList
{
    if(currentlyFetchingAnywhereGamesList)
    {
        NSLog(@"Skipping Request: already fetching nearby games");
        return;
    }
    
    currentlyFetchingAnywhereGamesList = YES;
    
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
                     [NSString stringWithFormat:@"%d",0],                                                             @"distanceInMeters",
                     [NSString stringWithFormat:@"%d",NO],                                                            @"question",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],              @"showGamesInDevel",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getGamesForPlayerAtLocation" arguments:args handler:self successSelector:@selector(parseAnywhereGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchRecentGameListForPlayer
{
    if(currentlyFetchingRecentGamesList)
    {
        NSLog(@"Skipping Request: already fetching recent games");
        return;
    }
    
    currentlyFetchingRecentGamesList = YES;
    
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"longitude",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],               @"showGamesInDevel",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getRecentGamesForPlayer" arguments:args handler:self successSelector:@selector(parseRecentGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchPopularGameListForTime:(int)time
{
    if(currentlyFetchingPopularGamesList)
    {
        NSLog(@"Skipping Request: already fetching popular games");
        return;
    }
    
    currentlyFetchingPopularGamesList = YES;
    
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],       @"playerId",
                     [NSString stringWithFormat:@"%d",time],                                            @"time",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],@"showGamesInDevel",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getPopularGames" arguments:args handler:self successSelector:@selector(parsePopularGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchGameListBySearch:(NSString *)searchText onPage:(int)page
{
    if(currentlyFetchingSearchGamesList)
    {
        NSLog(@"Skipping Request: already fetching search games");
        return;
    }
    
    currentlyFetchingSearchGamesList = YES;
    
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"longitude",
                     searchText,                                                                                       @"searchText",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],               @"showGamesInDevel",
                     [NSString stringWithFormat:@"%d", page],                                                          @"page",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getGamesContainingText" arguments:args handler:self successSelector:@selector(parseSearchGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerLocationViewed:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"locationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"locationViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerNodeViewed:(int)nodeId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
                     [NSString stringWithFormat:@"%d",nodeId],                                      @"nodeId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"locationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"nodeViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerWebPageViewed:(int)webPageId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
                     [NSString stringWithFormat:@"%d",webPageId],                                   @"webPageId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"locationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"webPageViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerPanoramicViewed:(int)panoramicId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",panoramicId],                                  @"panoramicId",
                     [NSString stringWithFormat:@"%d",locationId],                                   @"locationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"augBubbleViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerItemViewed:(int)itemId fromLocation:(int)locationId
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
        [NSString stringWithFormat:@"%d",itemId],                                       @"itemId",
        [NSString stringWithFormat:@"%d",locationId],                                   @"locationId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"itemViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerNpcViewed:(int)npcId fromLocation:(int)locationId
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
        [NSString stringWithFormat:@"%d",npcId],                                       @"npcId",
        [NSString stringWithFormat:@"%d",locationId],                                  @"locationId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"npcViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerGameSelected
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerLastGame" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerMapViewed
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"mapViewed" arguments:args handler:self successSelector:@selector(fetchPlayerLocationList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerQuestsViewed
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"questsViewed" arguments:args handler:self successSelector:@selector(fetchPlayerQuestList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerInventoryViewed
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"inventoryViewed" arguments:args handler:self successSelector:@selector(fetchPlayerInventory) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) parseResetAndEmailNewPassword:(ServiceResult *)jsonResult
{
    if(jsonResult == nil)
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ForgotPasswordTitleKey", nil) message:NSLocalizedString(@"ForgotPasswordMessageKey", nil)];
    else
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"ForgotEmailSentTitleKey", @"") message:NSLocalizedString(@"ForgotMessageKey", @"")];
}

- (void) startOverGame:(int)gameId
{
    [[AppModel sharedAppModel] resetAllGameLists];
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d", gameId],                                   @"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"playerId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"startOverGameForPlayer" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"itemId",
                     [NSString stringWithFormat:@"%d",locationId],                                   @"locationId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"pickupItemFromLocation" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)updateServerDropItemHere:(int)itemId qty:(int)qty
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                   @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"playerId",
                     [NSString stringWithFormat:@"%d",itemId],                                                         @"itemId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"longitude",
                     [NSString stringWithFormat:@"%d",qty],                                                            @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"dropItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
                     [NSString stringWithFormat:@"%d",noteId],                                      @"noteId",
                     [NSString stringWithFormat:@"%f",coordinate.latitude],                         @"latitude",
                     [NSString stringWithFormat:@"%f",coordinate.longitude],                        @"longitude",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"dropNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerDestroyItem:(int)itemId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"itemId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"destroyItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerInventoryItem:(int)itemId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"temId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"setItemCountForPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerAddInventoryItem:(int)itemId addQty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"itemId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"giveItemToPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"itemId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"qty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"takeItemFromPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",noteId], @"noteId",
                     title,                                    @"title",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateComment" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) likeNote:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"playerId",
                     [NSString stringWithFormat:@"%d",noteId],                                    @"noteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"likeNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) unLikeNote:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"playerId",
                     [NSString stringWithFormat:@"%d",noteId],                                    @"noteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"unlikeNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (int) addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",noteId],                                       @"noteId",
                     title,                                                                          @"title",
                     nil];
    ServiceResult *result = [connection performSynchronousRequestWithService:@"notes" method:@"addCommentToNote" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (void) setNoteCompleteForNoteId:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",noteId], @"noteId",
            nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"setNoteComplete" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (int) createNote
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
                     nil];
    ServiceResult *result =[connection performSynchronousRequestWithService:@"notes" method:@"createNewNote" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (int) createNoteStartIncomplete
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
                     nil];
    ServiceResult *result = [connection performSynchronousRequestWithService:@"notes" method:@"createNewNoteStartIncomplete" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (void) contentAddedToNoteWithText:(ServiceResult *)result
{
    if([result.userInfo validObjectForKey:@"noteId"])
        [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:[result.userInfo validIntForKey:@"noteId"]
                                                              andFileURL:[result.userInfo validObjectForKey:@"localURL"]];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
    [[AppModel sharedAppModel].currentGame.notesModel clearData];
}

- (void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",noteId],                                      @"noteId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
                     [NSString stringWithFormat:@"%d",mediaId],                                     @"mediaId",
                     type,                                                                          @"type",
                     text,                                                                          @"text",
                     nil];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:noteId], @"noteId", fileURL, @"localURL", nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"addContentToNote" arguments:args handler:self successSelector:@selector(contentAddedToNoteWithText:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:userInfo];
}

- (void) deleteNoteContentWithContentId:(int)contentId
{
    if(contentId != -1)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%d",contentId], @"contentId",
                        nil];
        [connection performAsynchronousRequestWithService:@"notes" method:@"deleteNoteContent" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
}

- (void) deleteNoteLocationWithNoteId:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     @"PlayerNote",                                                                  @"locationType",
                     [NSString stringWithFormat:@"%d",noteId],                                       @"noteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"locations" method:@"deleteLocationsForObject" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) deleteNoteWithNoteId:(int)noteId
{
    if(noteId != 0)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%d",noteId], @"noteId",
                         nil];
        [connection performAsynchronousRequestWithService:@"notes" method:@"deleteNote" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
}

- (void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int) noteId type: (NSString *)type
{
    NSNumber *nId = [[NSNumber alloc] initWithInt:noteId]; 
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:4];
    [userInfo setValue:name forKey:@"title"];
    [userInfo setValue:nId forKey:@"noteId"];
    [userInfo setValue:type forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"object", @"key", 
                          nil]; 
    [connection performAsynchronousRequestWithService:@"?" method:@"?" arguments:args handler:self successSelector:@selector(noteContentUploadDidFinish:) failSelector:@selector(uploadNoteContentDidFail:) userInfo:userInfo]; 
}

- (void) noteContentUploadDidFinish:(ServiceResult*)result
{
    int noteId      = [result.userInfo validIntForKey:@"noteId"];
    NSString *title = [result.userInfo validObjectForKey:@"title"];
    NSString *type  = [result.userInfo validObjectForKey:@"type"];
    NSURL *localUrl = [result.userInfo validObjectForKey:@"url"];
    NSString *newFileName = (NSString *)result.data;
    
    //TODO: Check that the response string is actually a new filename that was made on the server, not an error
    
    NoteContent *newContent = [[NoteContent alloc] init];
    newContent.noteId = noteId;
    newContent.title = @"Refreshing From Server...";
    newContent.type = type;
    newContent.contentId = 0;
    
    [[[[AppModel sharedAppModel].currentGame.notesModel noteForId:[NSNumber numberWithInt:noteId]] contents] addObject:newContent];
    [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:noteId andFileURL:localUrl];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
    
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",noteId],                                       @"noteId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     newFileName,                                                                    @"fileName",
                     type,                                                                           @"type",
                     title,                                                                          @"title",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"addContentToNoteFromFileName" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    [self fetchAllPlayerLists];
}

- (void) uploadNoteContentDidFail:(ServiceResult *)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
    
    [alert show];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:5];
    nId = [result.userInfo validObjectForKey:@"noteId"];
    //if(description == NULL) description = @"filename";
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
}

- (void) playerPicUploadDidFinish:(ServiceResult*)result
{        
    NSString *newFileName = (NSString *)result.data;
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"playerId",
            newFileName,                                                                 @"fileName",
            nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"addPlayerPicFromFilename" arguments:args handler:self successSelector:@selector(parseNewPlayerMediaResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    
    [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:-1 andFileURL:[result.userInfo validObjectForKey:@"url"]];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
}

- (void) updatedPlayer:(ServiceResult *)result
{
    //immediately load new image into cache
    if([AppModel sharedAppModel].player.playerMediaId != 0)
        [self loadMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:@"PHOTO"] delegate:nil]; 
}

- (void) parseNewPlayerMediaResponseFromJSON:(ServiceResult *)jsonResult
{	   
    if(jsonResult.data && [((NSDictionary *)jsonResult.data) validIntForKey:@"media_id"])
    {
        [AppModel sharedAppModel].player.playerMediaId = [((NSDictionary*)jsonResult.data) validIntForKey:@"media_id"];
        //immediately load new image into cache 
        if([AppModel sharedAppModel].player.playerMediaId != 0)
            [self loadMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:@"PHOTO"] delegate:nil];  
        [[AppModel sharedAppModel] saveUserDefaults];
    }
}

- (void) playerPicUploadDidFail:(ServiceResult *)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadFailedKey", @"") message:NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
    
    [alert show];
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
}

- (void) updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList
{	
    
      NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
             [NSString stringWithFormat:@"%d",noteId],      @"noteId",
             title,                                         @"title",
             [NSString stringWithFormat:@"%d",publicToMap], @"publicToMap",
             [NSString stringWithFormat:@"%d",publicToList],@"publicToList",
             nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateNoteContent:(int)contentId title:(NSString *)text;
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",contentId],@"contentId",
            text,                                       @"text",
            nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateContentTitle" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)updateNoteContent:(int)contentId text:(NSString *)text
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",contentId],@"contentId",
        text,                                       @"text",
        nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateContent" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)updateServerWithPlayerLocation
{
    if(![AppModel sharedAppModel].player)
    {
        NSLog(@"Skipping Request: player not logged in");
        return;
    }
    
    if(currentlyUpdatingServerWithPlayerLocation)
    {
        NSLog(@"Skipping Request: already updating player location");
        return;
    }
    
    currentlyUpdatingServerWithPlayerLocation = YES;
    
    //Update the server with the new Player Location
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"gameId",
            [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
            [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
            nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerLocation" arguments:args handler:self successSelector:@selector(parseUpdateServerWithPlayerLocationFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

#pragma mark ASync Fetch selectors

- (void) fetchAllGameLists
{
    [self fetchTabBarItems];
    [self fetchGameMediaList];
    [self fetchGameItemList];
    [self fetchGameNpcList];
    [self fetchGameNodeList];
    [self fetchGamePanoramicList];
    [self fetchGameWebPageList];
    [self fetchGameOverlayList];
}

- (void) fetchGameOverlayList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
            nil];
    
    [connection performAsynchronousRequestWithService:@"overlays" method:@"getCurrentOverlaysForPlayer" arguments:args handler:self successSelector:@selector(parseOverlayListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) parseOverlayListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingOverlayList) return;
    currentlyFetchingOverlayList = NO;
    
    NSLog(@"NSNotification: ReceivedOverlayList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedOverlayList" object:nil]];
    
    [AppModel sharedAppModel].overlayIsVisible = false;
    
    NSArray *overlayListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempOverlayList = [[NSMutableArray alloc] init];
    Overlay *tempOverlay = [[Overlay alloc] init];
    
    NSEnumerator *overlayListEnumerator = [overlayListArray objectEnumerator];
    NSDictionary *overlayDictionary;
    // step through results and create overlays
    int currentOverlayID = -1;
    int overlaysIndex = 0;
    while(overlayDictionary = [overlayListEnumerator nextObject])
    {
        // if new overlay in database
        if(currentOverlayID != [overlayDictionary validIntForKey:@"overlay_id"])
        {
            // add previous overlay to overlay list
            [tempOverlayList addObject:tempOverlay];
            
            // create new overlay
            tempOverlay.index = overlaysIndex;
            tempOverlay.overlayId = [overlayDictionary validIntForKey:@"overlay_id"];;
            tempOverlay.num_tiles = [overlayDictionary validIntForKey:@"num_tiles"];;
            //tempOverlay.alpha = [[overlayDictionary validObjectForKey:@"alpha"] floatValue] ;
            tempOverlay.alpha = 1.0;
            [tempOverlay.tileFileName addObject:[overlayDictionary validObjectForKey:@"file_path"]];
            [tempOverlay.tileMediaID addObject:[overlayDictionary validObjectForKey:@"media_id"]];
            [tempOverlay.tileX addObject:[overlayDictionary validObjectForKey:@"x"]];
            [tempOverlay.tileY addObject:[overlayDictionary validObjectForKey:@"y"]];
            [tempOverlay.tileZ addObject:[overlayDictionary validObjectForKey:@"zoom"]];
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[overlayDictionary validIntForKey:@"media_id"] ofType:@"PHOTO"];
            [tempOverlay.tileImage addObject:media];
            currentOverlayID = tempOverlay.overlayId;
            overlaysIndex += 1;
        }
        else
        {
            // add tiles to existing overlay
            [tempOverlay.tileFileName addObject:[overlayDictionary validObjectForKey:@"file_path"]];
            [tempOverlay.tileMediaID addObject:[overlayDictionary validObjectForKey:@"media_id"]];
            [tempOverlay.tileX addObject:[overlayDictionary validObjectForKey:@"x"]];
            [tempOverlay.tileY addObject:[overlayDictionary validObjectForKey:@"y"]];
            [tempOverlay.tileZ addObject:[overlayDictionary validObjectForKey:@"zoom"]];
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[overlayDictionary validIntForKey:@"media_id"] ofType:@"PHOTO"];
            [tempOverlay.tileImage addObject:media];
            currentOverlayID = tempOverlay.overlayId;
        }
    }
    
    [AppModel sharedAppModel].overlayList = tempOverlayList;
    
    for (int iOverlay=0; iOverlay < [[AppModel sharedAppModel].overlayList count]; iOverlay++)
    {
        Overlay *currentOverlay = [[AppModel sharedAppModel].overlayList objectAtIndex:iOverlay];
        int iTiles = [currentOverlay.tileX count];
        for (int iTile = 0; iTile < iTiles; iTile++)
        {
            //SHOULD NOT MANIPULATE VIEWS IN APPSERVICES!!! -Phil
            //ARISMediaView *aImageView = [[ARISMediaView alloc] initWithFrame:CGRectZero media:[currentOverlay.tileImage objectAtIndex:iTile] mode:ARISMediaDisplayModeAspectFit delegate:nil];
            //also... what the heck is this doing? -Phil
        }
    }
    
    NSError *error;
    if(![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    NSLog(@"NSNotification: NewOverlayListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewOverlayListReady" object:nil]];
    NSLog(@"NSNotification: PlayerPieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerPieceReceived" object:nil]];
}

- (void)fetchAllPlayerLists
{
    [self fetchPlayerLocationList];
    [self fetchPlayerQuestList];
    [self fetchPlayerInventory];
    [self fetchPlayerOverlayList];
}

- (void)fetchTabBarItems
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
            nil];
    
    [connection performAsynchronousRequestWithService:@"games" method:@"getTabBarItemsForGame" arguments:args handler:self successSelector:@selector(parseGameTabListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchQRCode:(NSString*)code
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
        [NSString stringWithFormat:@"%@",code],                                        @"code",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
        nil];
    [connection performAsynchronousRequestWithService:@"qrcodes" method:@"getQRCodeNearbyObjectForPlayer" arguments:args handler:self successSelector:@selector(parseQRCodeObjectFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
            [NSString stringWithFormat:@"%d",npcId],                                        @"npcId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
            [NSString stringWithFormat:@"%d",nodeId],                                       @"nodeId",
            nil];
    [connection performAsynchronousRequestWithService:@"npcs" method:@"getNpcConversationsForPlayerAfterViewingNode" arguments:args handler:self successSelector:@selector(parseConversationOptionsFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNpcList
{
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                     nil];
    
    [connection performAsynchronousRequestWithService:@"npcs" method:@"getNpcs" arguments:args handler:self successSelector:@selector(parseGameNpcListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchNoteListPage:(int)page
{
    if(currentlyFetchingNoteList)
    {
        NSLog(@"Skipping Request: already fetching player notes");
        return;
    }
    currentlyFetchingNoteList = YES;
    
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                     [NSString stringWithFormat:@"%d",page],                                         @"page",
                     [NSString stringWithFormat:@"%d", 20],                                          @"qty",
                     nil];
    
    [connection performAsynchronousRequestWithService:@"notebook" method:@"getStubNotesVisibleToPlayer" arguments:args handler:self successSelector:@selector(parseNoteListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchNoteWithId:(int)noteId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d",noteId],
                    nil];
    [connection performAsynchronousRequestWithService:@"notebook" method:@"getNote" arguments:args handler:self successSelector:@selector(parseNoteFromJSON:) failSelector:nil userInfo:nil]; 
}

- (void) fetchGameWebPageList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
        nil];
    
    [connection performAsynchronousRequestWithService:@"webpages" method:@"getWebPages" arguments:args handler:self successSelector:@selector(parseGameWebPageListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchMediaMeta:(Media *)m
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
         (([AppModel sharedAppModel].currentGame.gameId != 0) ? [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId] : @"player"), @"path",
         [NSString stringWithFormat:@"%d",[m.uid intValue]],                                                                                                 @"mediaId",
         nil];
    
    [connection performAsynchronousRequestWithService:@"media" method:@"getMediaObject" arguments:args handler:self successSelector:@selector(parseSingleMediaFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) loadMedia:(Media *)m delegate:(id<ARISMediaLoaderDelegate>)d
{
    [mediaLoader loadMedia:m delegate:d];
}

- (void)fetchGameMediaList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
            nil];
    [connection performAsynchronousRequestWithService:@"media" method:@"getMedia" arguments:args handler:self successSelector:@selector(parseGameMediaListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGamePanoramicList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
        nil];
    [connection performAsynchronousRequestWithService:@"augbubbles" method:@"getAugBubbles" arguments:args handler:self successSelector:@selector(parseGamePanoramicListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameItemList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
            nil];
    [connection performAsynchronousRequestWithService:@"items" method:@"getFullItems" arguments:args handler:self successSelector:@selector(parseGameItemListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNodeList
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                                 nil];
    [connection performAsynchronousRequestWithService:@"nodes" method:@"getNodes" arguments:args handler:self successSelector:@selector(parseGameNodeListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNoteTags
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
                                 nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"getAllTagsInGame" arguments:args handler:self successSelector:@selector(parseGameTagsListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)parseGameTagsListFromJSON:(ServiceResult *)jsonResult
{    
    NSArray *gameTagsArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempTagsList = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSEnumerator *gameTagEnumerator = [gameTagsArray objectEnumerator];
    NSDictionary *tagDictionary;
    while ((tagDictionary = [gameTagEnumerator nextObject]))
    {
        Tag *t = [[Tag alloc]init];
        t.tagName = [tagDictionary validObjectForKey:@"tag"];
        t.playerCreated = [tagDictionary validBoolForKey:@"player_created"];
        t.tagId = [tagDictionary validIntForKey:@"tag_id"];
        [tempTagsList addObject:t];
    }
    [AppModel sharedAppModel].gameTagList = tempTagsList;
}

- (void) addTagToNote:(int)noteId tagName:(NSString *)tag
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",noteId],                                       @"noteId", 
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                                 tag,                                                                            @"tag",
                                 nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"addTagToNote" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) deleteTagFromNote:(int)noteId tagId:(int)tagId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d",noteId], @"noteId",
                          [NSString stringWithFormat:@"%d",tagId],  @"tagId",
                          nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"deleteTagFromNote" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchPlayerLocationList
{
    if(currentlyFetchingLocationList)
    {
        NSLog(@"Skipping Request: already fetching locations");
        return;
    }
    
    currentlyFetchingLocationList = YES;
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId], @"gameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],     @"playerId",
        nil];
    [connection performAsynchronousRequestWithService:@"locations" method:@"getLocationsForPlayer" arguments:args handler:self successSelector:@selector(parseLocationListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchPlayerOverlayList
{
    if(currentlyFetchingOverlayList)
    {
        NSLog(@"Skipping Request: already fetching overlays or interacting with object");
        return;
    }
    
    currentlyFetchingOverlayList = YES;
    
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                                    nil];
    [connection performAsynchronousRequestWithService:@"overlays" method:@"getCurrentOverlaysForPlayer" arguments:args handler:self successSelector:@selector(parseOverlayListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchPlayerInventory
{    
    if(currentlyFetchingInventory)
    {
        NSLog(@"Skipping Request: already fetching inventory");
        return;
    }
    
    currentlyFetchingInventory = YES;
    
      NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
             [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"gameId",
             [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"playerId",
             nil];
    
    [connection performAsynchronousRequestWithService:@"items" method:@"getItemsForPlayer" arguments:args handler:self successSelector:@selector(parseInventoryFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchPlayerQuestList
{
    if(currentlyFetchingQuestList)
    {
        NSLog(@"Skipping Request: already fetching quests");
        return;
    }
    
    currentlyFetchingQuestList = YES;
    
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"gameId",
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"playerId",
                                    nil];
    [connection performAsynchronousRequestWithService:@"quests" method:@"getQuestsForPlayer" arguments:args handler:self successSelector:@selector(parseQuestListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchOneGameGameList:(int)gameId
{
    if(currentlyFetchingOneGame)
    {
        NSLog(@"Skipping Request: already fetching one game");
        return;
    }
    
    currentlyFetchingOneGame = YES;
    
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",gameId],                                                        @"gameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"playerId",
                     [NSString stringWithFormat:@"%d",1],                                                             @"question",
                     [NSString stringWithFormat:@"%d",999999999],                                                     @"question",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"latitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"longitude",
                     [NSString stringWithFormat:@"%d",1],                                                             @"showGamesInDev",// = 1, because if you're specifically seeking out one game, who cares
                     nil];
    
    [connection performAsynchronousRequestWithService:@"games" method:@"getOneGame" arguments:args handler:self successSelector:@selector(parseOneGameGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (Tab *) parseTabFromDictionary:(NSDictionary *)tabDictionary
{
    Tab *tab = [[Tab alloc] init];
    tab.tabIndex   = [tabDictionary validIntForKey:@"tab_index"];
    tab.tabName    = [tabDictionary validObjectForKey:@"tab"];
    tab.tabDetail1 = [tabDictionary validObjectForKey:@"tab_detail_1"] ? [tabDictionary validIntForKey:@"tab_detail_1"] : 0;
    return tab;
}

- (void) parseNoteListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingNoteList) return;
    currentlyFetchingNoteList = NO;
    
    NSArray *noteListArray = (NSArray *)jsonResult.data;
    NSMutableArray *tempNoteList = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
    NSDictionary *dict;
    while((dict = [enumerator nextObject]))
        [tempNoteList addObject:[[Note alloc] initWithDictionary:dict]];
    
    NSLog(@"NSNotification: LatestNoteListReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestNoteListReceived" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:tempNoteList, @"notes", nil]]]; 
}

- (void) parseNoteFromJSON:(ServiceResult *)jsonResult
{
    Note *note = [[Note alloc] initWithDictionary:(NSDictionary *)jsonResult.data];
    
    NSLog(@"NSNotification: NoteDataReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NoteDataReceived" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:note, @"note", nil]]]; 
}

- (void) parseConversationOptionsFromJSON:(ServiceResult *)jsonResult
{
    NSArray *conversationOptionsArray = (NSArray *)jsonResult.data;
    NSMutableArray *conversationOptions = [[NSMutableArray alloc] initWithCapacity:3];
    NSEnumerator *conversationOptionsEnumerator = [conversationOptionsArray objectEnumerator];
    NSDictionary *conversationDictionary;
    
    while((conversationDictionary = [conversationOptionsEnumerator nextObject]))
    {
        int nodeId = [conversationDictionary validIntForKey:@"node_id"];
        NSString *text = [conversationDictionary validObjectForKey:@"text"];
        BOOL hasViewed = [conversationDictionary validBoolForKey:@"has_viewed"];
        NpcScriptOption *option = [[NpcScriptOption alloc] initWithOptionText:text scriptText:@"" nodeId:nodeId hasViewed:hasViewed];
        [conversationOptions addObject:option];
    }
    
    NSLog(@"NSNotification: ConversationOptionsReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConversationOptionsReady" object:conversationOptions]];
}

- (Game *)parseGame:(NSDictionary *)gameSource
{
    Game *game = [[Game alloc] init];
    
    game.gameId                   = [gameSource validIntForKey:@"game_id"];
    game.hasBeenPlayed            = [gameSource validBoolForKey:@"has_been_played"];
    game.isLocational             = [gameSource validBoolForKey:@"is_locational"];
    game.showPlayerLocation       = [gameSource validBoolForKey:@"show_player_location"];
    game.inventoryModel.weightCap = [gameSource validIntForKey:@"inventory_weight_cap"];
    game.rating                   = [gameSource validIntForKey:@"rating"];
    game.pcMediaId                = [gameSource validIntForKey:@"pc_media_id"];
    game.numPlayers               = [gameSource validIntForKey:@"numPlayers"];
    game.playerCount              = [gameSource validIntForKey:@"count"];
    game.gdescription             = [gameSource validStringForKey:@"description"];
    game.name                     = [gameSource validStringForKey:@"name"];
    game.authors                  = [gameSource validStringForKey:@"editors"];
    game.mapType                  = [gameSource validObjectForKey:@"map_type"];
    game.latitude                 = [gameSource validDoubleForKey:@"latitude"]; 
    game.longitude                = [gameSource validDoubleForKey:@"longitude"]; 
    game.zoomLevel                = [gameSource validDoubleForKey:@"zoom_level"]; 
    if(!game.mapType || (![game.mapType isEqualToString:@"STREET"] && ![game.mapType isEqualToString:@"SATELLITE"] && ![game.mapType isEqualToString:@"HYBRID"])) game.mapType = @"STREET";
    
    NSString *distance = [gameSource validObjectForKey:@"distance"];
    if(distance) game.distanceFromPlayer = [distance doubleValue];
    else game.distanceFromPlayer = 999999999;
    
    NSString *latitude  = [gameSource validObjectForKey:@"latitude"];
    NSString *longitude = [gameSource validObjectForKey:@"longitude"];
    if(latitude && longitude)
        game.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    else
        game.location = [[CLLocation alloc] init];
    
    int iconMediaId;
    if((iconMediaId = [gameSource validIntForKey:@"icon_media_id"]) > 0)
    {
        game.iconMedia = [[AppModel sharedAppModel] mediaForMediaId:iconMediaId ofType:@"PHOTO"];
        game.iconMedia.type = @"PHOTO"; //Phil doesn't like this...
    }
    
    
    int mediaId;
    if((mediaId = [gameSource validIntForKey:@"media_id"]) > 0)
    {
        game.splashMedia = [[AppModel sharedAppModel] mediaForMediaId:mediaId ofType:@"PHOTO"];
        game.splashMedia.type = @"PHOTO"; //Phil doesn't like this...
    }
    
    game.questsModel.totalQuestsInGame = [gameSource validIntForKey:@"totalQuests"];
    game.launchNodeId                  = [gameSource validIntForKey:@"on_launch_node_id"];
    game.completeNodeId                = [gameSource validIntForKey:@"game_complete_node_id"];
    game.calculatedScore               = [gameSource validIntForKey:@"calculatedScore"];
    game.numReviews                    = [gameSource validIntForKey:@"numComments"];
    game.allowsPlayerTags              = [gameSource validBoolForKey:@"allow_player_tags"];
    game.allowShareNoteToMap           = [gameSource validBoolForKey:@"allow_share_note_to_map"];
    game.allowShareNoteToList          = [gameSource validBoolForKey:@"allow_share_note_to_book"];
    game.allowNoteComments             = [gameSource validBoolForKey:@"allow_note_comments"];
    game.allowNoteLikes                = [gameSource validBoolForKey:@"allow_note_likes"];
    if([[gameSource validStringForKey:@"note_title_behavior"] isEqualToString:@"NONE"])                 game.noteTitleBehavior = None;
    else if([[gameSource validStringForKey:@"note_title_behavior"] isEqualToString:@"FORCE_OVERWRITE"]) game.noteTitleBehavior = ForceOverwrite;
    
    NSArray *comments = [gameSource validObjectForKey:@"comments"];
    for (NSDictionary *comment in comments)
    {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        Comment *c = [[Comment alloc] init];
        c.text = [comment validObjectForKey:@"text"];
        c.playerName = [comment validObjectForKey:@"username"];
        NSString *cRating = [comment validObjectForKey:@"rating"];
        if(cRating) c.rating = [cRating intValue];
        [game.comments addObject:c];
    }
    
    return game;
}

- (NSMutableArray *)parseGameListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *gameListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
    
    NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];
    NSDictionary *gameDictionary;
    while ((gameDictionary = [gameListEnumerator nextObject]))
        [tempGameList addObject:[self parseGame:(gameDictionary)]];
    
    NSError *error;
    if(![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    return tempGameList;
}

- (void) parseOneGameGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingOneGame) return;
    currentlyFetchingOneGame = NO;
    
    [AppModel sharedAppModel].oneGameGameList = [self parseGameListFromJSON:jsonResult];
    
    Game *game;
    if([[AppModel sharedAppModel].oneGameGameList count] > 0)
    {
        game = (Game *)[[AppModel sharedAppModel].oneGameGameList  objectAtIndex:0];
        NSLog(@"NSNotification: NewOneGameGameListReady");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewOneGameGameListReady" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:game,@"game", nil]]];
    }
    else
    {
        NSLog(@"NSNotification: NewOneGameGameListFailed");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewOneGameGameListFailed" object:nil userInfo:nil]];
    }
}

- (void)parseNearbyGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingNearbyGamesList) return;
    currentlyFetchingNearbyGamesList = NO;
    
    [AppModel sharedAppModel].nearbyGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewNearbyGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNearbyGameListReady" object:nil]];
}

- (void)parseAnywhereGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingAnywhereGamesList) return;
    currentlyFetchingAnywhereGamesList = NO;
    
    [AppModel sharedAppModel].anywhereGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewAnywhereGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewAnywhereGameListReady" object:nil]];
}

- (void)parseSearchGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingSearchGamesList) return;
    currentlyFetchingSearchGamesList = NO;
    
    [AppModel sharedAppModel].searchGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewSearchGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewSearchGameListReady" object:nil]];
}

- (void)parsePopularGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingPopularGamesList) return;
    currentlyFetchingPopularGamesList = NO;
    
    [AppModel sharedAppModel].popularGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewPopularGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewPopularGameListReady" object:nil]];
}

- (void)parseRecentGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingRecentGamesList) return;
    currentlyFetchingRecentGamesList = NO;
    
    NSArray *gameListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
    
    NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];
    NSDictionary *gameDictionary;
    while ((gameDictionary = [gameListEnumerator nextObject]))
        [tempGameList addObject:[self parseGame:(gameDictionary)]];
    
    [AppModel sharedAppModel].recentGameList = tempGameList;
    
    NSError *error;
    if(![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    NSLog(@"NSNotification: NewRecentGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewRecentGameListReady" object:nil]];
}

- (void)saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId], @"playerId",
                                 [NSString stringWithFormat:@"%d", gameId],                                    @"gameId",
                                 [NSString stringWithFormat:@"%d", rating],                                    @"rating",
                                 comment,                                                                      @"comment",
                                 nil];
    [connection performAsynchronousRequestWithService: @"games" method:@"saveComment" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)parseLocationListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingLocationList) return;
    currentlyFetchingLocationList = NO;
    
    NSLog(@"NSNotification: ReceivedLocationList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedLocationList" object:nil]];
    
    NSArray *locationsArray = (NSArray *)jsonResult.data;
    
    //Build the location list
    NSMutableArray *tempLocationsList = [[NSMutableArray alloc] init];
    NSEnumerator *locationsEnumerator = [locationsArray objectEnumerator];
    NSDictionary *locationDictionary;
    while ((locationDictionary = [locationsEnumerator nextObject]))
        [tempLocationsList addObject:[[Location alloc] initWithDictionary:locationDictionary]];
    
    //Tell everyone
    NSDictionary *locations  = [[NSDictionary alloc] initWithObjectsAndKeys:tempLocationsList,@"locations", nil];
    NSLog(@"NSNotification: LatestPlayerLocationsReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerLocationsReceived" object:nil userInfo:locations]];
    NSLog(@"NSNotification: PlayerPieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerPieceReceived" object:nil]];
}

- (void)parseSingleMediaFromJSON:(ServiceResult *)jsonResult
{
    //Just convert the data into an array and pretend it is a full game list, so same thing as 'parseGameMediaListFromJSON'
    NSArray * data = [[NSArray alloc] initWithObjects:jsonResult.data, nil];
    jsonResult.data = data;
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread
}

- (void)parseGameMediaListFromJSON:(ServiceResult *)jsonResult
{
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread
}

- (void)startCachingMedia:(ServiceResult *)jsonResult
{
    NSArray *serverMediaArray = (NSArray *)jsonResult.data;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(gameid = 0) OR (gameid = %d)", [AppModel sharedAppModel].currentGame.gameId];
    NSArray *currentlyCachedMediaArray = [[AppModel sharedAppModel].mediaCache mediaForPredicate:predicate];
    NSLog(@"%d total media for %d",[currentlyCachedMediaArray count], [AppModel sharedAppModel].currentGame.gameId);
    
    //Construct cached media map (dictionary with identical key/values of mediaId) to quickly check for existence of media
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc] initWithCapacity:currentlyCachedMediaArray.count];
    for(int i = 0; i < [currentlyCachedMediaArray count]; i++)
    {
        if([[currentlyCachedMediaArray objectAtIndex:i] uid])
            [currentlyCachedMediaMap setObject:[currentlyCachedMediaArray objectAtIndex:i] forKey:[[currentlyCachedMediaArray objectAtIndex:i] uid]];
        else
            NSLog(@"found broken coredata entry");
    }
    
    Media *tmpMedia;
    for(int i = 0; i < [serverMediaArray count]; i++)
    {
        NSDictionary *serverMediaDict = [serverMediaArray objectAtIndex:i];
        int mediaId        = [serverMediaDict validIntForKey:@"media_id"];
        NSString *fileName = [serverMediaDict validObjectForKey:@"file_path"];
        
        if(!(tmpMedia = [currentlyCachedMediaMap objectForKey:[NSNumber numberWithInt:mediaId]]))
            tmpMedia = [[AppModel sharedAppModel].mediaCache addMediaToCache:mediaId];
        
        if(tmpMedia && (tmpMedia.url == nil || tmpMedia.type == nil || tmpMedia.gameid == nil))
        {
            tmpMedia.url = [NSString stringWithFormat:@"%@%@", [serverMediaDict validObjectForKey:@"url_path"], fileName];
            if([[serverMediaDict validStringForKey:@"type"] isEqualToString:@"Image"] || [[serverMediaDict validStringForKey:@"type"] isEqualToString:@"Icon"])
                tmpMedia.type = @"PHOTO";
            else if([[serverMediaDict validStringForKey:@"type"] isEqualToString:@"Audio"])
                tmpMedia.type = @"AUDIO";
            else if([[serverMediaDict validStringForKey:@"type"] isEqualToString:@"Video"])
                tmpMedia.type = @"VIDEO";
            tmpMedia.gameid = [NSNumber numberWithInt:[serverMediaDict validIntForKey:@"game_id"]];
            NSLog(@"Cached Media: %d with URL: %@",mediaId,tmpMedia.url);
        }
    }
    NSError *error;
    if(![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    NSLog(@"NSNotification: ReceivedMediaList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedMediaList" object:nil]];
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGameItemListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *itemListArray = (NSArray *)jsonResult.data;
    
    NSMutableDictionary *tempItemList = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumerator = [itemListArray objectEnumerator];
    
    NSDictionary *dict;
    while((dict = [enumerator nextObject]))
    {
        Item *tmpItem = [[Item alloc] initWithDictionary:dict];
        [tempItemList setObject:tmpItem forKey:[NSNumber numberWithInt:tmpItem.itemId]];
    }
    
    [AppModel sharedAppModel].gameItemList = tempItemList;
    
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGameNodeListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *nodeListArray = (NSArray *)jsonResult.data;
    NSMutableDictionary *tempNodeList = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumerator = [nodeListArray objectEnumerator];
    NSDictionary *dict;
    while ((dict = [enumerator nextObject]))
    {
        Node *tmpNode = [[Node alloc] initWithDictionary:dict];
        [tempNodeList setObject:tmpNode forKey:[NSNumber numberWithInt:tmpNode.nodeId]];
    }
    
    [AppModel sharedAppModel].gameNodeList = tempNodeList;
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void)parseGameTabListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *tabListArray = (NSArray *)jsonResult.data;
    NSMutableArray *tempTabList = [[NSMutableArray alloc] initWithCapacity:10];
    for(int i = 0; i < [tabListArray count]; i++)
        [tempTabList addObject:[self parseTabFromDictionary:[tabListArray objectAtIndex:i]]];
    
    //PHIL HATES THIS
    NSLog(@"NSNotification: ReceivedTabList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedTabList" object:nil userInfo:[[NSDictionary alloc] initWithObjects:[[NSArray alloc] initWithObjects:tempTabList,nil] forKeys:[[NSArray alloc] initWithObjects:@"tabs",nil]]]];
    //PHIL DONE HATING
    
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void)parseGameNpcListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *npcListArray = (NSArray *)jsonResult.data;
    
    NSMutableDictionary *tempNpcList = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumerator = [((NSArray *)npcListArray) objectEnumerator];
    NSDictionary *dict;
    while ((dict = [enumerator nextObject]))
    {
        Npc *tmpNpc = [[Npc alloc] initWithDictionary:dict];
        [tempNpcList setObject:tmpNpc forKey:[NSNumber numberWithInt:tmpNpc.npcId]];
    }
    
    [AppModel sharedAppModel].gameNpcList = tempNpcList;
    
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGameWebPageListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *webPageListArray = (NSArray *)jsonResult.data;
    
    NSMutableDictionary *tempWebPageList = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumerator = [((NSArray *)webPageListArray) objectEnumerator];
    NSDictionary *dict;
    while ((dict = [enumerator nextObject]))
    {
        WebPage *tmpWebPage = [[WebPage alloc] initWithDictionary:dict];
        [tempWebPageList setObject:tmpWebPage forKey:[NSNumber numberWithInt:tmpWebPage.webPageId]];
    }
    
    [AppModel sharedAppModel].gameWebPageList = tempWebPageList;
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGamePanoramicListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *panListArray = (NSArray *)jsonResult.data;
    
    NSMutableDictionary *tempPanoramicList = [[NSMutableDictionary alloc] init];
    NSEnumerator *enumerator = [((NSArray *)panListArray) objectEnumerator];
    NSDictionary *dict;
    while ((dict = [enumerator nextObject]))
    {
        Panoramic *tmpPan = [[Panoramic alloc] initWithDictionary:dict];
        [tempPanoramicList setObject:tmpPan forKey:[NSNumber numberWithInt:tmpPan.panoramicId]];
    }
    
    [AppModel sharedAppModel].gamePanoramicList = tempPanoramicList;
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseInventoryFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingInventory) return;
    currentlyFetchingInventory = NO;
    
    NSMutableArray *tempInventory = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *tempAttributes = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray *inventoryArray = (NSArray *)jsonResult.data;
    NSEnumerator *inventoryEnumerator = [((NSArray *)inventoryArray) objectEnumerator];
    NSDictionary *itemDictionary;
    while((itemDictionary = [inventoryEnumerator nextObject]))
    {
        Item *item = [[Item alloc] initWithDictionary:itemDictionary];
        item.tags = [[AppModel sharedAppModel] itemForItemId:item.itemId].tags;
        if(item.itemType == ItemTypeAttribute) [tempAttributes addObject:item];
        else                                   [tempInventory  addObject:item];
    }
    
    NSDictionary *inventory  = [[NSDictionary alloc] initWithObjectsAndKeys:tempInventory,@"inventory", nil];
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:tempAttributes,@"attributes", nil];
    NSLog(@"NSNotification: LatestPlayerInventoryReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerInventoryReceived" object:nil userInfo:inventory]];
    NSLog(@"NSNotification: LatestPlayerAttributesReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerAttributesReceived" object:nil userInfo:attributes]];
    NSLog(@"NSNotification: PlayerPieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerPieceReceived" object:nil]];
}

- (void)parseQRCodeObjectFromJSON:(ServiceResult *)jsonResult
{
    NSObject *qrCodeObject;
    
    if(jsonResult.data && jsonResult.data != [NSNull null])
    {
        NSDictionary *qrCodeDictionary = (NSDictionary *)jsonResult.data;
        if(![qrCodeDictionary isKindOfClass:[NSString class]])
        {
            NSString *type = [qrCodeDictionary validObjectForKey:@"link_type"];
            NSDictionary *objectDictionary = [qrCodeDictionary validObjectForKey:@"object"];
            if([type isEqualToString:@"Location"]) qrCodeObject = [[Location alloc] initWithDictionary:objectDictionary];
        }
        else qrCodeObject = qrCodeDictionary;
    }
    
    NSLog(@"NSNotification: QRCodeObjectReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"QRCodeObjectReady" object:qrCodeObject]];
}

- (void)parseUpdateServerWithPlayerLocationFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyUpdatingServerWithPlayerLocation) return;
    currentlyUpdatingServerWithPlayerLocation = NO;
}

- (void)parseQuestListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingQuestList) return;
    currentlyFetchingQuestList = NO;
    
    NSDictionary *questListsDictionary = (NSDictionary *)jsonResult.data;
    
    //Active Quests
    NSArray *activeQuestDicts = [questListsDictionary validObjectForKey:@"active"];
    NSEnumerator *activeQuestDictsEnumerator = [activeQuestDicts objectEnumerator];
    NSDictionary *activeQuestDict;
    NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
    while ((activeQuestDict = [activeQuestDictsEnumerator nextObject]))
    {
        Quest *quest = [[Quest alloc] init];
        quest.questId                  = [activeQuestDict validIntForKey:@"quest_id"];
        quest.mediaId                  = [activeQuestDict validIntForKey:@"active_media_id"];
        quest.iconMediaId              = [activeQuestDict validIntForKey:@"active_icon_media_id"];
        quest.notificationMediaId      = [activeQuestDict validIntForKey:@"active_notification_media_id"];  
        quest.sortNum                  = [activeQuestDict validIntForKey:@"sort_index"];
        quest.name                     = [activeQuestDict validStringForKey:@"name"];
        quest.qdescription             = [activeQuestDict validStringForKey:@"description"];
        quest.qdescriptionNotification = [activeQuestDict validStringForKey:@"description_notification"]; 
        quest.fullScreenNotification   = [activeQuestDict validBoolForKey:@"full_screen_notify"];
        quest.goFunction               = [activeQuestDict validStringForKey:@"go_function"];
        quest.notifGoFunction          = [activeQuestDict validStringForKey:@"notif_go_function"]; 
        quest.showDismiss              = [activeQuestDict validBoolForKey:@"active_notif_show_dismiss"]; 
        
        [activeQuestObjects addObject:quest];
    }
    
    //Completed Quests
    NSArray *completedQuestDicts = [questListsDictionary validObjectForKey:@"completed"];
    NSEnumerator *completedQuestDictsEnumerator = [completedQuestDicts objectEnumerator];
    NSDictionary *completedQuestDict;
    NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
    while ((completedQuestDict = [completedQuestDictsEnumerator nextObject]))
    {
        Quest *quest = [[Quest alloc] init];
        quest.questId                  = [completedQuestDict validIntForKey:@"quest_id"];
        quest.mediaId                  = [completedQuestDict validIntForKey:@"complete_media_id"];
        quest.iconMediaId              = [completedQuestDict validIntForKey:@"complete_icon_media_id"];
        quest.notificationMediaId      = [completedQuestDict validIntForKey:@"complete_notification_media_id"]; 
        quest.sortNum                  = [completedQuestDict validIntForKey:@"sort_index"];
        quest.name                     = [completedQuestDict validStringForKey:@"name"];
        quest.qdescription             = [completedQuestDict validStringForKey:@"text_when_complete"];
        quest.qdescriptionNotification = [completedQuestDict validStringForKey:@"text_when_complete_notification"];  
        quest.fullScreenNotification   = [completedQuestDict validBoolForKey:@"complete_full_screen_notify"]; 
        quest.goFunction               = [completedQuestDict validStringForKey:@"complete_go_function"];
        quest.notifGoFunction          = [completedQuestDict validStringForKey:@"complete_notif_go_function"]; 
        quest.showDismiss              = [completedQuestDict validBoolForKey:@"complete_notif_show_dismiss"];
        
        [completedQuestObjects addObject:quest];
    }
    
    //Package the two object arrays in a Dictionary
    NSMutableDictionary *questLists = [[NSMutableDictionary alloc] init];
    [questLists setObject:activeQuestObjects forKey:@"active"];
    [questLists setObject:completedQuestObjects forKey:@"completed"];
    
    NSLog(@"NSNotification: LatestPlayerQuestListsReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerQuestListsReceived" object:self userInfo:questLists]];
    NSLog(@"NSNotification: PlayerPieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PlayerPieceReceived" object:nil]];
}

@end
