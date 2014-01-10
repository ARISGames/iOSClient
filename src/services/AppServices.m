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
#import "Player.h"
#import "Note.h"
#import "Overlay.h"
#import "MediaModel.h"

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
                          username,@"ausername",
                          password,@"bpassword", 
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
                             userName,  @"ausername",
                             pass,      @"bpassword",
                             firstName, @"cfirstname",
                             lastName,  @"dlastname",
                             email,     @"eemail",
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
                             groupName,@"agroupName",
                             nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"createPlayerAndGetLoginPlayerObject" arguments:args handler:self successSelector:@selector(parseLoginResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setValue:fileURL forKey:@"url"];
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"object", @"key",
                          nil];
    
    //[connection performAsynchronousRequestWithService:@"notebook" method:@"addNoteFromJSON" arguments:args handler:self successSelector:@selector(playerPicUploadDidFinish:) failSelector:@selector(playerPicUploadDidFail:) userInfo:userInfo];
}

- (void) updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid
{
    if(playerId != 0)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",playerId], @"aplayerId",
                                 name,                                       @"bname",
                                 [NSString stringWithFormat:@"%d",mid],      @"cmediaId", 
                                 nil]; 
        [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerNameMedia" arguments:args handler:self successSelector:@selector(updatedPlayer:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
    else
        NSLog(@"Tried updating non-existent player! (playerId = 0)");
}

- (void) resetAndEmailNewPassword:(NSString *)email
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             email,@"aemail",
                             nil]; 
    [connection performAsynchronousRequestWithService:@"players" method:@"resetAndEmailNewPassword" arguments:args handler:self successSelector:@selector(parseResetAndEmailNewPassword:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) setShowPlayerOnMap
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId], @"aplayerId",
                             [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].showPlayerOnMap], @"bshowPlayerOnMap",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"aplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"blatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"clongitude",
                     [NSString stringWithFormat:@"%d",distanceInMeters],                                              @"ddistance",
                     [NSString stringWithFormat:@"%d",YES],                                                           @"equestion",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],              @"fshowGamesInDevel",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"aplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"blatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"clongitude",
                     [NSString stringWithFormat:@"%d",0],                                                             @"ddistanceInMeters",
                     [NSString stringWithFormat:@"%d",NO],                                                            @"equestion",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],              @"fshowGamesInDevel",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"aplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"blatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"clongitude",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],               @"dshowGamesInDevel",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],       @"aplayerId",
                     [NSString stringWithFormat:@"%d",time],                                            @"btime",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],@"cshowGamesInDevel",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"aplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"blatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"clongitude",
                     searchText,                                                                                       @"dsearchText",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],               @"eshowGamesInDevel",
                     [NSString stringWithFormat:@"%d", page],                                                          @"fpage",
                     nil];
    [connection performAsynchronousRequestWithService:@"games" method:@"getGamesContainingText" arguments:args handler:self successSelector:@selector(parseSearchGameListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerLocationViewed:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"clocationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"locationViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerNodeViewed:(int)nodeId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
                     [NSString stringWithFormat:@"%d",nodeId],                                      @"cnodeId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"nodeViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerWebPageViewed:(int)webPageId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
                     [NSString stringWithFormat:@"%d",webPageId],                                   @"cwebPageId",
                     [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"webPageViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerPanoramicViewed:(int)panoramicId fromLocation:(int)locationId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     [NSString stringWithFormat:@"%d",panoramicId],                                  @"cpanoramicId",
                     [NSString stringWithFormat:@"%d",locationId],                                   @"dlocationId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"augBubbleViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerItemViewed:(int)itemId fromLocation:(int)locationId
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
        [NSString stringWithFormat:@"%d",itemId],                                       @"citemId",
        [NSString stringWithFormat:@"%d",locationId],                                   @"dlocationId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"itemViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerNpcViewed:(int)npcId fromLocation:(int)locationId
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
        [NSString stringWithFormat:@"%d",npcId],                                       @"cnpcId",
        [NSString stringWithFormat:@"%d",locationId],                                  @"dlocationId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"npcViewed" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerGameSelected
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"aplayerId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"bgameId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"updatePlayerLastGame" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerMapViewed
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"mapViewed" arguments:args handler:self successSelector:@selector(fetchPlayerLocationList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerQuestsViewed
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"questsViewed" arguments:args handler:self successSelector:@selector(fetchPlayerQuestList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerInventoryViewed
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
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
        [NSString stringWithFormat:@"%d", gameId],                                   @"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"bplayerId",
        nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"startOverGameForPlayer" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"citemId",
                     [NSString stringWithFormat:@"%d",locationId],                                   @"dlocationId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"eqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"pickupItemFromLocation" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)updateServerDropItemHere:(int)itemId qty:(int)qty
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                   @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                      @"bplayerId",
                     [NSString stringWithFormat:@"%d",itemId],                                                         @"citemId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],  @"dlatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude], @"elongitude",
                     [NSString stringWithFormat:@"%d",qty],                                                            @"fqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"dropItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
                     [NSString stringWithFormat:@"%d",noteId],                                      @"cnoteId",
                     [NSString stringWithFormat:@"%f",coordinate.latitude],                         @"dlatitude",
                     [NSString stringWithFormat:@"%f",coordinate.longitude],                        @"elongitude",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"dropNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerDestroyItem:(int)itemId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"citemId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"destroyItem" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerInventoryItem:(int)itemId qty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"btemId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"cplayerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"setItemCountForPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerAddInventoryItem:(int)itemId addQty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"bitemId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"cplayerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"giveItemToPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",itemId],                                       @"bitemId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"cplayerId",
                     [NSString stringWithFormat:@"%d",qty],                                          @"dqty",
                     nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"takeItemFromPlayer" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",noteId], @"anoteId",
                     title,                                    @"btitle",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateComment" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) likeNote:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"aplayerId",
                     [NSString stringWithFormat:@"%d",noteId],                                    @"bnoteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"likeNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) unLikeNote:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"aplayerId",
                     [NSString stringWithFormat:@"%d",noteId],                                    @"bnoteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"unlikeNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (int) addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     [NSString stringWithFormat:@"%d",noteId],                                       @"cnoteId",
                     title,                                                                          @"dtitle",
                     nil];
    ServiceResult *result = [connection performSynchronousRequestWithService:@"notes" method:@"addCommentToNote" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (void) setNoteCompleteForNoteId:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",noteId], @"anoteId",
            nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"setNoteComplete" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (int) createNote
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"bplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"clatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"dlongitude",
                     nil];
    ServiceResult *result =[connection performSynchronousRequestWithService:@"notes" method:@"createNewNote" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (int) createNoteStartIncomplete
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"bplayerId",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"clatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"dlongitude",
                     nil];
    ServiceResult *result = [connection performSynchronousRequestWithService:@"notes" method:@"createNewNoteStartIncomplete" arguments:args userInfo:nil];
    [self fetchAllPlayerLists];
    
    return result.data ? [(NSDecimalNumber*)result.data intValue] : 0;
}

