//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"
#import "ARISUploader.h"
#import "NSDictionary+ValidParsers.h"
#import "NodeOption.h"
#import "ARISAlertHandler.h"

static const int kDefaultCapacity = 10;
static const BOOL kEmptyBoolValue = NO;
static const int kEmptyIntValue = 0;
static const float kEmptyFloatValue = 0.0;
static const double kEmptyDoubleValue = 0.0;
NSString *const kARISServerServicePackage = @"v1";

BOOL currentlyFetchingLocationList;
BOOL currentlyFetchingOverlayList;
BOOL currentlyFetchingGameNoteList;
BOOL currentlyFetchingPlayerNoteList;
BOOL currentlyFetchingInventory;
BOOL currentlyFetchingQuestList;
BOOL currentlyFetchingOneGame;
BOOL currentlyFetchingNearbyGamesList;
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

- (void) resetCurrentlyFetchingVars
{
    currentlyFetchingNearbyGamesList           = NO;
    currentlyFetchingSearchGamesList           = NO;
    currentlyFetchingPopularGamesList          = NO;
    currentlyFetchingRecentGamesList           = NO;
    currentlyFetchingInventory                 = NO;
    currentlyFetchingLocationList              = NO;
    currentlyFetchingOverlayList               = NO;
    currentlyFetchingQuestList                 = NO;
    currentlyFetchingGameNoteList              = NO;
    currentlyFetchingPlayerNoteList            = NO;
    currentlyUpdatingServerWithInventoryViewed = NO;
    currentlyUpdatingServerWithMapViewed       = NO;
    currentlyUpdatingServerWithPlayerLocation  = NO;
    currentlyUpdatingServerWithQuestsViewed    = NO;
}

#pragma mark Communication with Server
- (void) loginUserName:(NSString *)username password:(NSString *)password userInfo:(NSMutableDictionary *)dict
{
	NSArray *arguments = [NSArray arrayWithObjects:username, password, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"getLoginPlayerObject"
                                                               andArguments:arguments
                                                                andUserInfo:dict];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLoginResponseFromJSON:)];
}

- (void) parseLoginResponseFromJSON:(ServiceResult *)result
{
    NSMutableDictionary *responseDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [responseDict setObject:result forKey:@"result"];
    NSLog(@"NSNotification: LoginResponseReady");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LoginResponseReady" object:nil userInfo:responseDict]];
}

- (void) registerNewUser:(NSString*)userName password:(NSString*)pass
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email
{
	//createPlayer($strNewUserName, $strPassword, $strFirstName, $strLastName, $strEmail)
	NSArray *arguments = [NSArray arrayWithObjects:userName, pass, firstName, lastName, email, nil];
    [AppModel sharedAppModel].player.username = userName;
    //[AppModel sharedAppModel].password = pass;
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"createPlayer"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseSelfRegistrationResponseFromJSON:)];
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
	NSArray *arguments = [NSArray arrayWithObjects:groupName, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"createPlayerAndGetLoginPlayerObject"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLoginResponseFromJSON:)];
}

- (void) uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL
{
    ARISUploader *uploader = [[ARISUploader alloc] initWithURLToUpload:fileURL gameSpecific:NO delegate:self doneSelector:@selector(playerPicUploadDidFinish:) errorSelector:@selector(playerPicUploadDidFail:)];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setValue:@"PHOTO" forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
	[uploader setUserInfo:userInfo];

	//ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[[[RootViewController sharedRootViewController] showWaitingIndicator:@"Uploading" displayProgressBar:YES];
	//[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
    
	[uploader upload];
}

- (void) updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid
{
    if(playerId != 0)
    {
        //Call server service
        NSArray *arguments = [NSArray arrayWithObjects:
                              [NSString stringWithFormat:@"%d",playerId],
                              name,
                              [NSString stringWithFormat:@"%d",mid],
                              nil];
        JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                                andServiceName:@"players"
                                                                 andMethodName:@"updatePlayerNameMedia"
                                                                  andArguments:arguments
                                                                   andUserInfo:nil];
        [jsonConnection performAsynchronousRequestWithHandler:nil];
    }
    else
        NSLog(@"Tried updating non-existent player! (playerId = 0)");
}

-(void)resetAndEmailNewPassword:(NSString *)email
{
    NSArray *arguments = [NSArray arrayWithObjects:
                          email,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]
                                      initWithServer:[AppModel sharedAppModel].serverURL
                                      andServiceName:@"players"
                                      andMethodName:@"resetAndEmailNewPassword"
                                      andArguments:arguments
                                      andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:
     @selector(parseResetAndEmailNewPassword:)];
}

