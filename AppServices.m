//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"
#import "ARISUploader.h"

static const int kDefaultCapacity = 10;
static const BOOL kEmptyBoolValue = NO;
static const int kEmptyIntValue = -1;
static const float kEmptyFloatValue = 0.0;
static const double kEmptyDoubleValue = 0.0;
NSString *const kARISServerServicePackage = @"v1";

BOOL currentlyFetchingLocationList;
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

@interface AppServices()

- (BOOL)      validBoolForKey:  (NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (NSInteger) validIntForKey:   (NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (float)     validFloatForKey: (NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (double)    validDoubleForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (id)        validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;

@end

@implementation AppServices

+ (id)sharedAppServices
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
    currentlyFetchingNearbyGamesList = NO;
    currentlyFetchingSearchGamesList = NO;
    currentlyFetchingPopularGamesList = NO;
    currentlyFetchingRecentGamesList = NO;
    currentlyFetchingInventory = NO;
    currentlyFetchingLocationList = NO;
    currentlyFetchingQuestList = NO;
    currentlyFetchingGameNoteList = NO;
    currentlyFetchingPlayerNoteList = NO;
    currentlyUpdatingServerWithInventoryViewed = NO;
    currentlyUpdatingServerWithMapViewed = NO;
    currentlyUpdatingServerWithPlayerLocation = NO;
    currentlyUpdatingServerWithQuestsViewed = NO;
}

#pragma mark Communication with Server
- (void)login
{
	NSLog(@"AppModel: Login Requested");
	NSArray *arguments = [NSArray arrayWithObjects:[AppModel sharedAppModel].userName, [AppModel sharedAppModel].password, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName: @"players"
                                                              andMethodName:@"getLoginPlayerObject"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLoginResponseFromJSON:)];
}

- (void)registerNewUser:(NSString*)userName password:(NSString*)pass
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email
{
	NSLog(@"AppModel: New User Registration Requested");
	//createPlayer($strNewUserName, $strPassword, $strFirstName, $strLastName, $strEmail)
	NSArray *arguments = [NSArray arrayWithObjects:userName, pass, firstName, lastName, email, nil];
    [AppModel sharedAppModel].userName = userName;
    [AppModel sharedAppModel].password = pass;
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"createPlayer"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseSelfRegistrationResponseFromJSON:)];
}

- (void)createUserAndLoginWithGroup:(NSString *)groupName
{
    NSLog(@"AppModel: Create User And Login Requested");
	NSArray *arguments = [NSArray arrayWithObjects:groupName, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName: @"players"
                                                              andMethodName:@"createPlayerAndGetLoginPlayerObject"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLoginResponseFromJSON:)];
}

-(void) uploadPlayerPicMediaWithFileURL:(NSURL *)fileURL
{
    ARISUploader *uploader = [[ARISUploader alloc]initWithURLToUpload:fileURL gameSpecific:NO delegate:self doneSelector:@selector(playerPicUploadDidfinish: ) errorSelector:@selector(playerPicUploadDidFail:)];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:2];
    [userInfo setValue:kNoteContentTypePhoto forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
	[uploader setUserInfo:userInfo];
	
	NSLog(@"Model: Uploading File. gameID:%d ",[AppModel sharedAppModel].currentGame.gameId);
	
	//ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[[[RootViewController sharedRootViewController] showWaitingIndicator:@"Uploading" displayProgressBar:YES];
	//[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
    
	[uploader upload];
}

-(void) updatePlayer:(int)playerId withName:(NSString *)name andImage:(int)mid
{
    if(playerId != 0){
        NSLog(@"AppModel: Updating Player info: %@ %d", name, mid);
        
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
    else{
        NSLog(@"Tried updating non-existent player! (playerId = 0)");
    }
}

-(void)resetAndEmailNewPassword:(NSString *)email
{
    NSLog(@"Resetting Email: %@",email);
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
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId],[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].showPlayerOnMap], nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"setShowPlayerOnMap"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil];
}

- (void)fetchGameListWithDistanceFilter:(int)distanceInMeters locational:(BOOL)locationalOrNonLocational
{
	NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingNearbyGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingNearbyGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
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
	NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingRecentGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingRecentGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
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
	NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingPopularGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingPopularGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",time],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getPopularGames"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parsePopularGameListFromJSON:)];
}