- (void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",noteId],                                      @"anoteId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"bgameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"cplayerId",
                     [NSString stringWithFormat:@"%d",mediaId],                                     @"dmediaId",
                     type,                                                                          @"etype",
                     text,                                                                          @"ftext",
                     nil];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:noteId], @"noteId", fileURL, @"localURL", nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"addContentToNote" arguments:args handler:self successSelector:@selector(contentAddedToNoteWithText:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:userInfo];
}

- (void) deleteNoteContentWithContentId:(int)contentId
{
    if(contentId != -1)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%d",contentId], @"acontentId",
                        nil];
        [connection performAsynchronousRequestWithService:@"notes" method:@"deleteNoteContent" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
}

- (void) deleteNoteLocationWithNoteId:(int)noteId
{
       NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     @"PlayerNote",                                                                  @"blocationType",
                     [NSString stringWithFormat:@"%d",noteId],                                       @"cnoteId",
                     nil];
    [connection performAsynchronousRequestWithService:@"locations" method:@"deleteLocationsForObject" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) deleteNoteWithNoteId:(int)noteId
{
    if(noteId != 0)
    {
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSString stringWithFormat:@"%d",noteId], @"anoteId",
                         nil];
        [connection performAsynchronousRequestWithService:@"notes" method:@"deleteNote" arguments:args handler:self successSelector:@selector(fetchNoteList) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    }
}

- (void) uploadNote:(Note *)n
{
    NSDictionary *location = [[NSDictionary alloc] initWithObjectsAndKeys: 
                              [NSNumber numberWithBool:n.location.latlon.coordinate.latitude],  @"latitude",
                              [NSNumber numberWithBool:n.location.latlon.coordinate.longitude], @"longitude", 
                              nil];
    NSMutableArray *media = [[NSMutableArray alloc] initWithCapacity:n.contents];
    for(int i = 0; i < [n.contents count]; i++)
    {
        NSDictionary *m = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"path",
                           [((Media *)[n.contents objectAtIndex:i]).localURL absoluteString],@"filename", 
                           [((Media *)[n.contents objectAtIndex:i]).data base64Encoding],@"data", 
                           nil];
        [media addObject:m];
    }
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:[AppModel sharedAppModel].currentGame.gameId], @"gameId", 
                          [NSNumber numberWithInt:[AppModel sharedAppModel].player.playerId],    @"playerId",  
                          n.name,                                                                @"title",
                          n.desc,                                                                @"description", 
                          [NSNumber numberWithBool:n.publicToMap],                               @"publicToMap",  
                          [NSNumber numberWithBool:n.publicToList],                              @"publicToBook",  
                          location,                                                              @"location",   
                          media,                                                                 @"media",    
                          nil]; 
    [connection performAsynchronousRequestWithService:@"notebook" method:@"addNoteFromJSON" arguments:args handler:self successSelector:nil failSelector:nil userInfo:nil]; 
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