-(void)setShowPlayerOnMap
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId],[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].showPlayerOnMap], nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"setShowPlayerOnMap"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil];
}

- (void)fetchGameListWithDistanceFilter:(int)distanceInMeters locational:(BOOL)locationalOrNonLocational
{
    if (currentlyFetchingNearbyGamesList)
    {
        NSLog(@"Skipping Request: already fetching nearby games");
        return;
    }
    
    currentlyFetchingNearbyGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",distanceInMeters],
                          [NSString stringWithFormat:@"%d",locationalOrNonLocational],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getGamesForPlayerAtLocation"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseNearbyGameListFromJSON:)];
}

- (void)fetchRecentGameListForPlayer
{
    if (currentlyFetchingRecentGamesList)
    {
        NSLog(@"Skipping Request: already fetching recent games");
        return;
    }
    
    currentlyFetchingRecentGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getRecentGamesForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseRecentGameListFromJSON:)];
}

- (void)fetchPopularGameListForTime:(int)time
{
    if (currentlyFetchingPopularGamesList)
    {
        NSLog(@"Skipping Request: already fetching popular games");
        return;
    }
    
    currentlyFetchingPopularGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%d",time],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getPopularGames"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parsePopularGameListFromJSON:)];
}

- (void)fetchGameListBySearch:(NSString *)searchText onPage:(int)page
{
    if (currentlyFetchingSearchGamesList)
    {
        NSLog(@"Skipping Request: already fetching search games");
        return;
    }
    
    currentlyFetchingSearchGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
						  searchText,
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
                          [NSString stringWithFormat:@"%d", page],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getGamesContainingText"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseSearchGameListFromJSON:)];
}

- (void) updateServerNodeViewed:(int)nodeId fromLocation:(int)locationId
{
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d", nodeId],
                          [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"nodeViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerWebPageViewed:(int)webPageId fromLocation:(int)locationId
{
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",webPageId],
                          [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"webPageViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerPanoramicViewed:(int)panoramicId fromLocation:(int)locationId
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",panoramicId],
                          [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"augBubbleViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerItemViewed:(int)itemId fromLocation:(int)locationId
{	
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"itemViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
    
}

- (void) updateServerNpcViewed:(int)npcId fromLocation:(int)locationId
{	
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",npcId],
						  [NSString stringWithFormat:@"%d",locationId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"npcViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerGameSelected
{	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"updatePlayerLastGame"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil];
}

- (void) updateServerMapViewed
{
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"mapViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerLocationList)];
}

- (void) updateServerQuestsViewed
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"questsViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerQuestList)];
}

- (void) updateServerInventoryViewed
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"inventoryViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerInventory)];
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
    [self resetAllGameLists];
    
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d", gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]
                                      initWithServer:[AppModel sharedAppModel].serverURL
                                      andServiceName:@"players"
                                      andMethodName:@"startOverGameForPlayer"
                                      andArguments:arguments
                                      andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil];
}

- (void) updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%d",locationId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"pickupItemFromLocation"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void)updateServerDropItemHere:(int)itemId qty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"dropItem"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",noteId],
						  [NSString stringWithFormat:@"%f",coordinate.latitude],
						  [NSString stringWithFormat:@"%f",coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"dropNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerDestroyItem:(int)itemId qty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"destroyItem"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerInventoryItem:(int)itemId qty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"setItemCountForPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerAddInventoryItem:(int)itemId addQty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"giveItemToPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty
{
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"takeItemFromPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) commitInventoryTrade:(int)gameId fromMe:(int)playerOneId toYou:(int)playerTwoId giving:(NSString *)giftsJSON receiving:(NSString *)receiptsJSON
{
    //  Gifts/Receipts json should be of following format:
    //  {"items":[{"item_id":1,"qtyDelta":3},{"item_id":2,"qtyDelta":4}]}
    
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",gameId],
						  [NSString stringWithFormat:@"%d",playerOneId],
						  [NSString stringWithFormat:@"%d",playerTwoId],
                          giftsJSON,
                          receiptsJSON,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"items"
                                                             andMethodName:@"commitTradeTransaction"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerInventory)];
}

- (void) updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",noteId],
                          title,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateComment"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    
    if(refresh)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)];
    else
        [jsonConnection performAsynchronousRequestWithHandler:nil];	
}