- (void)fetchGameListBySearch:(NSString *)searchText onPage:(int)page {
    NSLog(@"Searching with Text: %@",searchText);
    
    if (currentlyFetchingSearchGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingSearchGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
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

- (void)updateServerNodeViewed: (int)nodeId fromLocation:(int)locationId {
	NSLog(@"Model: Node %d Viewed, update server", nodeId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId],
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

- (void)updateServerWebPageViewed: (int)webPageId fromLocation:(int)locationId {
	NSLog(@"Model: WebPage %d Viewed, update server", webPageId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
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

- (void)updateServerPanoramicViewed: (int)panoramicId fromLocation:(int)locationId{
	NSLog(@"Model: Panoramic %d Viewed, update server", panoramicId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
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

- (void)updateServerItemViewed: (int)itemId fromLocation:(int)locationId{
	NSLog(@"Model: Item %d Viewed, update server", itemId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
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

- (void)updateServerNpcViewed: (int)npcId fromLocation:(int)locationId {
	NSLog(@"Model: Npc %d Viewed, update server", npcId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
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

- (void)updateServerGameSelected{
	NSLog(@"Model: Game %d Selected, update server", [AppModel sharedAppModel].currentGame.gameId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"updatePlayerLastGame"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

- (void)updateServerMapViewed{
	NSLog(@"Model: Map Viewed, update server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"mapViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

- (void)updateServerQuestsViewed{
	NSLog(@"Model: Quests Viewed, update server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"questsViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

- (void)updateServerInventoryViewed{
	NSLog(@"Model: Inventory Viewed, update server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"inventoryViewed"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

-(void)parseResetAndEmailNewPassword:(JSONResult *)jsonResult{
    if(jsonResult == nil){
        [[RootViewController sharedRootViewController] showAlert:NSLocalizedString(@"ForgotPasswordTitleKey", nil) message:NSLocalizedString(@"ForgotPasswordMessageKey", nil)];
    }
    else{
        [[RootViewController sharedRootViewController] showAlert:NSLocalizedString(@"ForgotEmailSentTitleKey", @"") message:NSLocalizedString(@"ForgotMessageKey", @"")];
    }
}

- (void)startOverGame:(int)gameId
{
	NSLog(@"Model: Start Over");
    NSLog(@"%d", gameId);
        
    [self resetAllGameLists];
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d", gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]
                                      initWithServer:[AppModel sharedAppModel].serverURL
                                      andServiceName:@"players"
                                      andMethodName:@"startOverGameForPlayer"
                                      andArguments:arguments
                                      andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:
     @selector(parseStartOverFromJSON:)];
}

- (void)updateServerPickupItem:(int)itemId fromLocation:(int)locationId qty:(int)qty
{
	NSLog(@"Model: Informing the Server the player picked up item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%d",locationId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"pickupItemFromLocation"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)updateServerDropItemHere:(int)itemId qty:(int)qty
{
	NSLog(@"Model: Informing the Server the player dropped an item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"dropItem"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)dropNote:(int)noteId atCoordinate:(CLLocationCoordinate2D)coordinate
{
	NSLog(@"Model: Informing the Server the player dropped an item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",noteId],
						  [NSString stringWithFormat:@"%f",coordinate.latitude],
						  [NSString stringWithFormat:@"%f",coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"dropNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)updateServerDestroyItem: (int)itemId qty:(int)qty {
	NSLog(@"Model: Informing the Server the player destroyed an item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"destroyItem"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)updateServerInventoryItem:(int)itemId qty:(int)qty
{
    NSLog(@"Model: Enforcing a qty of player inventory item on server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"setItemCountForPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)updateServerAddInventoryItem:(int)itemId addQty:(int)qty
{
    NSLog(@"Model: adds a qty of player inventory item on server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"giveItemToPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)updateServerRemoveInventoryItem:(int)itemId removeQty:(int)qty
{
    NSLog(@"Model: Enforcing a qty of player inventory item on server");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",qty],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"takeItemFromPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

- (void)commitInventoryTrade:(int)gameId fromMe:(int)playerOneId toYou:(int)playerTwoId giving:(NSString *)giftsJSON receiving:(NSString *)receiptsJSON
{
    /*
     * Gifts/Receipts json should be of following format:
     * {"items":[{"item_id":1,"qtyDelta":3},{"item_id":2,"qtyDelta":4}]}
     */
    
    //Call server service
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

-(void)updateCommentWithId:(int)noteId andTitle:(NSString *)title andRefresh:(BOOL)refresh{
    NSLog(@"AppModel: Updating Comment Rating");
	
	//Call server service
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

-(void)likeNote:(int)noteId{
    NSLog(@"Liking Note: %d",noteId);
    NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"likeNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

-(void)unLikeNote:(int)noteId{
    NSLog(@"Unliking Note: %d",noteId);
    
    NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"unlikeNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
}

-(int)addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title
{
    NSLog(@"AppModel: Adding Comment To Note");
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",noteId],
                          title,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addCommentToNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
	
	if (!jsonResult)
    {
		NSLog(@"\tFailed.");
		return 0;
	}
	
	return [(NSDecimalNumber*)jsonResult.data intValue];
}

-(void)setNoteCompleteForNoteId:(int)noteId {
    NSLog(@"AppModel: Setting Note Complete");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",noteId],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"setNoteComplete"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists];
	
	if (!jsonResult) {
		NSLog(@"\tFailed.");
        
	}
	
}

-(int)createNote{
    NSLog(@"AppModel: Creating New Note");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"createNewNote"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists]; //This is a cheat to make sure that the fetch Happens After
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return 0;
	}
	
	return jsonResult.data ? [(NSDecimalNumber*)jsonResult.data intValue] : 0;
}

-(int)createNoteStartIncomplete{
    NSLog(@"AppModel: Creating New Note Start Incomplete");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"createNewNoteStartIncomplete"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
    [self fetchAllPlayerLists]; //This is a cheat to make sure that the fetch Happens After
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return 0;
	}
	
	return jsonResult.data ? [(NSDecimalNumber*)jsonResult.data intValue] : 0;
}

-(void) contentAddedToNoteWithText:(JSONResult *)result
{
    if([self validObjectForKey:@"noteId" inDictionary:result.userInfo])
        [[AppModel sharedAppModel].uploadManager deleteContentFromNoteId:[self validIntForKey:@"noteId" inDictionary:result.userInfo] andFileURL:[self validObjectForKey:@"localURL" inDictionary:result.userInfo]];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
    [self fetchPlayerNoteListAsync];
}

-(void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId andFileURL:(NSURL *)fileURL{
    NSLog(@"AppModel: Adding Text Content To Note: %d",noteId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",noteId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
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

-(void)deleteNoteContentWithContentId:(int)contentId{
    if(contentId != -1){
        NSLog(@"AppModel: Deleting Content From Note with contentId: %d",contentId);
        
        //Call server service
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

-(void)deleteNoteLocationWithNoteId:(int)noteId{
    NSLog(@"AppModel: Deleting Location of Note: %d",noteId);
	
	//Call server service
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
    [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
	
}

-(void)deleteNoteWithNoteId:(int)noteId{
    if(noteId != 0){
        NSLog(@"AppModel: Deleting Note: %d",noteId);
        
        //Call server service
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
    else{
        NSLog(@"Tried deleting note 0 and that's a no-no!");
    }
    
}

-(void)sendNotificationToNoteViewer{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewContentListReady" object:nil]];
    [self fetchPlayerNoteListAsync];
}

-(void)sendNotificationToNotebookViewer{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NoteDeleted" object:nil]];
    [self fetchPlayerNoteListAsync];
}

-(void) uploadContentToNoteWithFileURL:(NSURL *)fileURL name:(NSString *)name noteId:(int) noteId type: (NSString *)type{
    ARISUploader *uploader = [[ARISUploader alloc]initWithURLToUpload:fileURL gameSpecific:YES delegate:self doneSelector:@selector(noteContentUploadDidfinish: ) errorSelector:@selector(uploadNoteContentDidFail:)];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:noteId];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithCapacity:4];
    [userInfo setValue:name forKey:@"title"];
    [userInfo setValue:nId forKey:@"noteId"];
    [userInfo setValue:type forKey: @"type"];
    [userInfo setValue:fileURL forKey:@"url"];
	[uploader setUserInfo:userInfo];
	
	NSLog(@"Model: Uploading File. gameID:%d title:%@ noteId:%d",[AppModel sharedAppModel].currentGame.gameId,name,noteId);
	
	//ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    //[[[RootViewController sharedRootViewController] showWaitingIndicator:@"Uploading" displayProgressBar:YES];
	//[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
    
	[uploader upload];
    
    [self fetchAllPlayerLists];
}

-(void)fetchPlayerNoteListAsync{
    ///if([AppModel sharedAppModel].isGameNoteList)
    [self fetchGameNoteListAsynchronously:YES];
    // else
    [self fetchPlayerNoteListAsynchronously:YES];
}

- (void)noteContentUploadDidfinish:(ARISUploader*)uploader {
	NSLog(@"Model: Upload Note Content Request Finished. Response: %@", [uploader responseString]);
	
        int noteId = [self validObjectForKey:@"noteId" inDictionary:[uploader userInfo]] ? [self validIntForKey:@"noteId" inDictionary:[uploader userInfo]] : 0;
        NSString *title = [self validObjectForKey:@"title" inDictionary:[uploader userInfo]];
        NSString *type = [self validObjectForKey:@"type" inDictionary:[uploader userInfo]];
        NSURL *localUrl = [self validObjectForKey:@"url" inDictionary:[uploader userInfo]];
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
    
	NSLog(@"AppModel: Creating Note Content for Title:%@ File:%@",title,newFileName);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",noteId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  newFileName,
                          type,
                          title,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addContentToNoteFromFileName"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    //[AppModel sharedAppModel].isGameNoteList = NO;
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)];
    [self fetchAllPlayerLists];
}

- (void)uploadNoteContentDidFail:(ARISUploader *)uploader {
    NSError *error = uploader.error;
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	
	[alert show];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:5];
    nId = [self validObjectForKey:@"noteId" inDictionary:[uploader userInfo]];
	//if (description == NULL) description = @"filename";
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
}

- (void)playerPicUploadDidfinish:(ARISUploader*)uploader {
	NSLog(@"Model: Upload Note Content Request Finished. Response: %@", [uploader responseString]);
    
    //Call server service
    
    NSString *newFileName = [uploader responseString];
    
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  newFileName,
                          nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"players"
                                                             andMethodName:@"addPlayerPicFromFilename"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseNewPlayerMediaResponseFromJSON:)];
    [[AppModel sharedAppModel].uploadManager contentFinishedUploading];
}

-(void)parseNewPlayerMediaResponseFromJSON: (JSONResult *)jsonResult{
	NSLog(@"AppModel: parseNewPlayerMediaResponseFromJSON");
	
	[[RootViewController sharedRootViewController] removeWaitingIndicator];
    
        if (jsonResult.data && [self validObjectForKey:@"media_id" inDictionary:((NSDictionary *)jsonResult.data)])
    {
        [AppModel sharedAppModel].playerMediaId = [self validIntForKey:@"media_id" inDictionary:((NSDictionary*)jsonResult.data)];
        [[AppModel sharedAppModel] saveUserDefaults];
    }
}


- (void)playerPicUploadDidFail:(ARISUploader *)uploader {
    NSError *error = uploader.error;
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	
	[alert show];
    
    [[AppModel sharedAppModel].uploadManager contentFailedUploading];
}

-(void)updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList{
    NSLog(@"Model: Updating Note with ID: %d andTitle: %@ andPublicToMap:%d andPublicToList: %d",noteId,title,publicToMap,publicToList);
	
	//Call server service
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
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

- (void)updateNoteContent:(int)contentId title:(NSString *)text;
{
    NSLog(@"Model: Updating Note Content Title");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",contentId],
						  text,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateContentTitle"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

-(void)updateNoteContent:(int)contentId text:(NSString *)text{
    NSLog(@"Model: Updating Note Text Content");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",contentId],
						  text,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"updateContent"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After
    
}

- (void)uploadImageForMatching:(NSURL *)fileURL{
    
    ARISUploader *uploader = [[ARISUploader alloc]initWithURLToUpload:fileURL gameSpecific:YES delegate:self doneSelector:@selector(uploadImageForMatchingDidFinish: ) errorSelector:@selector(uploadImageForMatchingDidFail:)];
    
    NSLog(@"Model: Uploading File. gameID:%d",[AppModel sharedAppModel].currentGame.gameId);
    
    [AppModel sharedAppModel].fileToDeleteURL = fileURL;
    
    [[RootViewController sharedRootViewController] showWaitingIndicator:@"Uploading" displayProgressBar:YES];
    //[uplaoder setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
    [uploader upload];
    
}

- (void)uploadImageForMatchingDidFinish:(ARISUploader *)uploader
{
	[[RootViewController sharedRootViewController] removeWaitingIndicator];
    
    [[RootViewController sharedRootViewController] showWaitingIndicator:@"Decoding Image" displayProgressBar:NO];
	
	NSString *response = [uploader responseString];
    
	NSLog(@"Model: uploadImageForMatchingRequestFinished: Upload Media Request Finished. Response: %@", response);
    
	NSString *newFileName = [uploader responseString];
    
	NSLog(@"AppModel: uploadImageForMatchingRequestFinished: Trying to Match:%@",newFileName);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  newFileName,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"qrcodes"
                                                             andMethodName:@"getBestImageMatchNearbyObjectForPlayer"
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQRCodeObjectFromJSON:)];
    
    
    
    // delete temporary image file
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr removeItemAtURL:[AppModel sharedAppModel].fileToDeleteURL error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
}

- (void)uploadImageForMatchingDidFail:(ARISUploader *)uploader
{
	[[RootViewController sharedRootViewController] removeWaitingIndicator];
	NSError *error = [uploader error];
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"UploadFailedKey", @"") message: NSLocalizedString(@"AppServicesUploadFailedMessageKey", @"") delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
    
    // delete temporary image file
    NSError *error2;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr removeItemAtURL:[AppModel sharedAppModel].fileToDeleteURL error:&error2] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);;
	
	[alert show];
}

- (void)updateServerWithPlayerLocation {
	NSLog(@"Model: updating player position on server and determining nearby Locations");
	
	if (![AppModel sharedAppModel].loggedIn) {
		NSLog(@"Model: Player Not logged in yet, skip the location update");
		return;
	}
	
	if (currentlyUpdatingServerWithPlayerLocation) {
        NSLog(@"AppModel: Currently Updating server with player location, skipping this update");
        return;
    }
    
    currentlyUpdatingServerWithPlayerLocation = YES;
    
	//Update the server with the new Player Location
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName:@"players"
                                                              andMethodName:@"updatePlayerLocation"
                                                               andArguments:arguments
                                                                andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseUpdateServerWithPlayerLocationFromJSON:)];
	
}

#pragma mark Sync Fetch selectors
- (id) fetchFromService:(NSString *)aService usingMethod:(NSString *)aMethod
			   withArgs:(NSArray *)arguments usingParser:(SEL)aSelector
{
	NSLog(@"JSON://%@/%@/%@", aService, aMethod, arguments);
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:aService
                                                             andMethodName:aMethod
                                                              andArguments:arguments
                                                               andUserInfo:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest];
	
	
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return nil;
	}
	
	return [self performSelector:aSelector withObject:jsonResult.data];
}

-(Item *)fetchItem:(int)itemId{
	NSLog(@"Model: Fetch Requested for Item %d", itemId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",itemId],
						  nil];
    
	return [self fetchFromService:@"items" usingMethod:@"getItem" withArgs:arguments
					  usingParser:@selector(parseItemFromDictionary:)];
}

-(Node *)fetchNode:(int)nodeId{
	NSLog(@"Model: Fetch Requested for Node %d", nodeId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",nodeId],
						  nil];
	
	return [self fetchFromService:@"nodes" usingMethod:@"getNode" withArgs:arguments
					  usingParser:@selector(parseNodeFromDictionary:)];
}

-(Note *)fetchNote:(int)noteId{
    NSLog(@"AppModel: Fetching Note:%d",noteId);
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId], nil];
	
    return [self fetchFromService:@"notes" usingMethod:@"getNoteById" withArgs:arguments
					  usingParser:@selector(parseNoteFromDictionary:)];
    
}

-(Npc *)fetchNpc:(int)npcId{
	NSLog(@"Model: Fetch Requested for Npc %d", npcId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",npcId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	return [self fetchFromService:@"npcs" usingMethod:@"getNpcWithConversationsForPlayer"
						 withArgs:arguments usingParser:@selector(parseNpcFromDictionary:)];
}

#pragma mark ASync Fetch selectors

- (void)fetchAllGameLists
{
    [self fetchGameItemListAsynchronously:     YES];
    [self fetchGameNpcListAsynchronously:      YES];
    [self fetchGameNodeListAsynchronously:     YES];
    [self fetchGameMediaListAsynchronously:    YES];
    [self fetchGamePanoramicListAsynchronously:YES];
    [self fetchGameWebpageListAsynchronously:  YES];
    [self fetchGameOverlayListAsynchronously:  YES];
    
    [self fetchGameNoteListAsynchronously:NO];
    [self fetchPlayerNoteListAsynchronously:YES];
}

- (void)resetAllGameLists {
	NSLog(@"AppModel: resetAllGameLists");
    
	//Clear them out
	[[AppModel sharedAppModel].gameItemList removeAllObjects];
	[[AppModel sharedAppModel].gameNodeList removeAllObjects];
    [[AppModel sharedAppModel].gameNpcList removeAllObjects];
    [[AppModel sharedAppModel].gameMediaList removeAllObjects];
    [[AppModel sharedAppModel].gameWebPageList removeAllObjects];
    [[AppModel sharedAppModel].gamePanoramicList removeAllObjects];
    [[AppModel sharedAppModel].playerNoteList removeAllObjects];
    [[AppModel sharedAppModel].gameNoteList removeAllObjects];
}

- (void)fetchGameOverlayListAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSLog(@"AppModel: Fetching Map Overlay List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"overlays"
                                                             andMethodName:@"getCurrentOverlaysForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseOverlayListFromJSON:)];
	}
    else [self parseOverlayListFromJSON: [jsonConnection performSynchronousRequest]];
}

-(void)parseOverlayListFromJSON: (JSONResult *)jsonResult{
    //   currentlyFetchingGamesList = NO; Is there a reason for this?
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedOverlayList" object:nil]];
    
    if ([jsonResult.hash isEqualToString:[[AppModel sharedAppModel] overlayListHash]] && [AppModel sharedAppModel].overlayIsVisible ==true)
    {
		NSLog(@"AppModel: Hash is same as last overlay list update, continue");
        
        return;
	}
	
	//Save this hash for later comparisions
    [AppModel sharedAppModel].overlayIsVisible = false;
	[AppModel sharedAppModel].overlayListHash = [jsonResult.hash copy];
    
    
    NSArray *overlayListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempOverlayList = [[NSMutableArray alloc] init];
    Overlay *tempOverlay = [[Overlay alloc] init];
    
    NSEnumerator *overlayListEnumerator = [overlayListArray objectEnumerator];
    NSDictionary *overlayDictionary;
    // step through results and create overlays
    int currentOverlayID = -1;
    int overlaysIndex = 0;
    while (overlayDictionary = [overlayListEnumerator nextObject]) {
        // if new overlay in database
        if (currentOverlayID != [self validIntForKey:@"overlay_id" inDictionary:overlayDictionary]) {
            // add previous overlay to overlay list
            [tempOverlayList addObject:tempOverlay];
            
            // create new overlay
            tempOverlay.index = overlaysIndex;
            tempOverlay.overlayId = [self validIntForKey:@"overlay_id" inDictionary:overlayDictionary];;
            tempOverlay.num_tiles = [self validIntForKey:@"num_tiles" inDictionary:overlayDictionary];;
            //tempOverlay.alpha = [[self validObjectForKey:@"alpha" inDictionary:overlayDictionary] floatValue] ;
            tempOverlay.alpha = 1.0;
            [tempOverlay.tileFileName addObject:[self validObjectForKey:@"file_path" inDictionary:overlayDictionary]];
            [tempOverlay.tileMediaID addObject:[self validObjectForKey:@"media_id" inDictionary:overlayDictionary]];
            [tempOverlay.tileX addObject:[self validObjectForKey:@"x" inDictionary:overlayDictionary]];
            [tempOverlay.tileY addObject:[self validObjectForKey:@"y" inDictionary:overlayDictionary]];
            [tempOverlay.tileZ addObject:[self validObjectForKey:@"zoom" inDictionary:overlayDictionary]];
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[self validIntForKey:@"media_id" inDictionary:overlayDictionary]];
            [tempOverlay.tileImage addObject:media];
            currentOverlayID = tempOverlay.overlayId;
            overlaysIndex += 1;
        }
        else
        {
            // add tiles to existing overlay
            [tempOverlay.tileFileName addObject:[self validObjectForKey:@"file_path" inDictionary:overlayDictionary]];
            [tempOverlay.tileMediaID addObject:[self validObjectForKey:@"media_id" inDictionary:overlayDictionary]];
            [tempOverlay.tileX addObject:[self validObjectForKey:@"x" inDictionary:overlayDictionary]];
            [tempOverlay.tileY addObject:[self validObjectForKey:@"y" inDictionary:overlayDictionary]];
            [tempOverlay.tileZ addObject:[self validObjectForKey:@"zoom" inDictionary:overlayDictionary]];
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:[self validIntForKey:@"media_id" inDictionary:overlayDictionary]];
            [tempOverlay.tileImage addObject:media];
            currentOverlayID = tempOverlay.overlayId;
        }
    }
    
    [AppModel sharedAppModel].overlayList = tempOverlayList;
    
    for (int iOverlay=0; iOverlay < [[AppModel sharedAppModel].overlayList count]; iOverlay++) {
        Overlay *currentOverlay = [[AppModel sharedAppModel].overlayList objectAtIndex:iOverlay];
        int iTiles = [currentOverlay.tileX count];
        for (int iTile = 0; iTile < iTiles; iTile++) {
            
            // step through tile list and update media with images
            AsyncMediaImageView *aImageView = [[AsyncMediaImageView alloc] init ];
            [aImageView loadImageFromMedia:[currentOverlay.tileImage objectAtIndex:iTile]];
            
        }
    }
    
    
    NSError *error;
    if (![[AppModel sharedAppModel].mediaCache.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSLog(@"AppModel: parsOverlayListFromJSON Complete, sending notification");
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewOverlayListReady" object:nil]];
}

- (void)fetchAllPlayerLists{
	[self fetchPlayerLocationList];
	[self fetchPlayerQuestList];
	[self fetchPlayerInventory];
    [self fetchPlayerOverlayList];
}

- (void)resetAllPlayerLists
{
	NSLog(@"AppModel: resetAllPlayerLists");
    
	//Clear the Hashes
    [AppModel sharedAppModel].playerNoteListHash = @"";
    [AppModel sharedAppModel].gameNoteListHash = @"";
    [AppModel sharedAppModel].overlayListHash = @"";
    
	//Clear them out
	[AppModel sharedAppModel].nearbyLocationsList = [[NSMutableArray alloc] initWithCapacity:0];

	[[AppModel sharedAppModel].currentGame.inventoryModel  clearData];
	[[AppModel sharedAppModel].currentGame.attributesModel clearData];
	[[AppModel sharedAppModel].currentGame.questsModel     clearData];
	[[AppModel sharedAppModel].currentGame.locationsModel  clearData];
    
    [[AppModel sharedAppModel].overlayList removeAllObjects];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLocationListReady"       object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewQuestListReady"          object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewInventoryReady"          object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedNearbyLocationList" object:nil]];
}

-(void)fetchTabBarItemsForGame:(int)gameId {
    NSLog(@"Fetching TabBar Items for game: %d",gameId);
    NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",gameId],
						  nil];
    
    JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getTabBarItemsForGame"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTabListFromJSON:)];
}

-(void)fetchQRCode:(NSString*)code{
	NSLog(@"Model: Fetch Requested for QRCode Code: %@", code);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%@",code],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	/*
     return [self fetchFromService:@"qrcodes" usingMethod:@"getQRCodeObjectForPlayer"
     withArgs:arguments usingParser:@selector(parseQRCodeObjectFromDictionary:)];
     */
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"qrcodes"
                                                             andMethodName:@"getQRCodeNearbyObjectForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQRCodeObjectFromJSON:)];
}

-(void)fetchNpcConversations:(int)npcId afterViewingNode:(int)nodeId{
	NSLog(@"Model: Fetch Requested for Npc %d Conversations after Viewing node %d", npcId, nodeId);
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",npcId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",nodeId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"npcs"
                                                             andMethodName:@"getNpcConversationsForPlayerAfterViewingNode"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseConversationNodeOptionsFromJSON:)];
}

- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Npc List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"npcs"
                                                             andMethodName:@"getNpcs"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNpcListFromJSON:)];
	}
	else [self parseGameNpcListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGameNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Game Note List");
    
    /*if (currentlyFetchingGameNoteList) {
     NSLog(@"AppModel: Already fetching location list, skipping");
     return;
     }
     
     currentlyFetchingGameNoteList = YES;*/
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForGame"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNoteListFromJSON:)];
	}
	else [self parseGameNoteListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchPlayerNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Player Note List");
    
	/*if (currentlyFetchingPlayerNoteList) {
     NSLog(@"AppModel: Already fetching location list, skipping");
     return;
     }
     
     currentlyFetchingPlayerNoteList = YES;*/
    
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parsePlayerNoteListFromJSON:)];
	}
	else [self parsePlayerNoteListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGameWebpageListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Webpage List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"webpages"
                                                             andMethodName:@"getWebPages"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameWebPageListFromJSON:)];
	}
	else [self parseGameWebPageListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void) fetchMedia:(int)mediaId
{
    NSLog(@"AppModel: Fetching Individual media: %d",mediaId);
    
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

- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Media List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"media"
                                                             andMethodName:@"getMedia"
                                                              andArguments:arguments andUserInfo:nil];
	
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameMediaListFromJSON:)];
	}
	else [self parseGameMediaListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Panoramic List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"augbubbles"
                                                             andMethodName:@"getAugBubbles"
                                                              andArguments:arguments andUserInfo:nil];
	
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGamePanoramicListFromJSON:)];
	}
	else [self parseGamePanoramicListFromJSON: [jsonConnection performSynchronousRequest]];
}


- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Item List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"items"
                                                             andMethodName:@"getItems"
                                                              andArguments:arguments andUserInfo:nil];
	if (YesForAsyncOrNoForSync) {
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameItemListFromJSON:)];
	}
	else [self parseGameItemListFromJSON: [jsonConnection performSynchronousRequest]];
	
}



- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync  {
	NSLog(@"AppModel: Fetching Node List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"nodes"
                                                             andMethodName:@"getNodes"
                                                              andArguments:arguments andUserInfo:nil];
    
	if(YesForAsyncOrNoForSync)
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNodeListFromJSON:)];    
	else
    {
        JSONResult *result = [jsonConnection performSynchronousRequest];
        [self parseGameNodeListFromJSON: result];
    }
}

- (void)fetchGameNoteTagsAsynchronously:(BOOL)YesForAsyncOrNoForSync
{
	NSLog(@"AppModel: Fetching TAG List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getAllTagsInGame"
                                                              andArguments:arguments andUserInfo:nil];
    
    if(YesForAsyncOrNoForSync)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTagsListFromJSON:)];    
	else
    {
        JSONResult *result = [jsonConnection performSynchronousRequest];
        [self parseGameTagsListFromJSON: result];
    }
}

-(void)parseGameTagsListFromJSON:(JSONResult *)jsonResult
{
    NSLog(@"AppModel: parseGameTagListFromJSON Beginning");
    
    NSArray *gameTagsArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *tempTagsList = [[NSMutableArray alloc] initWithCapacity:10];
	
	NSEnumerator *gameTagEnumerator = [gameTagsArray objectEnumerator];
	NSDictionary *tagDictionary;
	while ((tagDictionary = [gameTagEnumerator nextObject]))
    {
        Tag *t = [[Tag alloc]init];
        t.tagName = [self validObjectForKey:@"tag" inDictionary:tagDictionary];
        t.playerCreated = [self validBoolForKey:@"player_created" inDictionary:tagDictionary];
        t.tagId = [self validIntForKey:@"tag_id" inDictionary:tagDictionary];
		[tempTagsList addObject:t];
	}
	[AppModel sharedAppModel].gameTagList = tempTagsList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
}