- (void) playerPicUploadDidFinish:(ServiceResult*)result
{        
    NSString *newFileName = (NSString *)result.data;
    
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], @"aplayerId",
            newFileName,                                                                 @"bfileName",
            nil];
    [connection performAsynchronousRequestWithService:@"players" method:@"addPlayerPicFromFilename" arguments:args handler:self successSelector:@selector(parseNewPlayerMediaResponseFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
    
}

- (void) updatedPlayer:(ServiceResult *)result
{
    //immediately load new image into cache
    if([AppModel sharedAppModel].player.playerMediaId != 0)
        [self loadMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId] delegate:nil]; 
}

- (void) parseNewPlayerMediaResponseFromJSON:(ServiceResult *)jsonResult
{	   
    if(jsonResult.data && [((NSDictionary *)jsonResult.data) validIntForKey:@"media_id"])
    {
        [AppModel sharedAppModel].player.playerMediaId = [((NSDictionary*)jsonResult.data) validIntForKey:@"media_id"];
        //immediately load new image into cache 
        if([AppModel sharedAppModel].player.playerMediaId != 0)
            [self loadMedia:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId] delegate:nil];  
        [[AppModel sharedAppModel] saveUserDefaults];
    }
}

- (void) playerPicUploadDidFail:(ServiceResult *)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UploadFailedKey", @"") message:NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
    
    [alert show];
}