- (void) likeNote:(int)noteId
{
    NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"likeNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) unLikeNote:(int)noteId
{
    NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"unlikeNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (int) addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          title,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addCommentToNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	ServiceResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
	
	if (!jsonResult) return 0;
	else             return [(NSDecimalNumber*)jsonResult.data intValue];
}

- (void) setNoteCompleteForNoteId:(int)noteId
{
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"setNoteComplete"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
}

- (int) createNote
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"createNewNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	ServiceResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
    
	if(!jsonResult) return 0;
	else            return jsonResult.data ? [(NSDecimalNumber*)jsonResult.data intValue] : 0;
}

- (int) createNoteStartIncomplete
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"createNewNoteStartIncomplete"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	ServiceResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
	if (!jsonResult) return 0;
	else             return jsonResult.data ? [(NSDecimalNumber*)jsonResult.data intValue] : 0;
}

- (void) contentAddedToNoteWithText:(ServiceResult *)result
{
    if([result.userInfo validObjectForKey:@"noteId"])
        [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:[result.userInfo validIntForKey:@"noteId"]
                                                              andFileURL:[result.userInfo validObjectForKey:@"localURL"]];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
    [self fetchPlayerNoteListAsync];
}

- (void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL
{
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",noteId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",mediaId],
                          type,
						  text,
						  nil];
    
    NSMutableDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:noteId], @"noteId", fileURL, @"localURL", nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addContentToNote"
                                                              andArguments:arguments
                                                               andUserInfo:userInfo];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(contentAddedToNoteWithText:)];
}

- (void) deleteNoteContentWithContentId:(int)contentId
{
    if(contentId != -1)
    {
        NSArray *arguments = [NSArray arrayWithObjects:
                              [NSString stringWithFormat:@"%d",contentId],
                              nil];
        JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                                andServiceName:@"notes"
                                                                 andMethodName:@"deleteNoteContent"
                                                                  andArguments:arguments
                                                                   andUserInfo:nil];
        [jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNoteViewer)];
    }
}

- (void) deleteNoteLocationWithNoteId:(int)noteId
{
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          @"PlayerNote",
						  [NSString stringWithFormat:@"%d",noteId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"locations"
                                                             andMethodName:@"deleteLocationsForObject"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) deleteNoteWithNoteId:(int)noteId
{
    if(noteId != 0)
    {
        NSArray *arguments = [NSArray arrayWithObjects:
                              [NSString stringWithFormat:@"%d",noteId],
                              nil];
        JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                                andServiceName:@"notes"
                                                                 andMethodName:@"deleteNote"
                                                                  andArguments:arguments
                                                                   andUserInfo:nil];
        [jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNotebookViewer)];
    }
}

- (void) sendNotificationToNoteViewer
{
    NSLog(@"NSNotification: NewContentListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewContentListReady" object:nil]];
    [self fetchPlayerNoteListAsync];
}

- (void) sendNotificationToNotebookViewer
{
    NSLog(@"NSNotification: NoteDeleted");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NoteDeleted" object:nil]];
    [self fetchPlayerNoteListAsync];
}

- (void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int) noteId type: (NSString *)type
{
    ARISUploader *uploader = [[ARISUploader alloc] initWithURLToUpload:fileURL gameSpecific:YES delegate:self doneSelector:@selector(noteContentUploadDidFinish: ) errorSelector:@selector(uploadNoteContentDidFail:)];
    
    NSNumber *nId = [[NSNumber alloc] initWithInt:noteId];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:4];
    [userInfo setValue:name forKey:@"title"];
    [userInfo setValue:nId forKey:@"noteId"];
    [userInfo setValue:type forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
	[uploader setUserInfo:userInfo];
	
	[uploader upload];
}

- (void) fetchPlayerNoteListAsync
{
    [self fetchGameNoteListAsynchronously:YES];
    [self fetchPlayerNoteListAsynchronously:YES];
}

- (void) noteContentUploadDidFinish:(ARISUploader*)uploader
{
    int noteId      = [[uploader userInfo] validIntForKey:@"noteId"] ? [[uploader userInfo] validIntForKey:@"noteId"] : 0;
    NSString *title = [[uploader userInfo] validObjectForKey:@"title"];
    NSString *type  = [[uploader userInfo] validObjectForKey:@"type"];
    NSURL *localUrl = [[uploader userInfo] validObjectForKey:@"url"];
    NSString *newFileName = [uploader responseString];
    
    //TODO: Check that the response string is actually a new filename that was made on the server, not an error
    
    NoteContent *newContent = [[NoteContent alloc] init];
    newContent.noteId = noteId;
    newContent.title = @"Refreshing From Server...";
    newContent.type = type;
    newContent.contentId = 0;
    
    [[[[[AppModel sharedAppModel] playerNoteList] objectForKey:[NSNumber numberWithInt:noteId]] contents] addObject:newContent];
    [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:noteId andFileURL:localUrl];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",noteId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  newFileName,
                          type,
                          title,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addContentToNoteFromFileName"
                                                              andArguments:arguments
                                                               andUserInfo:nil];

	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)];
    [self fetchAllPlayerLists];
}