-(void)addTagToNote:(int)noteId tagName:(NSString *)tag
{
    NSLog(@"AppModel: Adding Tag to note");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],tag, nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addTagToNote"
                                                              andArguments:arguments andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil];
}

-(void)deleteTagFromNote:(int)noteId tagId:(int)tagId{
    NSLog(@"AppModel: Deleting tag from note");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",tagId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"notes"
                                                             andMethodName:@"deleteTagFromNote"
                                                              andArguments:arguments andUserInfo:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil];
    
}

- (void)fetchPlayerLocationList
{
	NSLog(@"AppModel: Fetching Locations from Server");
	
	if (![AppModel sharedAppModel].loggedIn)
    {
		NSLog(@"AppModel: Player Not logged in yet, skip the location fetch");
		return;
	}
    
    if (currentlyFetchingLocationList || [AppModel sharedAppModel].currentlyInteractingWithObject)
    {
        NSLog(@"AppModel: Already fetching location list, skipping");
        return;
    }
    
    currentlyFetchingLocationList = YES;
    
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"locations"
                                                             andMethodName:@"getLocationsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLocationListFromJSON:)];
}

- (void)fetchPlayerOverlayList
{
	NSLog(@"AppModel: Fetching Map Overlay List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"overlays"
                                                             andMethodName:@"getCurrentOverlaysForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseOverlayListFromJSON:)];
}

- (void)fetchPlayerInventory {
	NSLog(@"Model: fetchInventory");
    
    if (currentlyFetchingInventory) {
        NSLog(@"AppModel: Already fetching inventory, skipping");
        return;
    }
    
    currentlyFetchingInventory = YES;
	
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"items"
                                                             andMethodName:@"getItemsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseInventoryFromJSON:)];
	
}

-(void)fetchPlayerQuestList {
	NSLog(@"Model: Fetch Requested for Quests");
    
    if (currentlyFetchingQuestList) {
        NSLog(@"AppModel: Already fetching quest list, skipping");
        return;
    }
    
    currentlyFetchingQuestList = YES;
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"quests"
                                                             andMethodName:@"getQuestsForPlayer"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQuestListFromJSON:)];
	
}

- (void)fetchOneGameGameList:(int)gameId
{
    NSLog(@"AppModel: Fetch Requested for a single game (as Game List).");
    //[self fetchTabBarItemsForGame:gameId];//Make sure to get the tabs as well
    
    if (currentlyFetchingOneGame)
    {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingOneGame = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%d",gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",1],
                          [NSString stringWithFormat:@"%d",999999999],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",1],//'showGamesInDev' = 1, because if you're specifically seeking out one game, who cares
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL
                                                            andServiceName:@"games"
                                                             andMethodName:@"getOneGame"
                                                              andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseOneGameGameListFromJSON:)];
}

#pragma mark Parsers
- (BOOL) validBoolForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(boolValue)] ? [theObject boolValue] : kEmptyBoolValue;
}

- (NSInteger) validIntForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(intValue)] ? [theObject intValue] : kEmptyIntValue;
}

- (float) validFloatForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(floatValue)] ? [theObject floatValue] : kEmptyFloatValue;
}

- (double) validDoubleForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(doubleValue)] ? [theObject doubleValue] : kEmptyDoubleValue;
}

- (id) validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return (theObject == [NSNull null]) ? nil : theObject;
}