- (void) updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList
{	
    
      NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
             [NSString stringWithFormat:@"%d",noteId],      @"anoteId",
             title,                                         @"btitle",
             [NSString stringWithFormat:@"%d",publicToMap], @"cpublicToMap",
             [NSString stringWithFormat:@"%d",publicToList],@"epublicToList",
             nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateNote" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) updateNoteContent:(int)contentId title:(NSString *)text;
{	
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",contentId],@"acontentId",
            text,                                       @"btext",
            nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"updateContentTitle" arguments:args handler:self successSelector:@selector(fetchAllPlayerLists) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)updateNoteContent:(int)contentId text:(NSString *)text
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",contentId],@"acontentId",
        text,                                       @"btext",
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
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"aplayerId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],                  @"bgameId",
            [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"clatitude",
            [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"dlongitude",
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
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
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
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[overlayDictionary validIntForKey:@"media_id"]];
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
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[overlayDictionary validIntForKey:@"media_id"]];
            [tempOverlay.tileImage addObject:media];
            currentOverlayID = tempOverlay.overlayId;
        }
    }
    
    /*
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
     */
    
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
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
            nil];
    
    [connection performAsynchronousRequestWithService:@"games" method:@"getTabBarItemsForGame" arguments:args handler:self successSelector:@selector(parseGameTabListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchQRCode:(NSString*)code
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
        [NSString stringWithFormat:@"%@",code],                                        @"bcode",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"cplayerId",
        nil];
    [connection performAsynchronousRequestWithService:@"qrcodes" method:@"getQRCodeNearbyObjectForPlayer" arguments:args handler:self successSelector:@selector(parseQRCodeObjectFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
            [NSString stringWithFormat:@"%d",npcId],                                        @"bnpcId",
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"cplayerId",
            [NSString stringWithFormat:@"%d",nodeId],                                       @"dnodeId",
            nil];
    [connection performAsynchronousRequestWithService:@"npcs" method:@"getNpcConversationsForPlayerAfterViewingNode" arguments:args handler:self successSelector:@selector(parseConversationOptionsFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNpcList
{
              NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
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
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
                     [NSString stringWithFormat:@"%d",page],                                         @"cpage",
                     [NSString stringWithFormat:@"%d", 20],                                          @"dqty",
                     nil];
    
    [connection performAsynchronousRequestWithService:@"notebook" method:@"getStubNotesVisibleToPlayer" arguments:args handler:self successSelector:@selector(parseNoteListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchNoteWithId:(int)noteId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%d",noteId],@"anoteId",
                    nil];
    [connection performAsynchronousRequestWithService:@"notebook" method:@"getNote" arguments:args handler:self successSelector:@selector(parseNoteFromJSON:) failSelector:nil userInfo:nil]; 
}

- (void) fetchGameWebPageList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
        nil];
    
    [connection performAsynchronousRequestWithService:@"webpages" method:@"getWebPages" arguments:args handler:self successSelector:@selector(parseGameWebPageListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) fetchMediaMeta:(Media *)m
{
  NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
         (([AppModel sharedAppModel].currentGame.gameId != 0) ? [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId] : @"player"), @"apath",
         [NSString stringWithFormat:@"%d",m.mediaId], @"bmediaId",
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
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
            nil];
    [connection performAsynchronousRequestWithService:@"media" method:@"getMedia" arguments:args handler:self successSelector:@selector(parseGameMediaListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGamePanoramicList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
        nil];
    [connection performAsynchronousRequestWithService:@"augbubbles" method:@"getAugBubbles" arguments:args handler:self successSelector:@selector(parseGamePanoramicListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameItemList
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
            nil];
    [connection performAsynchronousRequestWithService:@"items" method:@"getFullItems" arguments:args handler:self successSelector:@selector(parseGameItemListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNodeList
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
                                 nil];
    [connection performAsynchronousRequestWithService:@"nodes" method:@"getNodes" arguments:args handler:self successSelector:@selector(parseGameNodeListFromJSON:) failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void)fetchGameNoteTags
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
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
                                 [NSString stringWithFormat:@"%d",noteId],                                       @"anoteId", 
                                 [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"bgameId",
                                 tag,                                                                            @"ctag",
                                 nil];
    [connection performAsynchronousRequestWithService:@"notes" method:@"addTagToNote" arguments:args handler:self successSelector:nil failSelector:@selector(resetCurrentlyFetchingVars) userInfo:nil];
}

- (void) deleteTagFromNote:(int)noteId tagId:(int)tagId
{
    NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%d",noteId], @"anoteId",
                          [NSString stringWithFormat:@"%d",tagId],  @"btagId",
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
        [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId], @"agameId",
        [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],     @"bplayerId",
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
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
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
             [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],@"agameId",
             [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],   @"bplayerId",
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
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], @"agameId",
                                    [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],    @"bplayerId",
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
                     [NSString stringWithFormat:@"%d",gameId],                                                        @"agameId",
                     [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],                     @"bplayerId",
                     [NSString stringWithFormat:@"%d",1],                                                             @"cquestion",
                     [NSString stringWithFormat:@"%d",999999999],                                                     @"dquestion",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude], @"elatitude",
                     [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],@"flongitude",
                     [NSString stringWithFormat:@"%d",1],                                                             @"gshowGamesInDev",// = 1, because if you're specifically seeking out one game, who cares
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
    game.playerCount              = [gameSource validIntForKey:@"count"];
    game.desc                     = [gameSource validStringForKey:@"description"];
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
    
    game.iconMedia   = [[AppModel sharedAppModel] mediaForMediaId:[gameSource validIntForKey:@"icon_media_id"]];
    game.splashMedia = [[AppModel sharedAppModel] mediaForMediaId:[gameSource validIntForKey:@"media_id"]];
    
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
    
    NSLog(@"NSNotification: NewRecentGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewRecentGameListReady" object:nil]];
}

- (void)saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating
{
           NSDictionary *args = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId], @"aplayerId",
                                 [NSString stringWithFormat:@"%d", gameId],                                    @"bgameId",
                                 [NSString stringWithFormat:@"%d", rating],                                    @"crating",
                                 comment,                                                                      @"dcomment",
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
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread //Phil thinks this is fishy/stupid... 12/13
}

- (void)parseGameMediaListFromJSON:(ServiceResult *)jsonResult
{
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread //Phil thinks this is fishy/stupid... 12/13
}

- (void)startCachingMedia:(ServiceResult *)jsonResult
{
    [[AppModel sharedAppModel].mediaModel syncMediaDataToCache:(NSArray *)jsonResult.data];
    
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
    
    [AppModel sharedAppModel].currentGame.itemList = tempItemList;
    
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
    
    [AppModel sharedAppModel].currentGame.nodeList = tempNodeList;
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
    
    [AppModel sharedAppModel].currentGame.npcList = tempNpcList;
    
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
    
    [AppModel sharedAppModel].currentGame.webpageList = tempWebPageList;
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
    
    [AppModel sharedAppModel].currentGame.panoramicList = tempPanoramicList;
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
        item.tags = [[AppModel sharedAppModel].currentGame itemForItemId:item.itemId].tags;
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