- (void) uploadNoteContentDidFail:(ARISUploader *)uploader
{
    NSError *error = uploader.error;
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	
	[alert show];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:5];
    nId = [[uploader userInfo] validObjectForKey:@"noteId"];
	//if (description == NULL) description = @"filename";
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
    NSLog(@"NSNotification: NewNoteListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
}

- (void) playerPicUploadDidFinish:(ARISUploader*)uploader
{        
    NSString *newFileName = [uploader responseString];
    
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  newFileName,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"addPlayerPicFromFilename"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseNewPlayerMediaResponseFromJSON:)];
    
    [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:-1 andFileURL:[uploader.userInfo validObjectForKey:@"url"]];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
}

- (void) parseNewPlayerMediaResponseFromJSON:(ServiceResult *)jsonResult
{	   
    if(jsonResult.data && [((NSDictionary *)jsonResult.data) validIntForKey:@"media_id"])
    {
        [AppModel sharedAppModel].player.playerMediaId = [((NSDictionary*)jsonResult.data) validIntForKey:@"media_id"];
        [[AppModel sharedAppModel] saveUserDefaults];
    }
}

- (void) playerPicUploadDidFail:(ARISUploader *)uploader
{
    NSError *error = uploader.error;
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	
	[alert show];
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
}

- (void) updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList
{	
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",noteId],
						  title,
                          [NSString stringWithFormat:@"%d",publicToMap],
                          [NSString stringWithFormat:@"%d",publicToList],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];
}

- (void) updateNoteContent:(int)contentId title:(NSString *)text;
{	
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",contentId],
						  text,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateContentTitle"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];    
}

-(void)updateNoteContent:(int)contentId text:(NSString *)text
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",contentId],
						  text,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateContent"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)];    
}

- (void)updateServerWithPlayerLocation
{
	if (![AppModel sharedAppModel].player)
    {
        NSLog(@"Skipping Request: player not logged in");
		return;
	}
	
	if (currentlyUpdatingServerWithPlayerLocation)
    {
        NSLog(@"Skipping Request: already updating player location");
        return;
    }
    
    currentlyUpdatingServerWithPlayerLocation = YES;
    
	//Update the server with the new Player Location
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"updatePlayerLocation"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseUpdateServerWithPlayerLocationFromJSON:)];
}

#pragma mark ASync Fetch selectors

- (void) fetchAllGameLists
{
    [self fetchTabBarItemsAsynchronously:      YES];
    [self fetchGameMediaListAsynchronously:    YES];
    [self fetchGameItemListAsynchronously:     YES];
    [self fetchGameNpcListAsynchronously:      YES];
    [self fetchGameNodeListAsynchronously:     YES];
    [self fetchGamePanoramicListAsynchronously:YES];
    [self fetchGameWebPageListAsynchronously:  YES];
    [self fetchGameOverlayListAsynchronously:  YES];
    
    [self fetchGameNoteListAsynchronously:NO];
    [self fetchPlayerNoteListAsynchronously:YES];
}

- (void) resetAllGameLists
{
	NSLog(@"Resetting game lists");
	[[AppModel sharedAppModel].gameItemList removeAllObjects];
	[[AppModel sharedAppModel].gameNodeList removeAllObjects];
    [[AppModel sharedAppModel].gameNpcList removeAllObjects];
    [[AppModel sharedAppModel].gameMediaList removeAllObjects];
    [[AppModel sharedAppModel].gameWebPageList removeAllObjects];
    [[AppModel sharedAppModel].gamePanoramicList removeAllObjects];
    [[AppModel sharedAppModel].playerNoteList removeAllObjects];
    [[AppModel sharedAppModel].gameNoteList removeAllObjects];
}