-(Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary{
    Item *item = [[Item alloc] init];
    item.itemId      = [self validIntForKey:@"item_id"              inDictionary:itemDictionary];
    item.mediaId     = [self validIntForKey:@"media_id"             inDictionary:itemDictionary];
    item.iconMediaId = [self validIntForKey:@"icon_media_id"        inDictionary:itemDictionary];
    item.maxQty      = [self validIntForKey:@"max_qty_in_inventory" inDictionary:itemDictionary];
    item.weight      = [self validIntForKey:@"weight"               inDictionary:itemDictionary];
    item.creatorId   = [self validIntForKey:@"creator_player_id"    inDictionary:itemDictionary];
    item.url         = [self validObjectForKey:@"url"         inDictionary:itemDictionary];
    item.type        = [self validObjectForKey:@"type"        inDictionary:itemDictionary];
    item.name        = [self validObjectForKey:@"name"        inDictionary:itemDictionary];
    item.description = [self validObjectForKey:@"description" inDictionary:itemDictionary];
    item.dropable    = [self validBoolForKey:@"dropable"     inDictionary:itemDictionary];
    item.destroyable = [self validBoolForKey:@"destroyable"  inDictionary:itemDictionary];
    item.isAttribute = [self validBoolForKey:@"is_attribute" inDictionary:itemDictionary];
    item.isTradeable = [self validBoolForKey:@"tradeable"    inDictionary:itemDictionary];
	
	return item;
}
-(Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary{
	//Build the node
	Node *node = [[Node alloc] init];
	node.nodeId          = [self validIntForKey:@"node_id"                          inDictionary:nodeDictionary];
        node.mediaId         = [self validIntForKey:@"media_id"                         inDictionary:nodeDictionary];
	node.iconMediaId     = [self validIntForKey:@"icon_media_id"                    inDictionary:nodeDictionary];
	node.nodeIfCorrect   = [self validIntForKey:@"require_answer_correct_node_id"   inDictionary:nodeDictionary];
	node.nodeIfIncorrect = [self validIntForKey:@"require_answer_incorrect_node_id" inDictionary:nodeDictionary];
	node.name            = [self validObjectForKey:@"title"                         inDictionary:nodeDictionary];
	node.text            = [self validObjectForKey:@"text"                          inDictionary:nodeDictionary];
	node.answerString    = [self validObjectForKey:@"require_answer_string"         inDictionary:nodeDictionary];
 
	
	//Add options here
	int optionNodeId;
	NSString *text;
	NodeOption *option;
	
	if ([self validObjectForKey:@"opt1_node_id" inDictionary:nodeDictionary] && [self validIntForKey:@"opt1_node_id" inDictionary:nodeDictionary] > 0)
    {
		optionNodeId= [self validIntForKey:@"opt1_node_id" inDictionary:nodeDictionary];
		text = [self validObjectForKey:@"opt1_text" inDictionary:nodeDictionary];
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId andHasViewed:NO];
		[node addOption:option];
	}
	if ([self validObjectForKey:@"opt2_node_id" inDictionary:nodeDictionary] && [self validIntForKey:@"opt2_node_id" inDictionary:nodeDictionary] > 0)
    {
		optionNodeId = [self validIntForKey:@"opt2_node_id" inDictionary:nodeDictionary];
		text = [self validObjectForKey:@"opt2_text" inDictionary:nodeDictionary];
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId andHasViewed:NO];
		[node addOption:option];
	}
	if ([self validObjectForKey:@"opt3_node_id" inDictionary:nodeDictionary] && [self validIntForKey:@"opt3_node_id" inDictionary:nodeDictionary] > 0)
    {
		optionNodeId = [self validIntForKey:@"opt3_node_id" inDictionary:nodeDictionary];
		text = [self validObjectForKey:@"opt3_text" inDictionary:nodeDictionary];
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId andHasViewed:NO];
		[node addOption:option];
	}
	
	
	return node;
}
-(Note *)parseNoteFromDictionary: (NSDictionary *)noteDictionary {
	Note *aNote = [[Note alloc] init];
    aNote.dropped       = [self validBoolForKey:@"dropped"            inDictionary:noteDictionary];
    aNote.showOnMap     = [self validBoolForKey:@"public_to_map"      inDictionary:noteDictionary];
    aNote.showOnList    = [self validBoolForKey:@"public_to_notebook" inDictionary:noteDictionary];
    aNote.userLiked     = [self validBoolForKey:@"player_liked"       inDictionary:noteDictionary];
    aNote.noteId        = [self validIntForKey:@"note_id"        inDictionary:noteDictionary];
    aNote.parentNoteId  = [self validIntForKey:@"parent_note_id" inDictionary:noteDictionary];
    aNote.parentRating  = [self validIntForKey:@"parent_rating"  inDictionary:noteDictionary];
    aNote.numRatings    = [self validIntForKey:@"likes"          inDictionary:noteDictionary];
    aNote.creatorId     = [self validIntForKey:@"owner_id"       inDictionary:noteDictionary];
    aNote.latitude      = [self validDoubleForKey:@"lat" inDictionary:noteDictionary];
    aNote.longitude     = [self validDoubleForKey:@"lon" inDictionary:noteDictionary];
    aNote.username      = [self validObjectForKey:@"username" inDictionary:noteDictionary];
    aNote.title         = [self validObjectForKey:@"title"    inDictionary:noteDictionary];
    aNote.text          = [self validObjectForKey:@"text"     inDictionary:noteDictionary];
    
    NSArray *contents = [self validObjectForKey:@"contents" inDictionary:noteDictionary];
    for (NSDictionary *content in contents)
    {
        NoteContent *c = [[NoteContent alloc] init];
        c.text = [self validObjectForKey:@"text" inDictionary:content];
        c.title = [self validObjectForKey:@"title" inDictionary:content];
        c.contentId = [self validIntForKey:@"content_id" inDictionary:content];
        c.mediaId = [self validIntForKey:@"media_id" inDictionary:content];
        c.noteId = [self validIntForKey:@"note_id" inDictionary:content];
        c.sortIndex =[self validIntForKey:@"sort_index" inDictionary:content];
        c.type = [self validObjectForKey:@"type" inDictionary:content];
        int returnCode = [self validIntForKey:@"returnCode" inDictionary:[self validObjectForKey:@"media" inDictionary:content]];
        NSDictionary *m = [self validObjectForKey:@"data" inDictionary:[self validObjectForKey:@"media" inDictionary:content]];
        if(returnCode == 0 && m)
        {
            Media *media = [[AppModel sharedAppModel].mediaCache mediaForMediaId:c.mediaId];
            NSString *fileName = [self validObjectForKey:@"file_path" inDictionary:m];
            if(fileName == nil) fileName = [self validObjectForKey:@"file_name" inDictionary:m];
            NSString *urlPath = [self validObjectForKey:@"url_path" inDictionary:m];
            NSString *fullUrl = [NSString stringWithFormat:@"%@%@", urlPath, fileName];
            media.url = fullUrl;
            media.type = [self validObjectForKey:@"type" inDictionary:m];
        }
        
        [aNote.contents addObject:c];
    }
    
    NSArray *tags = [self validObjectForKey:@"tags" inDictionary:noteDictionary];
    for (NSDictionary *tagOb in tags) 
    {
        Tag *tag = [[Tag alloc] init];
        tag.tagName = [self validObjectForKey:@"tag" inDictionary:tagOb];
        tag.playerCreated = [self validBoolForKey:@"player_created" inDictionary:tagOb];
        tag.tagId = [self validIntForKey:@"tag_id" inDictionary:tagOb];
        [aNote.tags addObject:tag];
    }
    NSArray *comments = [self validObjectForKey:@"comments" inDictionary:noteDictionary];
    NSEnumerator *enumerator = [((NSArray *)comments) objectEnumerator];
	NSDictionary *dict;
    while ((dict = [enumerator nextObject])) {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        //TODO: Create a Comments object
        Note *c = [self parseNoteFromDictionary:dict];
        [aNote.comments addObject:c];
    }
    
	NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"noteId"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    aNote.comments = [[aNote.comments sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
	return aNote;
}

-(Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary {
	Npc *npc = [[Npc alloc] init];
	npc.npcId = [self validIntForKey:@"npc_id" inDictionary:npcDictionary];
	npc.name = [self validObjectForKey:@"name" inDictionary:npcDictionary];
	npc.greeting = [self validObjectForKey:@"text" inDictionary:npcDictionary];
	
	npc.closing = [self validObjectForKey:@"closing" inDictionary:npcDictionary];
	if (!npc.closing) npc.closing = @"";
    
	npc.description = [self validObjectForKey:@"description" inDictionary:npcDictionary];
	npc.mediaId = [self validIntForKey:@"media_id" inDictionary:npcDictionary];
	npc.iconMediaId = [self validIntForKey:@"icon_media_id" inDictionary:npcDictionary];
    
	return npc;
}

- (Tab *)parseTabFromDictionary:(NSDictionary *)tabDictionary{
    Tab *tab = [[Tab alloc] init];
    tab.tabName = [self validObjectForKey:@"tab" inDictionary:tabDictionary];
    tab.tabIndex = [self validIntForKey:@"tab_index" inDictionary:tabDictionary];
    tab.tabDetail1 = [self validObjectForKey:@"tab_detail_1" inDictionary:tabDictionary] ? [self validIntForKey:@"tab_detail_1" inDictionary:tabDictionary] : 0;
    return tab;
}

-(WebPage *)parseWebPageFromDictionary: (NSDictionary *)webPageDictionary {
	WebPage *webPage = [[WebPage alloc] init];
	webPage.webPageId = [self validIntForKey:@"web_page_id" inDictionary:webPageDictionary];
	webPage.name = [self validObjectForKey:@"name" inDictionary:webPageDictionary];
	webPage.url = [self validObjectForKey:@"url" inDictionary:webPageDictionary];
	webPage.iconMediaId = [self validIntForKey:@"icon_media_id" inDictionary:webPageDictionary];
    
	return webPage;
}

-(Panoramic *)parsePanoramicFromDictionary: (NSDictionary *)panoramicDictionary {
	Panoramic *pan = [[Panoramic alloc] init];
    pan.panoramicId  = [self validIntForKey:@"aug_bubble_id" inDictionary:panoramicDictionary];
    pan.name = [self validObjectForKey:@"name" inDictionary:panoramicDictionary];
	pan.description = [self validObjectForKey:@"description" inDictionary:panoramicDictionary];
    pan.alignMediaId = [self validIntForKey:@"alignment_media_id" inDictionary:panoramicDictionary];
    pan.iconMediaId = [self validIntForKey:@"icon_media_id" inDictionary:panoramicDictionary];
    
    //parse out the active quests into quest objects
	NSMutableArray *media = [[NSMutableArray alloc] init];
        NSArray *incomingPanMediaArray = [self validObjectForKey:@"media" inDictionary:panoramicDictionary];
	NSEnumerator *incomingPanMediaEnumerator = [incomingPanMediaArray objectEnumerator];
    NSDictionary* currentPanMediaDictionary;
	while (currentPanMediaDictionary = (NSDictionary*)[incomingPanMediaEnumerator nextObject]) {
        PanoramicMedia *pm = [[PanoramicMedia alloc]init];
        pm.text = [self validObjectForKey:@"text" inDictionary:currentPanMediaDictionary];
        if ([self validObjectForKey:@"media_id" inDictionary:currentPanMediaDictionary] && [self validIntForKey:@"media_id" inDictionary:currentPanMediaDictionary] > 0)
            pm.mediaId = [self validIntForKey:@"media_id" inDictionary:currentPanMediaDictionary];
		[media addObject:pm];
	}
    
    pan.media = [NSArray arrayWithArray: media];
    
	return pan;
}

-(void)parseGameNoteListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"Parsing Game Note List");
    
    if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].gameNoteListHash]) {
		NSLog(@"AppModel: Hash is same as last game note list update, continue");
		//return;
	}
	
	//Save this hash for later comparisions
	[AppModel sharedAppModel].gameNoteListHash = jsonResult.hash;
    
	NSArray *noteListArray = (NSArray *)jsonResult.data;
    NSMutableDictionary *tempNoteList = [[NSMutableDictionary alloc]init];
    
	NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
        Note *tmpNote = [self parseNoteFromDictionary:dict];
        [tempNoteList setObject:tmpNote forKey:[NSNumber numberWithInt:tmpNote.noteId]];
	}
    
	[AppModel sharedAppModel].gameNoteList = tempNoteList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GameNoteListRefreshed" object:nil]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedNoteList" object:nil]];
    //^ This is ridiculous. Each notification is a paraphrasing of the last. <3 Phil
    NSLog(@"DONE Parsing Game Note List");
    
    currentlyFetchingGameNoteList = NO;
}

-(void)parsePlayerNoteListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"Parsing Player Note List");
    if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].playerNoteListHash]) {
		NSLog(@"AppModel: Hash is same as last player note list update, continue");
		//return;
	}
	
	//Save this hash for later comparisions
	[AppModel sharedAppModel].playerNoteListHash = [jsonResult.hash copy];
    
	NSArray *noteListArray = (NSArray *)jsonResult.data;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedNoteList" object:nil]];
	NSMutableDictionary *tempNoteList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Note *tmpNote = [self parseNoteFromDictionary:dict];
		
		[tempNoteList setObject:tmpNote forKey:[NSNumber numberWithInt:tmpNote.noteId]];
	}
    
    
	[AppModel sharedAppModel].playerNoteList = tempNoteList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
    NSLog(@"DONE Parsing Player Note List");
    currentlyFetchingPlayerNoteList = NO;
}

-(void)parseConversationNodeOptionsFromJSON:(JSONResult *)jsonResult
{
    [self fetchPlayerInventory];
    [self fetchPlayerQuestList];
    
    NSArray *conversationOptionsArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *conversationNodeOptions = [[NSMutableArray alloc] initWithCapacity:3];
	
	NSEnumerator *conversationOptionsEnumerator = [conversationOptionsArray objectEnumerator];
	NSDictionary *conversationDictionary;
	
	while ((conversationDictionary = [conversationOptionsEnumerator nextObject])) {
		//Make the Node Option and add it to the Npc
		int optionNodeId = [self validIntForKey:@"node_id" inDictionary:conversationDictionary];
		NSString *text = [self validObjectForKey:@"text" inDictionary:conversationDictionary];
        BOOL hasViewed = [self validBoolForKey:@"has_viewed" inDictionary:conversationDictionary];
		NodeOption *option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId andHasViewed:hasViewed];
		[conversationNodeOptions addObject:option];
	}
	
	//return conversationNodeOptions;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConversationNodeOptionsReady" object:conversationNodeOptions]];
}