- (void) fetchGameOverlayListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"overlays"
                                                             andMethodName:@"getCurrentOverlaysForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
	if (YesForAsyncOrNoForSync) [jsonConnection performAsynchronousRequestWithHandler:@selector(parseOverlayListFromJSON:)];
    else [self parseOverlayListFromJSON: [jsonConnection performSynchronousRequest]];
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
        if (currentOverlayID != [overlayDictionary validIntForKey:@"overlay_id"])
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
    // don' do that for offline game
    Game *game = [AppModel sharedAppModel].currentGame;
    if (!game.offlineMode) {
        for (int iOverlay=0; iOverlay < [[AppModel sharedAppModel].overlayList count]; iOverlay++) {
            Overlay *currentOverlay = [[AppModel sharedAppModel].overlayList objectAtIndex:iOverlay];
            int iTiles = [currentOverlay.tileX count];
            for (int iTile = 0; iTile < iTiles; iTile++)
            {
                // step through tile list and update media with images
                AsyncMediaImageView *aImageView = [[AsyncMediaImageView alloc] init ];
                [aImageView loadMedia:[currentOverlay.tileImage objectAtIndex:iTile]];
            }
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

- (void)resetAllPlayerLists
{
	NSLog(@"AppModel: resetAllPlayerLists");    
	[AppModel sharedAppModel].nearbyLocationsList = [[NSMutableArray alloc] initWithCapacity:0];
	[[AppModel sharedAppModel].currentGame clearLocalModels];
    [[AppModel sharedAppModel].overlayList removeAllObjects];
}

-(void)fetchTabBarItemsAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
    NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  nil];
    
    JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getTabBarItemsForGame"
                                                              andArguments:arguments andUserInfo:nil];
    if (YesForAsyncOrNoForSync)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTabListFromJSON:)];
	else
        [self parseGameTabListFromJSON:[jsonConnection performSynchronousRequest]];
}

-(void)fetchQRCode:(NSString*)code
{
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%@",code],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];

	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"qrcodes"
                                                             andMethodName:@"getQRCodeNearbyObjectForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQRCodeObjectFromJSON:)];
}

-(void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId
{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",npcId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  [NSString stringWithFormat:@"%d",nodeId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"npcs"
                                                             andMethodName:@"getNpcConversationsForPlayerAfterViewingNode"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseConversationNodeOptionsFromJSON:)];
}

- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"npcs"
                                                             andMethodName:@"getNpcs"
                                                              andArguments:arguments andUserInfo:nil];
	if(YesForAsyncOrNoForSync)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNpcListFromJSON:)];
	else
        [self parseGameNpcListFromJSON:[jsonConnection performSynchronousRequest]];
}

- (void)fetchGameNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
    if (currentlyFetchingGameNoteList)
    {
        NSLog(@"Skipping Request: already fetching game notes");
        return;
    }
     
    currentlyFetchingGameNoteList = YES;
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForGame"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNoteListFromJSON:)];
	}
	else [self parseGameNoteListFromJSON:[jsonConnection performSynchronousRequest]];
}

- (void)fetchPlayerNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	if (currentlyFetchingPlayerNoteList)
    {
        NSLog(@"Skipping Request: already fetching player notes");
        return;
    }
     
    currentlyFetchingPlayerNoteList = YES;
    
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parsePlayerNoteListFromJSON:)];
	else [self parsePlayerNoteListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGameWebPageListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"webpages"
                                                             andMethodName:@"getWebPages"
                                                              andArguments:arguments andUserInfo:nil];
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameWebPageListFromJSON:)];
	else [self parseGameWebPageListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void) fetchMedia:(int)mediaId
{
    NSArray *arguments = [NSArray arrayWithObjects:
                          (([AppModel sharedAppModel].currentGame.gameId != 0) ? [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId] : @"player"),
                          [NSString stringWithFormat:@"%d",mediaId],
                          nil];
    
    JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"media"
                                                             andMethodName:@"getMediaObject"
                                                              andArguments:arguments andUserInfo:nil];
    
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseSingleMediaFromJSON:)];
}

- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"media"
                                                             andMethodName:@"getMedia"
                                                              andArguments:arguments andUserInfo:nil];
	
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameMediaListFromJSON:)];
	else [self parseGameMediaListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"augbubbles"
                                                             andMethodName:@"getAugBubbles"
                                                              andArguments:arguments andUserInfo:nil];
	
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGamePanoramicListFromJSON:)];
	else [self parseGamePanoramicListFromJSON: [jsonConnection performSynchronousRequest]];
}


- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"items"
                                                             andMethodName:@"getItems"
                                                              andArguments:arguments andUserInfo:nil];
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameItemListFromJSON:)];
	else
        [self parseGameItemListFromJSON:[jsonConnection performSynchronousRequest]];
	
}

- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"nodes"
                                                             andMethodName:@"getNodes"
                                                              andArguments:arguments andUserInfo:nil];
    
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNodeListFromJSON:)];    
	else
    {
        ServiceResult *result = [jsonConnection performSynchronousRequest];
        [self parseGameNodeListFromJSON: result];
    }
}

- (void)fetchGameNoteTagsAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getAllTagsInGame"
                                                              andArguments:arguments andUserInfo:nil];
    
    if(YesForAsyncOrNoForSync)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTagsListFromJSON:)];    
	else
    {
        ServiceResult *result = [jsonConnection performSynchronousRequest];
        [self parseGameTagsListFromJSON: result];
    }
}

-(void)parseGameTagsListFromJSON:(ServiceResult *)jsonResult
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
    
    NSLog(@"NSNotification: NewNoteListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
}

-(void)addTagToNote:(int)noteId tagName:(NSString *)tag
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],tag, nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addTagToNote"
                                                              andArguments:arguments andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil];
}

-(void)deleteTagFromNote:(int)noteId tagId:(int)tagId
{
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",tagId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"deleteTagFromNote"
                                                              andArguments:arguments andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil];
    
}

- (void)fetchPlayerLocationList
{
    if (currentlyFetchingLocationList)
    {
        NSLog(@"Skipping Request: already fetching locations");
        return;
    }
    
    currentlyFetchingLocationList = YES;
    
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"locations"
                                                             andMethodName:@"getLocationsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLocationListFromJSON:)];
}

- (void)fetchPlayerOverlayList
{
    if (currentlyFetchingOverlayList)
    {
        NSLog(@"Skipping Request: already fetching overlays or interacting with object");
        return;
    }
    
    currentlyFetchingOverlayList = YES;
    
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"overlays"
                                                             andMethodName:@"getCurrentOverlaysForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseOverlayListFromJSON:)];
}

- (void)fetchPlayerInventory
{    
    if (currentlyFetchingInventory)
    {
        NSLog(@"Skipping Request: already fetching inventory");
        return;
    }
    
    currentlyFetchingInventory = YES;
	
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"items"
                                                             andMethodName:@"getItemsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseInventoryFromJSON:)];
}

-(void)fetchPlayerQuestList
{
    if (currentlyFetchingQuestList)
    {
        NSLog(@"Skipping Request: already fetching quests");
        return;
    }
    
    currentlyFetchingQuestList = YES;
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"quests"
                                                             andMethodName:@"getQuestsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQuestListFromJSON:)];
}

- (void)fetchOneGameGameList:(int)gameId
{
    if (currentlyFetchingOneGame)
    {
        NSLog(@"Skipping Request: already fetching one game");
        return;
    }
    
    currentlyFetchingOneGame = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].player.playerId],
                          [NSString stringWithFormat:@"%d",1],
                          [NSString stringWithFormat:@"%d",999999999],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].player.location.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",1],//'showGamesInDev' = 1, because if you're specifically seeking out one game, who cares
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getOneGame"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseOneGameGameListFromJSON:)];
}

- (Tab *)parseTabFromDictionary:(NSDictionary *)tabDictionary
{
    Tab *tab = [[Tab alloc] init];
    tab.tabIndex   = [tabDictionary validIntForKey:@"tab_index"];
    tab.tabName    = [tabDictionary validObjectForKey:@"tab"];
    tab.tabDetail1 = [tabDictionary validObjectForKey:@"tab_detail_1"] ? [tabDictionary validIntForKey:@"tab_detail_1"] : 0;
    return tab;
}

-(void)parseGameNoteListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingGameNoteList) return;
    currentlyFetchingGameNoteList = NO;

	NSArray *noteListArray = (NSArray *)jsonResult.data;
    NSMutableDictionary *tempNoteList = [[NSMutableDictionary alloc]init];
    
	NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
        Note *tmpNote = [[Note alloc] initWithDictionary:dict];
        [tempNoteList setObject:tmpNote forKey:[NSNumber numberWithInt:tmpNote.noteId]];
	}
    
	[AppModel sharedAppModel].gameNoteList = tempNoteList;
    NSLog(@"NSNotification: NewNoteListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady"      object:nil]];
    NSLog(@"NSNotification: ReceivedNoteList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedNoteList"      object:nil]];
    //^ This is ridiculous. Each notification is a paraphrasing of the last. <3 Phil
}

-(void)parsePlayerNoteListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingPlayerNoteList) return;
    currentlyFetchingPlayerNoteList = NO;
    
	NSArray *noteListArray = (NSArray *)jsonResult.data;
    	NSMutableDictionary *tempNoteList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Note *tmpNote = [[Note alloc] initWithDictionary:dict];
		[tempNoteList setObject:tmpNote forKey:[NSNumber numberWithInt:tmpNote.noteId]];
	}
    
	[AppModel sharedAppModel].playerNoteList = tempNoteList;
    NSLog(@"NSNotification: ReceivedNoteList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedNoteList" object:nil]];
    NSLog(@"NSNotification: NewNoteListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
}