-(void)parseLoginResponseFromJSON:(JSONResult *)jsonResult
{
	NSLog(@"AppServices: parseLoginResponseFromJSON");
	
	[[RootViewController sharedRootViewController] removeWaitingIndicator];
    
	if (jsonResult.data != [NSNull null])
    {
		[AppModel sharedAppModel].loggedIn = YES;
		[AppModel sharedAppModel].playerId = [self validIntForKey:@"player_id" inDictionary:((NSDictionary*)jsonResult.data)];
		[AppModel sharedAppModel].playerMediaId = [self validIntForKey:@"media_id" inDictionary:((NSDictionary*)jsonResult.data)];
        [AppModel sharedAppModel].userName = [self validObjectForKey:@"user_name" inDictionary:((NSDictionary*)jsonResult.data)];
        [AppModel sharedAppModel].displayName = [self validObjectForKey:@"display_name" inDictionary:((NSDictionary*)jsonResult.data) ];
        [[AppServices sharedAppServices] setShowPlayerOnMap];
        [[AppModel sharedAppModel] saveUserDefaults];
        
        //Subscribe to player channel
        //[RootViewController sharedRootViewController].playerChannel = [[RootViewController sharedRootViewController].client subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",[AppModel sharedAppModel].playerId]];
    }
	else
        [AppModel sharedAppModel].loggedIn = NO;
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLoginResponseReady" object:nil]];
}

-(void)parseSelfRegistrationResponseFromJSON: (JSONResult *)jsonResult
{
	if (!jsonResult)
    {
		NSLog(@"AppModel registerNewUser: No result Data, return");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationFailed" object:nil]];
	}
    
    int newId = [(NSDecimalNumber*)jsonResult.data intValue];
    
	if (newId > 0)
    {
		NSLog(@"AppModel: Result from new user request successfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationSucceeded" object:nil]];
	}
	else
    {
		NSLog(@"AppModel: Result from new user request unsuccessfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationFailed" object:nil]];
	}
}

- (Game *)parseGame:(NSDictionary *)gameSource
{
    Game *game = [[Game alloc] init];
    
    game.gameId                   = [self validIntForKey:@"game_id"               inDictionary:gameSource];
    game.hasBeenPlayed            = [self validBoolForKey:@"has_been_played"      inDictionary:gameSource];
    game.isLocational             = [self validBoolForKey:@"is_locational"        inDictionary:gameSource];
    game.showPlayerLocation       = [self validBoolForKey:@"show_player_location" inDictionary:gameSource];
    game.inventoryModel.weightCap = [self validIntForKey:@"inventory_weight_cap"  inDictionary:gameSource];
    game.rating                   = [self validIntForKey:@"rating"                inDictionary:gameSource];
    game.pcMediaId                = [self validIntForKey:@"pc_media_id"           inDictionary:gameSource];
    game.numPlayers               = [self validIntForKey:@"numPlayers"            inDictionary:gameSource];
    game.playerCount              = [self validIntForKey:@"count"                 inDictionary:gameSource];
    game.description              = [self validObjectForKey:@"description"        inDictionary:gameSource]; if (!game.description) game.description = @"";
    game.name                     = [self validObjectForKey:@"name"               inDictionary:gameSource]; if (!game.name) game.name = @"";
    game.authors                  = [self validObjectForKey:@"editors"            inDictionary:gameSource]; if (!game.authors) game.authors = @"";
    game.mapType                  = [self validObjectForKey:@"map_type"           inDictionary:gameSource];
    if (!game.mapType || (![game.mapType isEqualToString:@"STREET"] && ![game.mapType isEqualToString:@"SATELLITE"] && ![game.mapType isEqualToString:@"HYBRID"])) game.mapType = @"STREET";

    NSString *distance = [self validObjectForKey:@"distance" inDictionary:gameSource];
    if (distance) game.distanceFromPlayer = [distance doubleValue];
    else game.distanceFromPlayer = 999999999;
    
    NSString *latitude  = [self validObjectForKey:@"latitude" inDictionary:gameSource];
    NSString *longitude = [self validObjectForKey:@"longitude" inDictionary:gameSource];
    if (latitude && longitude)
        game.location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    else
        game.location = [[CLLocation alloc] init];
    
    

    
    int iconMediaId;
    if((iconMediaId = [self validIntForKey:@"icon_media_id" inDictionary:gameSource]) > 0)
    {
        game.iconMedia = [[AppModel sharedAppModel] mediaForMediaId:iconMediaId];
        game.iconMediaUrl = [NSURL URLWithString:game.iconMedia.url];
    }
    NSString *iconMediaUrl;
    if(!game.iconMedia && (iconMediaUrl = [self validObjectForKey:@"icon_media_url" inDictionary:gameSource]) && [iconMediaUrl length]>0)
    {
        game.iconMediaUrl = [NSURL URLWithString:iconMediaUrl];
        game.iconMedia = [[AppModel sharedAppModel].mediaCache mediaForUrl:game.iconMediaUrl];
    }
    
    int mediaId;
    if((mediaId = [self validIntForKey:@"media_id" inDictionary:gameSource]) > 0)
    {
        game.splashMedia = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
        game.mediaUrl = [NSURL URLWithString:game.splashMedia.url];
    }
    NSString *mediaUrl;
    if (!game.splashMedia && (mediaUrl = [self validObjectForKey:@"media_url" inDictionary:gameSource]) && [mediaUrl length]>0)
    {
        game.mediaUrl = [NSURL URLWithString:mediaUrl];
        game.splashMedia = [[AppModel sharedAppModel].mediaCache mediaForUrl:game.mediaUrl];
    }
    
    game.questsModel.totalQuestsInGame = [self validIntForKey:@"totalQuests"           inDictionary:gameSource];
    game.launchNodeId                  = [self validIntForKey:@"on_launch_node_id"     inDictionary:gameSource];
    game.completeNodeId                = [self validIntForKey:@"game_complete_node_id" inDictionary:gameSource];
    game.calculatedScore               = [self validIntForKey:@"calculatedScore"       inDictionary:gameSource];
    game.numReviews                    = [self validIntForKey:@"numComments"           inDictionary:gameSource];
    game.allowsPlayerTags              = [self validBoolForKey:@"allow_player_tags"        inDictionary:gameSource];
    game.allowShareNoteToMap           = [self validBoolForKey:@"allow_share_note_to_map"  inDictionary:gameSource];
    game.allowShareNoteToList          = [self validBoolForKey:@"allow_share_note_to_book" inDictionary:gameSource];
    game.allowNoteComments             = [self validBoolForKey:@"allow_note_comments"      inDictionary:gameSource];
    game.allowNoteLikes                = [self validBoolForKey:@"allow_note_likes"         inDictionary:gameSource];
    game.allowTrading                  = [self validBoolForKey:@"allow_trading"            inDictionary:gameSource];
    
    NSArray *comments = [self validObjectForKey:@"comments" inDictionary:gameSource];
    for (NSDictionary *comment in comments) {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        //TODO: Create a Comments object
        Comment *c = [[Comment alloc] init];
        c.text = [self validObjectForKey:@"text" inDictionary:comment];
        c.playerName = [self validObjectForKey:@"username" inDictionary:comment];
        NSString *cRating = [self validObjectForKey:@"rating" inDictionary:comment];
        if (cRating) c.rating = [cRating intValue];
        [game.comments addObject:c];
    }
    
    //NSLog(@"Model: Adding Game: %@", game.name);
    return game;
}

-(NSMutableArray *)parseGameListFromJSON:(JSONResult *)jsonResult{
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedGameList" object:nil]];
    
    NSArray *gameListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
    
    NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];
    NSDictionary *gameDictionary;
    while ((gameDictionary = [gameListEnumerator nextObject])) {
        [tempGameList addObject:[self parseGame:(gameDictionary)]];
    }
    
    NSError *error;
    if (![[AppModel sharedAppModel].mediaCache.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSLog(@"AppModel: parseGameListFromJSON Complete, sending notification");
    
    return tempGameList;
}

-(void)parseOneGameGameListFromJSON: (JSONResult *)jsonResult
{
    NSLog(@"parseOneGameGameListFromJSON called");
    currentlyFetchingOneGame = NO;
    [AppModel sharedAppModel].oneGameGameList = [self parseGameListFromJSON:jsonResult];
    Game * game = (Game *)[[AppModel sharedAppModel].oneGameGameList  objectAtIndex:0];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewOneGameGameListReady" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:game,@"game", nil]]];
}

-(void)parseNearbyGameListFromJSON: (JSONResult *)jsonResult
{
    currentlyFetchingNearbyGamesList = NO;
    [AppModel sharedAppModel].nearbyGameList = [self parseGameListFromJSON:jsonResult];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNearbyGameListReady" object:nil]];
}

-(void)parseSearchGameListFromJSON: (JSONResult *)jsonResult
{
    currentlyFetchingSearchGamesList = NO;
    [AppModel sharedAppModel].searchGameList = [self parseGameListFromJSON:jsonResult];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewSearchGameListReady" object:nil]];
}

-(void)parsePopularGameListFromJSON: (JSONResult *)jsonResult{
    currentlyFetchingPopularGamesList = NO;
    [AppModel sharedAppModel].popularGameList = [self parseGameListFromJSON:jsonResult];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewPopularGameListReady" object:nil]];
}

-(void)parseRecentGameListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"AppModel: parseRecentGameListFromJSON Beginning");
    
    currentlyFetchingRecentGamesList = NO;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedGameList" object:nil]];
    
    NSArray *gameListArray = (NSArray *)jsonResult.data;
    
    NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
    
    NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];
    NSDictionary *gameDictionary;
    while ((gameDictionary = [gameListEnumerator nextObject])) {
        [tempGameList addObject:[self parseGame:(gameDictionary)]];
    }
    
    [AppModel sharedAppModel].recentGameList = tempGameList;
    NSError *error;
    if (![[AppModel sharedAppModel].mediaCache.context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    NSLog(@"AppModel: parseGameListFromJSON Complete, sending notification");
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewRecentGameListReady" object:nil]];
}

- (void)saveGameComment:(NSString*)comment game:(int)gameId starRating:(int)rating{
	NSLog(@"AppModel: Save Comment Requested");
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId], [NSString stringWithFormat:@"%d", gameId], [NSString stringWithFormat:@"%d", rating], comment, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL
                                                             andServiceName: @"games"
                                                              andMethodName:@"saveComment"
                                                               andArguments:arguments andUserInfo:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameCommentResponseFromJSON:)];
}