-(void)parseConversationNodeOptionsFromJSON:(ServiceResult *)jsonResult
{
    NSArray *conversationOptionsArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *conversationNodeOptions = [[NSMutableArray alloc] initWithCapacity:3];
	
	NSEnumerator *conversationOptionsEnumerator = [conversationOptionsArray objectEnumerator];
	NSDictionary *conversationDictionary;
	
	while ((conversationDictionary = [conversationOptionsEnumerator nextObject]))
    {
		int optionNodeId = [conversationDictionary validIntForKey:@"node_id"];
		NSString *text = [conversationDictionary validObjectForKey:@"text"];
        BOOL hasViewed = [conversationDictionary validBoolForKey:@"has_viewed"];
		NodeOption *option = [[NodeOption alloc] initWithText:text andNodeId:optionNodeId andHasViewed:hasViewed];
		[conversationNodeOptions addObject:option];
	}
	
	//return conversationNodeOptions;
    NSLog(@"NSNotification: ConversationNodeOptionsReady");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConversationNodeOptionsReady" object:conversationNodeOptions]];
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
    if (!game.mapType || (![game.mapType isEqualToString:@"STREET"] && ![game.mapType isEqualToString:@"SATELLITE"] && ![game.mapType isEqualToString:@"HYBRID"])) game.mapType = @"STREET";

    NSString *distance = [gameSource validObjectForKey:@"distance"];
    if (distance) game.distanceFromPlayer = [distance doubleValue];
    else game.distanceFromPlayer = 999999999;
    
    NSString *latitude  = [gameSource validObjectForKey:@"latitude"];
    NSString *longitude = [gameSource validObjectForKey:@"longitude"];
    if (latitude && longitude)
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
    game.allowTrading                  = [gameSource validBoolForKey:@"allow_trading"];
    
    NSArray *comments = [gameSource validObjectForKey:@"comments"];
    for (NSDictionary *comment in comments)
    {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        Comment *c = [[Comment alloc] init];
        c.text = [comment validObjectForKey:@"text"];
        c.playerName = [comment validObjectForKey:@"username"];
        NSString *cRating = [comment validObjectForKey:@"rating"];
        if (cRating) c.rating = [cRating intValue];
        [game.comments addObject:c];
    }
    game.offlineMode = [gameSource validBoolForKey:@"offline"];
    
    return game;
}

-(NSMutableArray *)parseGameListFromJSON:(ServiceResult *)jsonResult
{
    NSArray *gameListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
    
    NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];
    NSDictionary *gameDictionary;
    while ((gameDictionary = [gameListEnumerator nextObject]))
        [tempGameList addObject:[self parseGame:(gameDictionary)]];
    
    NSError *error;
    if (![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);

    return tempGameList;
}

-(void)parseOneGameGameListFromJSON:(ServiceResult *)jsonResult
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

-(void)parseNearbyGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingNearbyGamesList) return;
    currentlyFetchingNearbyGamesList = NO;
    
    [AppModel sharedAppModel].nearbyGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewNearbyGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNearbyGameListReady" object:nil]];
}

-(void)parseSearchGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingSearchGamesList) return;
    currentlyFetchingSearchGamesList = NO;
    
    [AppModel sharedAppModel].searchGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewSearchGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewSearchGameListReady" object:nil]];
}

-(void)parsePopularGameListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingPopularGamesList) return;
    currentlyFetchingPopularGamesList = NO;
    
    [AppModel sharedAppModel].popularGameList = [self parseGameListFromJSON:jsonResult];
    NSLog(@"NSNotification: NewPopularGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewPopularGameListReady" object:nil]];
}

-(void)parseRecentGameListFromJSON:(ServiceResult *)jsonResult
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
    if (![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    NSLog(@"NSNotification: NewRecentGameListReady");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewRecentGameListReady" object:nil]];
}

- (void)saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating
{
	NSLog(@"AppModel: Save Comment Requested");
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].player.playerId], [NSString stringWithFormat:@"%d", gameId], [NSString stringWithFormat:@"%d", rating], comment, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName: @"games"
                                                              andMethodName:@"saveComment"
                                                               andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:nil];
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

-(void)parseSingleMediaFromJSON:(ServiceResult *)jsonResult
{
    //Just convert the data into an array and pretend it is a full game list, so same thing as 'parseGameMediaListFromJSON'
    NSArray * data = [[NSArray alloc] initWithObjects:jsonResult.data, nil];
    jsonResult.data = data;
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread
}

-(void)parseGameMediaListFromJSON:(ServiceResult *)jsonResult
{
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1]; //Deal with CoreData on separate thread
}

-(void)startCachingMedia:(ServiceResult *)jsonResult
{
    NSArray *serverMediaArray = (NSArray *)jsonResult.data;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(gameid = 0) OR (gameid = %d)", [AppModel sharedAppModel].currentGame.gameId];
    NSArray *currentlyCachedMediaArray = [[AppModel sharedAppModel].mediaCache mediaForPredicate:predicate];
    NSLog(@"%d total media for %d",[currentlyCachedMediaArray count], [AppModel sharedAppModel].currentGame.gameId);
    
    //Construct cached media map (dictionary with identical key/values of mediaId) to quickly check for existence of media
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc]initWithCapacity:currentlyCachedMediaArray.count];
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
    if (![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    NSLog(@"NSNotification: ReceivedMediaList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedMediaList" object:nil]];
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameItemListFromJSON:(ServiceResult *)jsonResult
{
	NSArray *itemListArray = (NSArray *)jsonResult.data;
    
	NSMutableDictionary *tempItemList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [itemListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Item *tmpItem = [[Item alloc] initWithDictionary:dict];
		[tempItemList setObject:tmpItem forKey:[NSNumber numberWithInt:tmpItem.itemId]];
    }
	
	[AppModel sharedAppModel].gameItemList = tempItemList;
    
    NSLog(@"NSNotification: GamePieceReceived");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameNodeListFromJSON:(ServiceResult *)jsonResult
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

-(void)parseGameTabListFromJSON:(ServiceResult *)jsonResult
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

-(void)parseGameNpcListFromJSON:(ServiceResult *)jsonResult
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

-(void)parseInventoryFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingInventory) return;
    currentlyFetchingInventory = NO;
    
    NSLog(@"NSNotification: ReceivedInventory");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedInventory" object:nil]];
    
	NSMutableArray *tempInventory = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *tempAttributes = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray *inventoryArray = (NSArray *)jsonResult.data;
	NSEnumerator *inventoryEnumerator = [((NSArray *)inventoryArray) objectEnumerator];
	NSDictionary *itemDictionary;
	while ((itemDictionary = [inventoryEnumerator nextObject]))
    {
        Item *item = [[Item alloc] initWithDictionary:itemDictionary];
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

-(void)parseQRCodeObjectFromJSON:(ServiceResult *)jsonResult
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

-(void)parseUpdateServerWithPlayerLocationFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyUpdatingServerWithPlayerLocation) return;
    currentlyUpdatingServerWithPlayerLocation = NO;
}

-(void)parseQuestListFromJSON:(ServiceResult *)jsonResult
{
    if(!currentlyFetchingQuestList) return;
    currentlyFetchingQuestList = NO;
    
    NSLog(@"NSNotification: ReceivedQuestList");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedQuestList" object:nil]];

	NSDictionary *questListsDictionary = (NSDictionary *)jsonResult.data;
	
    //Active Quests
    NSArray *activeQuestDicts = [questListsDictionary validObjectForKey:@"active"];
	NSEnumerator *activeQuestDictsEnumerator = [activeQuestDicts objectEnumerator];
	NSDictionary *activeQuestDict;
    NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
	while ((activeQuestDict = [activeQuestDictsEnumerator nextObject]))
    {
        Quest *quest = [[Quest alloc] init];
        quest.questId                = [activeQuestDict validIntForKey:@"quest_id"];
        quest.mediaId                = [activeQuestDict validIntForKey:@"active_media_id"];
        quest.iconMediaId            = [activeQuestDict validIntForKey:@"active_icon_media_id"];
        quest.sortNum                = [activeQuestDict validIntForKey:@"sort_index"];
        quest.name                   = [activeQuestDict validObjectForKey:@"name"];
        quest.qdescription           = [activeQuestDict validObjectForKey:@"description"];
        quest.fullScreenNotification = [activeQuestDict validBoolForKey:@"full_screen_notify"];
        quest.goFunction             = [activeQuestDict validObjectForKey:@"go_function"];
        
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
        quest.questId                = [completedQuestDict validIntForKey:@"quest_id"];
        quest.mediaId                = [completedQuestDict validIntForKey:@"complete_media_id"];
        quest.iconMediaId            = [completedQuestDict validIntForKey:@"complete_icon_media_id"];
        quest.sortNum                = [completedQuestDict validIntForKey:@"sort_index"];
        quest.fullScreenNotification = [completedQuestDict validBoolForKey:@"full_screen_notify"];
        quest.name                   = [completedQuestDict validStringForKey:@"name"];
        quest.qdescription           = [completedQuestDict validStringForKey:@"text_when_complete"];
        quest.goFunction             = [completedQuestDict validStringForKey:@"go_function"];
        
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