- (void)parseSaveGameCommentResponseFromJSON: (JSONResult *)jsonResult
{
	if (!jsonResult)
    {
		NSLog(@"AppModel saveComment: No result Data, return");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SaveCommentFailed" object:nil]];
	}
	else
    {
		NSLog(@"AppModel: Result from save comment request unsuccessfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SaveCommentFailed" object:nil]];
	}
}

- (void)parseLocationListFromJSON: (JSONResult *)jsonResult
{
	NSLog(@"AppModel: Parsing Location List");
	
    currentlyFetchingLocationList = NO;
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedLocationList" object:nil]];
	
	NSArray *locationsArray = (NSArray *)jsonResult.data;
    
	//Build the location list
	NSMutableArray *tempLocationsList = [[NSMutableArray alloc] init];
	NSEnumerator *locationsEnumerator = [locationsArray objectEnumerator];
	NSDictionary *locationDictionary;
	while ((locationDictionary = [locationsEnumerator nextObject]))
    {
        Location *location = [self parseLocationFromDictionary:locationDictionary];
		
		NSLog(@"AppServices parsed: %@",location);
		[tempLocationsList addObject:location];
	}
		
	//Tell everyone
    NSDictionary *locations  = [[NSDictionary alloc] initWithObjectsAndKeys:tempLocationsList,@"locations", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerLocationsReceived" object:nil userInfo:locations]];
}

-(Location*)parseLocationFromDictionary: (NSDictionary*)locationDictionary
{
    Location *location = [[Location alloc] init];
    location.locationId        = [self validIntForKey:@"location_id"         inDictionary:locationDictionary];
    location.objectId          = [self validIntForKey:@"type_id"             inDictionary:locationDictionary];
    location.qty               = [self validIntForKey:@"item_qty"            inDictionary:locationDictionary];
    location.iconMediaId       = [self validIntForKey:@"icon_media_id"       inDictionary:locationDictionary];
    location.name              = [self validObjectForKey:@"name"             inDictionary:locationDictionary];
    location.error             = [self validDoubleForKey:@"error"            inDictionary:locationDictionary];
    location.objectType        = [self validObjectForKey:@"type"             inDictionary:locationDictionary];
    location.hidden            = [self validBoolForKey:@"hidden"             inDictionary:locationDictionary];
    location.forcedDisplay     = [self validBoolForKey:@"force_view"         inDictionary:locationDictionary];
    location.showTitle         = [self validBoolForKey:@"show_title"         inDictionary:locationDictionary];
    location.wiggle            = [self validBoolForKey:@"wiggle"             inDictionary:locationDictionary];
    location.allowsQuickTravel = [self validBoolForKey:@"allow_quick_travel" inDictionary:locationDictionary];
    location.location          = [[CLLocation alloc] initWithLatitude:[self validDoubleForKey:@"latitude"  inDictionary:locationDictionary]
                                                            longitude:[self validDoubleForKey:@"longitude" inDictionary:locationDictionary]];
    
    NSNumber *num = [NSNumber numberWithInt:location.wiggle];
    if(num == nil)  location.wiggle = 0;
    //if(location.wiggle == nil)  location.wiggle = 0;
    location.deleteWhenViewed = [self validIntForKey:@"delete_when_viewed" inDictionary:locationDictionary];
    
    if(location.objectType &&[location.objectType isEqualToString:@"PlayerNote"])
    {
        Note *note     = [[AppModel sharedAppModel]noteForNoteId:location.objectId playerListYesGameListNo:YES];
        if(!note) note = [[AppModel sharedAppModel]noteForNoteId:location.objectId playerListYesGameListNo:NO];
        if(note && note.showOnList) location.allowsQuickTravel = YES;
        else                        location.allowsQuickTravel = NO;
    }
    return location;
}

-(void)parseSingleMediaFromJSON: (JSONResult *)jsonResult
{
    //Just convert the data into a dictionary and pretend it is a full game list, so same thing as 'parseGameMediaListFromJSON'
    NSArray * data = [[NSArray alloc] initWithObjects:jsonResult.data, nil];
    jsonResult.data = data;
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1];
}

-(void)parseGameMediaListFromJSON: (JSONResult *)jsonResult
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
    [self performSelector:@selector(startCachingMedia:) withObject:jsonResult afterDelay:.1];
}

-(void)startCachingMedia:(JSONResult *)jsonResult
{
    //Get server media
    NSArray *serverMediaArray = (NSArray *)jsonResult.data;
    
    //Get cached media
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(gameid = 0) OR (gameid = %d)", [AppModel sharedAppModel].currentGame.gameId];
    NSArray *cachedMediaArray = [[AppModel sharedAppModel].mediaCache mediaForPredicate:predicate];
    NSLog(@"%d total media for %d",[cachedMediaArray count], [AppModel sharedAppModel].currentGame.gameId);
    
    //Construct cached media map (dictionary with identical key/values of mediaId) to quickly check for existence of media
    NSMutableDictionary *cachedMediaMap = [[NSMutableDictionary alloc]initWithCapacity:cachedMediaArray.count];
    for(int i = 0; i < [cachedMediaArray count]; i++)
    {
        if([[cachedMediaArray objectAtIndex:i] uid])
            [cachedMediaMap setObject:[cachedMediaArray objectAtIndex:i] forKey:[[cachedMediaArray objectAtIndex:i] uid]];
        else
            NSLog(@"found broken coredata entry");
    }
    
    //For every media in server array
    Media *tmpMedia;
    for(int i = 0; i < [serverMediaArray count]; i++)
    {
        //Check if the id is valid, but doesn't exist in the cached array
        int mediaId = [self validIntForKey:@"media_id" inDictionary:[serverMediaArray objectAtIndex:i]];
        if(mediaId >= 1 && ![cachedMediaMap objectForKey:[NSNumber numberWithInt:mediaId]])
        {
            //Cache it
            NSDictionary *tempMediaDict = [serverMediaArray objectAtIndex:i];
            NSString *fileName = [self validObjectForKey:@"file_path" inDictionary:tempMediaDict] ? [self validObjectForKey:@"file_path" inDictionary:tempMediaDict] : [self validObjectForKey:@"file_name" inDictionary:tempMediaDict];
            tmpMedia = [[AppModel sharedAppModel].mediaCache addMediaToCache:mediaId];
            tmpMedia.url = [NSString stringWithFormat:@"%@%@", [self validObjectForKey:@"url_path" inDictionary:tempMediaDict], fileName];
            tmpMedia.type = [self validObjectForKey:@"type" inDictionary:tempMediaDict];
            tmpMedia.gameid = [NSNumber numberWithInt:[self validIntForKey:@"game_id" inDictionary:tempMediaDict]];
            NSLog(@"Cached Media: %d with URL: %@",mediaId,tmpMedia.url);
        }
        else if((tmpMedia = [cachedMediaMap objectForKey:[NSNumber numberWithInt:mediaId]]) && (tmpMedia.url == nil || tmpMedia.type == nil || tmpMedia.gameid == nil))
        {
            NSDictionary *tempMediaDict = [serverMediaArray objectAtIndex:i];
            NSString *fileName = [self validObjectForKey:@"file_path" inDictionary:tempMediaDict] ? [self validObjectForKey:@"file_path" inDictionary:tempMediaDict] : [self validObjectForKey:@"file_name" inDictionary:tempMediaDict];
            tmpMedia.url = [NSString stringWithFormat:@"%@%@", [self validObjectForKey:@"url_path" inDictionary:tempMediaDict], fileName];
            tmpMedia.type = [self validObjectForKey:@"type" inDictionary:tempMediaDict];
            tmpMedia.gameid = [NSNumber numberWithInt:[self validIntForKey:@"game_id" inDictionary:tempMediaDict]];
            NSLog(@"Cached Media: %d with URL: %@",mediaId,tmpMedia.url);
        }
    }
    NSError *error;
    if (![[AppModel sharedAppModel].mediaCache.context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedMediaList" object:nil]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameItemListFromJSON:(JSONResult *)jsonResult
{
	NSArray *itemListArray = (NSArray *)jsonResult.data;
    
	NSMutableDictionary *tempItemList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [itemListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Item *tmpItem = [self parseItemFromDictionary:dict];
		[tempItemList setObject:tmpItem forKey:[NSNumber numberWithInt:tmpItem.itemId]];
    }
	
	[AppModel sharedAppModel].gameItemList = tempItemList;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameNodeListFromJSON: (JSONResult *)jsonResult
{
	NSArray *nodeListArray = (NSArray *)jsonResult.data;
	NSMutableDictionary *tempNodeList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [nodeListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Node *tmpNode = [self parseNodeFromDictionary:dict];
		[tempNodeList setObject:tmpNode forKey:[NSNumber numberWithInt:tmpNode.nodeId]];
	}
	
	[AppModel sharedAppModel].gameNodeList = tempNodeList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameTabListFromJSON: (JSONResult *)jsonResult
{
	NSArray *tabListArray = (NSArray *)jsonResult.data;
	NSArray *tempTabList = [[NSMutableArray alloc] initWithCapacity:10];
	NSEnumerator *enumerator = [tabListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Tab *tmpTab = [self parseTabFromDictionary:dict];
		tempTabList = [tempTabList arrayByAddingObject:tmpTab];
	}
	
	[AppModel sharedAppModel].gameTabList = tempTabList;
    [[RootViewController sharedRootViewController] changeTabBar];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseGameNpcListFromJSON:(JSONResult *)jsonResult
{
	NSArray *npcListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempNpcList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)npcListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Npc *tmpNpc = [self parseNpcFromDictionary:dict];
		[tempNpcList setObject:tmpNpc forKey:[NSNumber numberWithInt:tmpNpc.npcId]];
	}
	
	[AppModel sharedAppModel].gameNpcList = tempNpcList;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGameWebPageListFromJSON:(JSONResult *)jsonResult
{
	NSArray *webpageListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempWebPageList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)webpageListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		WebPage *tmpWebpage = [self parseWebPageFromDictionary:dict];
		[tempWebPageList setObject:tmpWebpage forKey:[NSNumber numberWithInt:tmpWebpage.webPageId]];
	}
	
	[AppModel sharedAppModel].gameWebPageList = tempWebPageList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

- (void) parseGamePanoramicListFromJSON:(JSONResult *)jsonResult
{
	NSArray *panListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempPanoramicList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)panListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject]))
    {
		Panoramic *tmpPan = [self parsePanoramicFromDictionary:dict];
		[tempPanoramicList setObject:tmpPan forKey:[NSNumber numberWithInt:tmpPan.panoramicId]];
	}
	
	[AppModel sharedAppModel].gamePanoramicList = tempPanoramicList;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseInventoryFromJSON:(JSONResult *)jsonResult
{
	NSLog(@"AppModel: Parsing Inventory");
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedInventory" object:nil]];
    
    currentlyFetchingInventory = NO;
	
	NSMutableArray *tempInventory = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *tempAttributes = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray *inventoryArray = (NSArray *)jsonResult.data;
	NSEnumerator *inventoryEnumerator = [((NSArray *)inventoryArray) objectEnumerator];
	NSDictionary *itemDictionary;
	while ((itemDictionary = [inventoryEnumerator nextObject]))
    {
        Item *item = [[Item alloc] init];
        item.itemId      = [self validIntForKey:@"item_id"              inDictionary:itemDictionary];
        item.mediaId     = [self validIntForKey:@"media_id"             inDictionary:itemDictionary];
        item.iconMediaId = [self validIntForKey:@"icon_media_id"        inDictionary:itemDictionary];
        item.creatorId   = [self validIntForKey:@"creator_player_id"    inDictionary:itemDictionary];
        item.qty         = [self validIntForKey:@"qty"                  inDictionary:itemDictionary];
        item.maxQty      = [self validIntForKey:@"max_qty_in_inventory" inDictionary:itemDictionary];
        item.weight      = [self validIntForKey:@"weight"               inDictionary:itemDictionary];
        item.dropable    = [self validBoolForKey:@"dropable"            inDictionary:itemDictionary];
        item.destroyable = [self validBoolForKey:@"destroyable"         inDictionary:itemDictionary];
        item.isAttribute = [self validBoolForKey:@"is_attribute"        inDictionary:itemDictionary];
        item.isTradeable = [self validBoolForKey:@"tradeable"           inDictionary:itemDictionary];
        item.hasViewed   = [self validBoolForKey:@"viewed"              inDictionary:itemDictionary];
        item.url         = [self validObjectForKey:@"url"               inDictionary:itemDictionary];
        item.type        = [self validObjectForKey:@"type"              inDictionary:itemDictionary];
        item.name        = [self validObjectForKey:@"name"              inDictionary:itemDictionary];
        item.description = [self validObjectForKey:@"description"       inDictionary:itemDictionary];

        if(item.isAttribute)[tempAttributes addObject:item];
        else                [tempInventory  addObject:item];
	}
    
	NSDictionary *inventory  = [[NSDictionary alloc] initWithObjectsAndKeys:tempInventory,@"inventory", nil];
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:tempAttributes,@"attributes", nil];
    NSLog(@"Posting notif");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerInventoryReceived" object:nil userInfo:inventory]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerAttributesReceived" object:nil userInfo:attributes]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}

-(void)parseQRCodeObjectFromJSON:(JSONResult *)jsonResult
{
    NSLog(@"ParseQRCodeObjectFromJSON: Coolio!");
    [[RootViewController sharedRootViewController] removeWaitingIndicator];
    
	NSObject<QRCodeProtocol> *qrCodeObject;
    
	if (jsonResult.data)
    {
		NSDictionary *qrCodeDictionary = (NSDictionary *)jsonResult.data;
        if(![qrCodeDictionary isKindOfClass:[NSString class]])
        {
            NSString *type = [self validObjectForKey:@"link_type" inDictionary:qrCodeDictionary];
            NSDictionary *objectDictionary = [self validObjectForKey:@"object" inDictionary:qrCodeDictionary];
            if ([type isEqualToString:@"Location"]) qrCodeObject = [self parseLocationFromDictionary:objectDictionary];
        }
        else qrCodeObject = qrCodeDictionary;
	}
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"QRCodeObjectReady" object:qrCodeObject]];
}

-(void)parseStartOverFromJSON:(JSONResult *)jsonResult
{
	NSLog(@"AppModel: Parsing start over result and firing off fetches");
}

-(void)parseUpdateServerWithPlayerLocationFromJSON:(JSONResult *)jsonResult
{
    NSLog(@"AppModel: parseUpdateServerWithPlayerLocationFromJSON");
    currentlyUpdatingServerWithPlayerLocation = NO;
}

-(void)parseQuestListFromJSON:(JSONResult *)jsonResult
{
    NSLog(@"AppModel: Parsing Quests");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedQuestList" object:nil]];
    
    currentlyFetchingQuestList = NO;

	NSDictionary *questListDictionary = (NSDictionary *)jsonResult.data;
	
    //Active Quests
	NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
    NSArray *activeQuests = [self validObjectForKey:@"active" inDictionary:questListDictionary];
	NSEnumerator *activeQuestsEnumerator = [activeQuests objectEnumerator];
	NSDictionary *activeQuest;
	while ((activeQuest = [activeQuestsEnumerator nextObject]))
    {
	Quest *quest = [[Quest alloc] init];
	quest.questId                = [self validIntForKey:@"quest_id"             inDictionary:activeQuest];
        quest.name                   = [self validObjectForKey:@"name"              inDictionary:activeQuest];
        quest.qdescription            = [self validObjectForKey:@"description"       inDictionary:activeQuest];
        quest.fullScreenNotification = [self validBoolForKey:@"full_screen_notify"  inDictionary:activeQuest];
        quest.mediaId                = [self validIntForKey:@"active_media_id"      inDictionary:activeQuest];
	quest.iconMediaId            = [self validIntForKey:@"active_icon_media_id" inDictionary:activeQuest];
        quest.sortNum                = [self validIntForKey:@"sort_index"           inDictionary:activeQuest];
        
        quest.exitToTabName = [self validObjectForKey:@"exit_to_tab" inDictionary:activeQuest]
                              ? [self validObjectForKey:@"exit_to_tab" inDictionary:activeQuest]
                              : @"NONE";
        if     ([quest.exitToTabName isEqualToString:@"QUESTS"])    quest.exitToTabName = NSLocalizedString(@"QuestViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"GPS"])       quest.exitToTabName = NSLocalizedString(@"MapViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"INVENTORY"]) quest.exitToTabName = NSLocalizedString(@"InventoryViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"QR"])        quest.exitToTabName = NSLocalizedString(@"QRScannerTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"PLAYER"])    quest.exitToTabName = NSLocalizedString(@"PlayerTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"NOTE"])      quest.exitToTabName = NSLocalizedString(@"NotebookTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"PICKGAME"])  quest.exitToTabName = NSLocalizedString(@"GamePickerTitleKey",@"");
        
		[activeQuestObjects addObject:quest];
	}
    
    //Completed Quests
	NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
    NSArray *completedQuests = [self validObjectForKey:@"completed" inDictionary:questListDictionary];
	NSEnumerator *completedQuestsEnumerator = [completedQuests objectEnumerator];
	NSDictionary *completedQuest;
	while ((completedQuest = [completedQuestsEnumerator nextObject]))
    {
	Quest *quest = [[Quest alloc] init];
	quest.questId                = [self validIntForKey:@"quest_id"               inDictionary:completedQuest];
        quest.name                   = [self validObjectForKey:@"name"                inDictionary:completedQuest];
        quest.qdescription            = [self validObjectForKey:@"text_when_complete"  inDictionary:completedQuest];
        quest.fullScreenNotification = [self validBoolForKey:@"full_screen_notify"    inDictionary:completedQuest];
        quest.mediaId                = [self validIntForKey:@"complete_media_id"      inDictionary:completedQuest];
        quest.iconMediaId            = [self validIntForKey:@"complete_icon_media_id" inDictionary:completedQuest];
        quest.sortNum                = [self validIntForKey:@"sort_index"             inDictionary:completedQuest];
        
        quest.exitToTabName = [self validObjectForKey:@"exit_to_tab" inDictionary:completedQuest]
                              ? [self validObjectForKey:@"exit_to_tab" inDictionary:completedQuest]
                              : @"NONE";
        if     ([quest.exitToTabName isEqualToString:@"QUESTS"])    quest.exitToTabName = NSLocalizedString(@"QuestViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"GPS"])       quest.exitToTabName = NSLocalizedString(@"MapViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"INVENTORY"]) quest.exitToTabName = NSLocalizedString(@"InventoryViewTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"QR"])        quest.exitToTabName = NSLocalizedString(@"QRScannerTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"PLAYER"])    quest.exitToTabName = NSLocalizedString(@"PlayerTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"NOTE"])      quest.exitToTabName = NSLocalizedString(@"NotebookTitleKey",@"");
        else if([quest.exitToTabName isEqualToString:@"PICKGAME"])  quest.exitToTabName = NSLocalizedString(@"GamePickerTitleKey",@"");
        
		[completedQuestObjects addObject:quest];
	}
        
	//Package the two object arrays in a Dictionary
	NSMutableDictionary *questLists = [[NSMutableDictionary alloc] init];
	[questLists setObject:activeQuestObjects forKey:@"active"];
	[questLists setObject:completedQuestObjects forKey:@"completed"];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LatestPlayerQuestListsReceived" object:self userInfo:questLists]];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GamePieceReceived" object:nil]];
}


@end
