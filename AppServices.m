//
//  AppServices.m
//  ARIS
//
//  Created by David J Gagnon on 5/11/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "AppServices.h"

static const int kDefaultCapacity = 10;
static const int kEmptyValue = -1;
NSString *const kARISServerServicePackage = @"v1";


@interface AppServices()

- (NSInteger) validIntForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;
- (id) validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary;

@end

@implementation AppServices

@synthesize currentlyFetchingLocationList, currentlyFetchingInventory, currentlyFetchingQuestList, currentlyFetchingGamesList, currentlyUpdatingServerWithPlayerLocation;
@synthesize currentlyUpdatingServerWithMapViewed, currentlyUpdatingServerWithQuestsViewed, currentlyUpdatingServerWithInventoryViewed;


+ (id)sharedAppServices
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark Communication with Server
- (void)login {
	NSLog(@"AppModel: Login Requested");
	NSArray *arguments = [NSArray arrayWithObjects:[AppModel sharedAppModel].userName, [AppModel sharedAppModel].password, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL 
                                                             andServiceName: @"players" 
                                                              andMethodName:@"loginPlayer"
                                                               andArguments:arguments
                                                                andUserData:nil]; 
    
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLoginResponseFromJSON:)]; 
	[jsonConnection release];
	
}
-(void)setShowPlayerOnMap{
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId],[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].showPlayerOnMap], nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL 
                                                             andServiceName: @"players" 
                                                              andMethodName:@"setShowPlayerOnMap"
                                                               andArguments:arguments 
                                                                andUserData:nil]; 
    
	[jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
}
- (void)registerNewUser:(NSString*)userName password:(NSString*)pass 
			  firstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email {
	NSLog(@"AppModel: New User Registration Requested");
	//createPlayer($strNewUserName, $strPassword, $strFirstName, $strLastName, $strEmail)
	NSArray *arguments = [NSArray arrayWithObjects:userName, pass, firstName, lastName, email, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL 
                                                             andServiceName: @"players" 
                                                              andMethodName:@"createPlayer"
                                                               andArguments:arguments 
                                                                andUserData:nil]; 
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseSelfRegistrationResponseFromJSON:)]; 
	[jsonConnection release];
	
}

- (void)updateServerNodeViewed: (int)nodeId {
	NSLog(@"Model: Node %d Viewed, update server", nodeId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d", nodeId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"players" 
                                                             andMethodName:@"nodeViewed" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
}

- (void)updateServerWebPageViewed: (int)webPageId {
	NSLog(@"Model: WebPage %d Viewed, update server", webPageId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",webPageId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"players" 
                                                             andMethodName:@"webPageViewed" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}
- (void)updateServerPanoramicViewed: (int)panoramicId {
	NSLog(@"Model: Panoramic %d Viewed, update server", panoramicId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",panoramicId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"players" 
                                                             andMethodName:@"augBubbleViewed" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}

- (void)updateServerItemViewed: (int)itemId {
	NSLog(@"Model: Item %d Viewed, update server", itemId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",itemId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"players" 
                                                             andMethodName:@"itemViewed" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}

- (void)updateServerNpcViewed: (int)npcId {
	NSLog(@"Model: Npc %d Viewed, update server", npcId);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  [NSString stringWithFormat:@"%d",npcId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"players" 
                                                             andMethodName:@"npcViewed" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil];
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
    
}

- (void)startOverGame{
	NSLog(@"Model: Start Over");
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	
    [appDelegate displayIntroNode];
    
    [self resetAllPlayerLists];
    
    [self resetAllGameLists];
    
    [appDelegate.tutorialViewController dismissAllTutorials];
    
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]
                                      initWithServer:[AppModel sharedAppModel].serverURL
                                      andServiceName:@"players"
                                      andMethodName:@"startOverGameForPlayer"
                                      andArguments:arguments 
                                      andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:
     @selector(parseStartOverFromJSON:)]; 
	[jsonConnection release];
    
    [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] returnToHomeView];
    
}


- (void)updateServerPickupItem: (int)itemId fromLocation: (int)locationId qty:(int)qty{
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[self forceUpdateOnNextLocationListFetch];
	[jsonConnection release];
	
}

- (void)updateServerDropItemHere: (int)itemId qty:(int)qty{
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[self forceUpdateOnNextLocationListFetch];
	[jsonConnection release];
    
}
- (void)updateServerDropNoteHere: (int)noteId atCoordinate: (CLLocationCoordinate2D) coordinate{
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[self forceUpdateOnNextLocationListFetch];
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[jsonConnection release];
    
}

- (void)uploadImageForMatching:(NSData *)fileData{

   	// setting up the request object now
	    NSURL *url = [[AppModel sharedAppModel].serverURL URLByAppendingPathComponent:[NSString stringWithFormat: @"services/%@/uploadHandler.php",kARISServerServicePackage]];	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.timeOutSeconds = 60;
	
 	[request setPostValue:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId] forKey:@"gameID"];	 
	[request setPostValue:@"upload.png" forKey:@"fileName"];
	[request setData:fileData forKey:@"file"];
	[request setDidFinishSelector:@selector(uploadImageForMatchingRequestFinished:)];
	[request setDidFailSelector:@selector(uploadRequestFailed:)];
	[request setDelegate:self];
		
	NSLog(@"Model: Uploading File. gameID:%d",[AppModel sharedAppModel].currentGame.gameId);
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate showNewWaitingIndicator:@"Uploading" displayProgressBar:YES];
	[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
	[request startAsynchronous];
}

-(void)createItemAndPlaceOnMap:(Item *)item {
    NSLog(@"AppModel: Creating Note: %@",item.name);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          item.name,
						  item.description,
                          @"note123",
						  @"1", //dropable
						  @"1", //destroyable
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          @"NOTE",
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items" 
                                                             andMethodName:@"createItemAndPlaceOnMap" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}

- (void)createItemAndPlaceOnMapFromFileData:(NSData *)fileData fileName:(NSString *)fileName 
										title:(NSString *)title description:(NSString*)description {
    
	// setting up the request object now
	    NSURL *url = [[AppModel sharedAppModel].serverURL URLByAppendingPathComponent:[NSString stringWithFormat: @"services/%@/uploadHandler.php",kARISServerServicePackage]];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.timeOutSeconds = 60;
	
 	[request setPostValue:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId] forKey:@"gameID"];	 
	[request setPostValue:fileName forKey:@"fileName"];
	[request setData:fileData forKey:@"file"];
	[request setDidFinishSelector:@selector(uploadItemRequestFinished:)];
	[request setDidFailSelector:@selector(uploadItemRequestFailed:)];
	[request setDelegate:self];
	
	//We need these after the upload is complete to create the item on the server
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", description, @"description", nil];
	[request setUserInfo:userInfo];
	
	NSLog(@"Model: Uploading File. gameID:%d fileName:%@ title:%@ description:%@",[AppModel sharedAppModel].currentGame.gameId,fileName,title,description );
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate showNewWaitingIndicator:@"Uploading" displayProgressBar:YES];
	[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
	[request startAsynchronous];
}


-(void)createItemAndGivetoPlayer:(Item *)item {
    NSLog(@"AppModel: Creating Note: %@",item.name);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          item.name,
						  item.description,
                           @"note123",
						  @"1", //dropable
						  @"1", //destroyable
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          @"NOTE",
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items" 
                                                             andMethodName:@"createItemAndGiveToPlayer" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];

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
                                                               andUserData:nil];

    if(refresh)
        [jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)]; 

        else
	[jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
	
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
                                                               andUserData:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	[jsonConnection release];

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
                                                               andUserData:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	[jsonConnection release];
}

-(int)addCommentToNoteWithId:(int)noteId andTitle:(NSString *)title{
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
                                                               andUserData:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	[jsonConnection release];
	
	
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return nil;
	}
	
	return [jsonResult.data intValue];
}
-(int)createNote{
    NSLog(@"AppModel: Creating New Note");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes" 
                                                             andMethodName:@"createNewNote" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	[jsonConnection release];
	
	
	if (!jsonResult) {
		NSLog(@"\tFailed.");
		return nil;
	}
	
	return [jsonResult.data intValue];
}

-(void) addContentToNoteWithText:(NSString *)text type:(NSString *) type mediaId:(int) mediaId andNoteId:(int)noteId{
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
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes" 
                                                             andMethodName:@"addContentToNote" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)]; 
	[jsonConnection release];
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNoteViewer)]; 
	[jsonConnection release];
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
                                                               andUserData:nil];
    [jsonConnection performAsynchronousRequestWithHandler:nil]; 
	[jsonConnection release];
	
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNotebookViewer)]; 
	[jsonConnection release];
    }
    else{
        NSLog(@"Tried deleting note 0 and that's a no-no!");
    }

}

-(void)sendNotificationToNoteViewer{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewContentListReady" object:nil]];
}
-(void)sendNotificationToNotebookViewer{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NoteDeleted" object:nil]];
}
-(void) addContentToNoteFromFileData:(NSData *)fileData fileName:(NSString *)fileName 
                                name:(NSString *)name noteId:(int) noteId type: (NSString *)type{
    NSURL *url = [[AppModel sharedAppModel].serverURL URLByAppendingPathComponent:[NSString stringWithFormat: @"services/%@/uploadHandler.php",kARISServerServicePackage]];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.timeOutSeconds = 300;
	
 	[request setPostValue:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId] forKey:@"gameID"];
	[request setPostValue:fileName forKey:@"fileName"];
	[request setData:fileData forKey:@"file"];
	[request setDidFinishSelector:@selector(uploadNoteContentRequestFinished: )];
	[request setDidFailSelector:@selector(uploadNoteRequestFailed:)];
	[request setDelegate:self];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:noteId];
    //NSNumber *contentCount = [[NSNumber alloc]initWithInt:([[(Note *)[[AppModel sharedAppModel].playerNoteList objectForKey:[NSNumber numberWithInt:noteId]] contents] count]-1)];
	//We need these after the upload is complete to create the item on the server
	NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:name, @"title", nId, @"noteId", nil];
    [userInfo setValue:name forKey:@"title"];
    [userInfo setValue:nId forKey:@"noteId"];
    [userInfo setValue:type forKey: @"type"];
    [userInfo setValue:fileName forKey:@"url"];
	[request setUserInfo:userInfo];
	
	NSLog(@"Model: Uploading File. gameID:%d fileName:%@ title:%@ noteId:%d",[AppModel sharedAppModel].currentGame.gameId,fileName,name,noteId);
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate showNewWaitingIndicator:@"Uploading" displayProgressBar:YES];
	[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
	[request startAsynchronous];


}
-(void)fetchPlayerNoteListAsync{
    if([AppModel sharedAppModel].isGameNoteList)
    [self fetchGameNoteListAsynchronously:YES];
    else
    [self fetchPlayerNoteListAsynchronously:YES];
}
- (void)uploadNoteContentRequestFinished:(ASIFormDataRequest *)request
{
    NSString *response = [request responseString];
    
	NSLog(@"Model: Upload Note Content Request Finished. Response: %@", response);
	
	NSString *title = [[request userInfo] objectForKey:@"title"];
	//NSString *description = [[request userInfo] objectForKey:@"description"];
	NSNumber *nId = [[NSNumber alloc]initWithInt:5];
    nId = [[request userInfo] objectForKey:@"noteId"];
	//if (description == NULL) description = @"filename"; 
	int noteId = [nId intValue];

    NSString *type = [[request userInfo] objectForKey:@"type"];
    NSString *newFileName = [request responseString];
    
    NSString *localUrl = [[request userInfo] objectForKey:@"url"];
    [[AppModel sharedAppModel].uploadManager deleteContentFromNote:nId andFileURL:localUrl];
    
    

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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchPlayerNoteListAsync)]; 
	[jsonConnection release];
    
}

- (void)uploadNoteRequestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message: @"A network error occured while uploading the file" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[alert release];
    
    NSNumber *nId = [[NSNumber alloc]initWithInt:5];
    nId = [[request userInfo] objectForKey:@"noteId"];
	//if (description == NULL) description = @"filename"; 

    NSString *localUrl = [[request userInfo] objectForKey:@"url"];
    UploadContent *uploadContent =[[AppModel sharedAppModel].uploadManager.uploadContents objectForKey:localUrl];
    uploadContent.attemptfailed = [NSNumber numberWithBool:YES];
    [self sendNotificationToNoteViewer];
  }

- (void)createItemAndGiveToPlayerFromFileData:(NSData *)fileData fileName:(NSString *)fileName 
										title:(NSString *)title description:(NSString*)description {
    
	// setting up the request object now
    NSURL *url = [[AppModel sharedAppModel].serverURL URLByAppendingPathComponent:[NSString stringWithFormat: @"services/%@/uploadHandler.php",kARISServerServicePackage]];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.timeOutSeconds = 60;
	
 	[request setPostValue:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].currentGame.gameId] forKey:@"gameID"];	 
	[request setPostValue:fileName forKey:@"fileName"];
	[request setData:fileData forKey:@"file"];
	[request setDidFinishSelector:@selector(uploadItemRequestFinished:)];
	[request setDidFailSelector:@selector(uploadItemRequestFailed:)];
	[request setDelegate:self];
	
	//We need these after the upload is complete to create the item on the server
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", description, @"description", nil];
	[request setUserInfo:userInfo];
	
	NSLog(@"Model: Uploading File. gameID:%d fileName:%@ title:%@ description:%@",[AppModel sharedAppModel].currentGame.gameId,fileName,title,description );
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate showNewWaitingIndicator:@"Uploading" displayProgressBar:YES];
	[request setUploadProgressDelegate:appDelegate.waitingIndicator.progressView];
	[request startAsynchronous];
}
-(void)updateNoteWithNoteId:(int)noteId title:(NSString *)title publicToMap:(BOOL)publicToMap publicToList:(BOOL)publicToList{
    NSLog(@"Model: Updating Note");
	
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[jsonConnection release];

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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[jsonConnection release];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[jsonConnection release];
    
}
-(void)updateItem:(Item *)item {
    NSLog(@"Model: Updating Item");
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",item.itemId],
						  item.name,
						  item.description,
                          [NSString stringWithFormat:@"%d",item.iconMediaId],
						  [NSString stringWithFormat:@"%d",item.mediaId],
						  [NSString stringWithFormat:@"%d",item.dropable],
                          [NSString stringWithFormat:@"%d",item.destroyable],
						  [NSString stringWithFormat:@"%d",item.isAttribute],
						  [NSString stringWithFormat:@"%d",item.maxQty],
                          [NSString stringWithFormat:@"%d",item.weight],
						  item.url,
						  item.type,
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items" 
                                                             andMethodName:@"updateItem" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; //This is a cheat to make sure that the fetch Happens After 
	[jsonConnection release];

}

- (void)uploadImageForMatchingRequestFinished:(ASIFormDataRequest *)request
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
    
    [appDelegate showNewWaitingIndicator:@"Decoding Image" displayProgressBar:NO];
	
	NSString *response = [request responseString];
    
	NSLog(@"Model: uploadImageForMatchingRequestFinished: Upload Media Request Finished. Response: %@", response);
        
	NSString *newFileName = [request responseString];
    
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
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQRCodeObjectFromJSON:)]; 
	[jsonConnection release];
    
}


- (void)uploadItemForMapRequestFinished:(ASIFormDataRequest *)request
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
	
	NSString *response = [request responseString];
    
	NSLog(@"Model: Upload Media Request Finished. Response: %@", response);
	
	NSString *title = [[request userInfo] objectForKey:@"title"];
	NSString *description = [[request userInfo] objectForKey:@"description"];
	
	if (description == NULL) description = @""; 
	
	NSString *newFileName = [request responseString];
    
	NSLog(@"AppModel: Creating Item for Title:%@ Desc:%@ File:%@",title,description,newFileName);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  title, //[title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						  description, //[description stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						  newFileName,
						  @"1", //dropable
						  @"1", //destroyable
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          @"NORMAL",
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items" 
                                                             andMethodName:@"createItemAndPlaceOnMap" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}

- (void)uploadForMapRequestFailed:(ASIHTTPRequest *)request
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
	NSError *error = [request error];
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message: @"An network error occured while uploading the file" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[alert release];
}

- (void)uploadItemRequestFinished:(ASIFormDataRequest *)request
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
	
	NSString *response = [request responseString];
    
	NSLog(@"Model: Upload Media Request Finished. Response: %@", response);
	
	NSString *title = [[request userInfo] objectForKey:@"title"];
	NSString *description = [[request userInfo] objectForKey:@"description"];
	
	if (description == NULL) description = @""; 
	
	NSString *newFileName = [request responseString];
    
	NSLog(@"AppModel: Creating Item for Title:%@ Desc:%@ File:%@",title,description,newFileName);
	
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects:
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
						  title, //[title stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						  description, //[description stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						  newFileName,
						  @"1", //dropable
						  @"1", //destroyable
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          @"NORMAL",
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items" 
                                                             andMethodName:@"createItemAndGiveToPlayer" 
                                                              andArguments:arguments 
                                                               andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(fetchAllPlayerLists)]; 
	[jsonConnection release];
    
}

- (void)uploadRequestFailed:(ASIHTTPRequest *)request
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
	NSError *error = [request error];
	NSLog(@"Model: uploadRequestFailed: %@",[error localizedDescription]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Upload Failed" message: @"An network error occured while uploading the file" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[alert release];
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
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].currentGame.gameId],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
						  nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL 
                                                             andServiceName:@"players" 
                                                              andMethodName:@"updatePlayerLocation" 
                                                               andArguments:arguments 
                                                                andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseUpdateServerWithPlayerLocationFromJSON:)]; 
	[jsonConnection release];
	
}


- (void) silenceNextServerUpdate {
	NSLog(@"AppModel: silenceNextServerUpdate");
	
	NSNotification *notification = [NSNotification notificationWithName:@"SilentNextUpdate" object:nil];
	[[NSNotificationCenter defaultCenter] postNotification:notification];
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
                                                               andUserData:nil];
	JSONResult *jsonResult = [jsonConnection performSynchronousRequest]; 
	[jsonConnection release];
	
	
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

- (void)fetchAllGameLists {
	[self fetchGameItemListAsynchronously:YES];
	[self fetchGameNpcListAsynchronously:YES];
	[self fetchGameNodeListAsynchronously:YES];
	[self fetchGameMediaListAsynchronously:YES];
}

- (void)resetAllGameLists {
	NSLog(@"AppModel: resetAllGameLists");
    
	//Clear them out
	[AppModel sharedAppModel].gameItemList = [[NSMutableDictionary alloc] 
                         initWithCapacity:0];
	[AppModel sharedAppModel].gameNodeList = [[NSMutableDictionary alloc] 
                         initWithCapacity:0];
    [AppModel sharedAppModel].gameNpcList = [[NSMutableDictionary alloc] 
                        initWithCapacity:0];
    
}

- (void)fetchAllPlayerLists{
	[self fetchLocationList];
	[self fetchQuestList];
	[self fetchInventory];	
}

- (void)resetAllPlayerLists {
	NSLog(@"AppModel: resetAllPlayerLists");
    
	//Clear the Hashes
	[AppModel sharedAppModel].questListHash = @"";
	[AppModel sharedAppModel].inventoryHash = @"";
	[AppModel sharedAppModel].locationListHash = @"";
    [AppModel sharedAppModel].playerNoteListHash = @"";
    [AppModel sharedAppModel].gameNoteListHash = @"";
	//Clear them out
	[AppModel sharedAppModel].locationList = [[NSMutableArray alloc] initWithCapacity:0];
	[AppModel sharedAppModel].nearbyLocationsList = [[NSMutableArray alloc] initWithCapacity:0];
    
	NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
	NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
	NSMutableDictionary *tmpQuestList = [[NSMutableDictionary alloc] init];
	[tmpQuestList setObject:activeQuestObjects forKey:@"active"];
	[tmpQuestList setObject:completedQuestObjects forKey:@"completed"];
	[activeQuestObjects release];
	[completedQuestObjects release];
	[AppModel sharedAppModel].questList = tmpQuestList;
	[tmpQuestList release];
    
	
	[AppModel sharedAppModel].inventory = [[NSMutableDictionary alloc] initWithCapacity:10];
	
	//Tell the VCs
	[self silenceNextServerUpdate];
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLocationListReady" object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewQuestListReady" object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewInventoryReady" object:nil]];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedNearbyLocationList" object:nil]];
    
}

-(void)fetchTabBarItemsForGame:(int)gameId {
    NSLog(@"Fetching TabBar Items for game: %d",gameId);
    NSArray *arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],
						  nil];
    
    JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"games"
                                                             andMethodName:@"getTabBarItemsForGame"
                                                              andArguments:arguments andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTabListFromJSON:)]; 
	[jsonConnection release];

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
                                                              andArguments:arguments andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQRCodeObjectFromJSON:)]; 
	[jsonConnection release];
	
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
                                                              andArguments:arguments andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseConversationNodeOptionsFromJSON:)]; 
	[jsonConnection release];
    
}


- (void)fetchGameNpcListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Npc List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"npcs"
                                                             andMethodName:@"getNpcs"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNpcListFromJSON:)]; 
		[jsonConnection release];
	}
	else [self parseGameNpcListFromJSON: [jsonConnection performSynchronousRequest]];
    
	
}
- (void)fetchGameNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Game Note List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForGame"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNoteListFromJSON:)]; 
		[jsonConnection release];
	}
	else [self parseGameNoteListFromJSON: [jsonConnection performSynchronousRequest]];
    
	
}
- (void)fetchPlayerNoteListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Player Note List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getNotesForPlayer"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parsePlayerNoteListFromJSON:)]; 
		[jsonConnection release];
	}
	else [self parsePlayerNoteListFromJSON: [jsonConnection performSynchronousRequest]];
    
	
}

- (void)fetchGameWebpageListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Webpage List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"webpages"
                                                             andMethodName:@"getWebPages"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameWebPageListFromJSON:)]; 
		[jsonConnection release];
	}
	else [self parseGameWebPageListFromJSON: [jsonConnection performSynchronousRequest]];
    
	
}

- (void)fetchGameMediaListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Media List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"media"
                                                             andMethodName:@"getMedia"
                                                              andArguments:arguments andUserData:nil];
	
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameMediaListFromJSON:)];
		[jsonConnection release];
	}
	else [self parseGameMediaListFromJSON: [jsonConnection performSynchronousRequest]];
}

- (void)fetchGamePanoramicListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Panoramic List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
    
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"augbubbles"
                                                             andMethodName:@"getAugBubbles"
                                                              andArguments:arguments andUserData:nil];
	
	if (YesForAsyncOrNoForSync){
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGamePanoramicListFromJSON:)];
		[jsonConnection release];
	}
	else [self parseGamePanoramicListFromJSON: [jsonConnection performSynchronousRequest]];
}


- (void)fetchGameItemListAsynchronously:(BOOL)YesForAsyncOrNoForSync {
	NSLog(@"AppModel: Fetching Item List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"items"
                                                             andMethodName:@"getItems"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync) {
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameItemListFromJSON:)]; 
		[jsonConnection release];
	}
	else [self parseGameItemListFromJSON: [jsonConnection performSynchronousRequest]];
	
}



- (void)fetchGameNodeListAsynchronously:(BOOL)YesForAsyncOrNoForSync  {
	NSLog(@"AppModel: Fetching Node List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"nodes"
                                                             andMethodName:@"getNodes"
                                                              andArguments:arguments andUserData:nil];
	if (YesForAsyncOrNoForSync) {
		[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameNodeListFromJSON:)]; 
		[jsonConnection release];
	}
    
	else {
        JSONResult *result = [jsonConnection performSynchronousRequest];
        [self parseGameNodeListFromJSON: result];
    }
    
	
}
- (void)fetchGameTags{
	NSLog(@"AppModel: Fetching TAG List");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId], nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes"
                                                             andMethodName:@"getAllTagsInGame"
                                                              andArguments:arguments andUserData:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameTagsListFromJSON:)]; 
	[jsonConnection release];		
}
-(void)parseGameTagsListFromJSON:(JSONResult *)jsonResult{
    NSLog(@"AppModel: parseGameTagListFromJSON Beginning");		
    
    NSArray *gameTagsArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *tempTagsList = [[NSMutableArray alloc] initWithCapacity:10];
	
	NSEnumerator *gameTagEnumerator = [gameTagsArray objectEnumerator];	
	NSDictionary *tagDictionary;
	while ((tagDictionary = [gameTagEnumerator nextObject])) {
        Tag *t = [[Tag alloc]init];
        t.tagName = [tagDictionary objectForKey:@"tag"];
        t.playerCreated = [[tagDictionary objectForKey:@"player_created"]boolValue];
		[tempTagsList addObject:t]; 
	}
    
	[AppModel sharedAppModel].gameTagList = tempTagsList;
	[tempTagsList release];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];	
    

}
-(void)addTagToNote:(int)noteId tagName:(NSString *)tag{
    NSLog(@"AppModel: Adding Tag to note");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],[NSString stringWithFormat:@"%d",[AppModel sharedAppModel].currentGame.gameId],tag, nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes"
                                                             andMethodName:@"addTagToNote"
                                                              andArguments:arguments andUserData:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNotebookViewer)]; 
	[jsonConnection release];		

}

-(void)deleteTagFromNote:(int)noteId tagName:(NSString *)tag{
    NSLog(@"AppModel: Deleting tag from note");
	
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",noteId],tag, nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"notes"
                                                             andMethodName:@"deleteTagFromNote"
                                                              andArguments:arguments andUserData:nil];
    [jsonConnection performAsynchronousRequestWithHandler:@selector(sendNotificationToNotebookViewer)]; 
	[jsonConnection release];		

}

- (void)fetchLocationList {
	NSLog(@"AppModel: Fetching Locations from Server");	
	
	if (![AppModel sharedAppModel].loggedIn) {
		NSLog(@"AppModel: Player Not logged in yet, skip the location fetch");	
		return;
	}
    
    if (currentlyFetchingLocationList) {
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
                                                              andArguments:arguments andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseLocationListFromJSON:)]; 
	[jsonConnection release];
	
}

- (void)forceUpdateOnNextLocationListFetch {
	[AppModel sharedAppModel].locationListHash = @"";
}

- (void)fetchInventory {
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
                                                              andArguments:arguments andUserData:nil];
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseInventoryFromJSON:)]; 
	[jsonConnection release];
	
}

-(void)fetchGameListBySearch:(NSString *)searchText{
    NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: 
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
						  searchText,
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"games"
                                                             andMethodName:@"getGamesContainingText"
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameListFromJSON:)]; 
	[jsonConnection release];
}








-(void)fetchMiniGamesListLocations{
    NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: 
                          [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"games"
                                                             andMethodName:@"getGamesWithLocations"
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameListFromJSON:)]; 
	[jsonConnection release];
}






-(void)fetchQuestList {
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
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseQuestListFromJSON:)]; 
	[jsonConnection release];
	
}

- (void)fetchGameListWithDistanceFilter: (int)distanceInMeters locational:(BOOL)locationalOrNonLocational {
	NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingGamesList = YES;
    
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
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameListFromJSON:)]; 
	[jsonConnection release];
}


- (void)fetchOneGame:(int)gameId {
    NSLog(@"AppModel: Fetch Requested for a single game (as Game List).");
    
    if (currentlyFetchingGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingGamesList = YES;
    
	//Call server service
	NSArray *arguments = [NSArray arrayWithObjects: 
                          [NSString stringWithFormat:@"%d",gameId],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].playerId],
                          [NSString stringWithFormat:@"%d",1],
                          [NSString stringWithFormat:@"%d",9999999999],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.latitude],
						  [NSString stringWithFormat:@"%f",[AppModel sharedAppModel].playerLocation.coordinate.longitude],
                          [NSString stringWithFormat:@"%d",[AppModel sharedAppModel].showGamesInDevelopment],
						  nil];
	
	JSONConnection *jsonConnection = [[JSONConnection alloc]initWithServer:[AppModel sharedAppModel].serverURL 
                                                            andServiceName:@"games"
                                                             andMethodName:@"getOneGame"
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseGameListFromJSON:)]; 
	[jsonConnection release];
}


- (void)fetchRecentGameListForPlayer  {
	NSLog(@"AppModel: Fetch Requested for Game List.");
    
    if (currentlyFetchingGamesList) {
        NSLog(@"AppModel: Already fetching Games list, skipping");
        return;
    }
    
    currentlyFetchingGamesList = YES;
    
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
                                                              andArguments:arguments andUserData:nil];
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseRecentGameListFromJSON:)]; 
	[jsonConnection release];
}



#pragma mark Parsers
- (NSInteger) validIntForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return [theObject respondsToSelector:@selector(intValue)] ? [theObject intValue] : kEmptyValue;
}

- (id) validObjectForKey:(NSString *const)aKey inDictionary:(NSDictionary *const)aDictionary {
	id theObject = [aDictionary valueForKey:aKey];
	return theObject == [NSNull null] ? nil : theObject;
}

-(Item *)parseItemFromDictionary: (NSDictionary *)itemDictionary{	
	Item *item = [[[Item alloc] init] autorelease];
	item.itemId = [[itemDictionary valueForKey:@"item_id"] intValue];
	item.name = [itemDictionary valueForKey:@"name"];
	item.description = [itemDictionary valueForKey:@"description"];
	item.mediaId = [[itemDictionary valueForKey:@"media_id"] intValue];
	item.iconMediaId = [[itemDictionary valueForKey:@"icon_media_id"] intValue];
	item.dropable = [[itemDictionary valueForKey:@"dropable"] boolValue];
	item.destroyable = [[itemDictionary valueForKey:@"destroyable"] boolValue];
	item.maxQty = [[itemDictionary valueForKey:@"max_qty_in_inventory"] intValue];
    item.isAttribute = [[itemDictionary valueForKey:@"is_attribute"] boolValue];
    item.weight = [[itemDictionary valueForKey:@"weight"] intValue];
    item.url = [itemDictionary valueForKey:@"url"];
	item.type = [itemDictionary valueForKey:@"type"];
    item.creatorId = [[itemDictionary valueForKey:@"creator_player_id"] intValue];
	NSLog(@"\tadded item %@", item.name);
	
	return item;	
}
-(Node *)parseNodeFromDictionary: (NSDictionary *)nodeDictionary{
	//Build the node
	NSLog(@"%@", nodeDictionary);
	Node *node = [[[Node alloc] init] autorelease];
	node.nodeId = [[nodeDictionary valueForKey:@"node_id"] intValue];
	node.name = [nodeDictionary valueForKey:@"title"];
	node.text = [nodeDictionary valueForKey:@"text"];
	NSLog(@"%@", [nodeDictionary valueForKey:@"media_id"]);
	node.mediaId = [self validIntForKey:@"media_id" inDictionary:nodeDictionary];
	node.iconMediaId = [self validIntForKey:@"icon_media_id" inDictionary:nodeDictionary];
	node.answerString = [self validObjectForKey:@"require_answer_string" inDictionary:nodeDictionary];
	node.nodeIfCorrect = [self validIntForKey:@"require_answer_correct_node_id" inDictionary:nodeDictionary];
	node.nodeIfIncorrect = [self validIntForKey:@"require_answer_incorrect_node_id" inDictionary:nodeDictionary];
	
	//Add options here
	int optionNodeId;
	NSString *text;
	NodeOption *option;
	
	if ([nodeDictionary valueForKey:@"opt1_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt1_node_id"] intValue] > 0) {
		optionNodeId= [[nodeDictionary valueForKey:@"opt1_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt1_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
		[option release];
	}
	if ([nodeDictionary valueForKey:@"opt2_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt2_node_id"] intValue] > 0) {
		optionNodeId = [[nodeDictionary valueForKey:@"opt2_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt2_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
		[option release];
	}
	if ([nodeDictionary valueForKey:@"opt3_node_id"] != [NSNull null] && [[nodeDictionary valueForKey:@"opt3_node_id"] intValue] > 0) {
		optionNodeId = [[nodeDictionary valueForKey:@"opt3_node_id"] intValue];
		text = [nodeDictionary valueForKey:@"opt3_text"]; 
		option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId];
		[node addOption:option];
		[option release];
	}
	
	
	return node;	
}
-(Note *)parseNoteFromDictionary: (NSDictionary *)noteDictionary {
	Note *aNote = [[[Note alloc] init] autorelease];
	aNote.noteId = [[noteDictionary valueForKey:@"note_id"] intValue];
	aNote.title = [noteDictionary valueForKey:@"title"];
	aNote.text = [noteDictionary valueForKey:@"text"];    
    aNote.averageRating = [[noteDictionary valueForKey:@"ave_rating"] floatValue];
    aNote.parentNoteId = [[noteDictionary valueForKey:@"parent_note_id"] intValue];
    aNote.parentRating = [[noteDictionary valueForKey:@"parent_rating"]intValue];
    aNote.numRatings = [[noteDictionary valueForKey:@"likes"]intValue];
    aNote.creatorId = [[noteDictionary valueForKey:@"owner_id"]intValue];
    aNote.showOnMap = [[noteDictionary valueForKey:@"public_to_map"]boolValue];
    aNote.showOnList = [[noteDictionary valueForKey:@"public_to_notebook"]boolValue];
    aNote.userLiked = [[noteDictionary valueForKey:@"player_liked"]boolValue];
    aNote.username = [noteDictionary valueForKey:@"username"];
    aNote.dropped = [[noteDictionary valueForKey:@"dropped"]boolValue];
    
    NSArray *comments = [noteDictionary valueForKey:@"comments"];
    NSEnumerator *enumerator = [((NSArray *)comments) objectEnumerator];
	NSDictionary *dict;
    while ((dict = [enumerator nextObject])) {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        //TODO: Create a Comments object
        Note *c = [[Note alloc] init];
        c = [self parseNoteFromDictionary:dict];
        [aNote.comments addObject:c];
    }
    
    NSArray *contents = [noteDictionary valueForKey:@"contents"];
    for (NSDictionary *content in contents) {
 
        NoteContent *c = [[NoteContent alloc] init];
        c.text = [content objectForKey:@"text"];
        c.title = [content objectForKey:@"title"];
        c.contentId = [[content objectForKey:@"content_id"]intValue];
        c.mediaId = [[content objectForKey:@"media_id"]intValue];
        c.noteId = [[content objectForKey:@"note_id"]intValue];
        c.sortIndex =[[content objectForKey:@"sort_index"]intValue];
        c.type = [content objectForKey:@"type"];
        [aNote.contents addObject:c];
    }
    
    NSArray *tags = [noteDictionary valueForKey:@"tags"];
    for (NSDictionary *tagOb in tags) {
        
        Tag *tag = [[Tag alloc] init];
        tag.tagName = [tagOb objectForKey:@"tag"];
        tag.playerCreated = [[tagOb objectForKey:@"player_created"]boolValue];
        [aNote.tags addObject:tag];
    }
	NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"noteId"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    aNote.comments = [[aNote.comments sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
	return aNote;	
}

-(Npc *)parseNpcFromDictionary: (NSDictionary *)npcDictionary {
	Npc *npc = [[[Npc alloc] init] autorelease];
	npc.npcId = [[npcDictionary valueForKey:@"npc_id"] intValue];
	npc.name = [npcDictionary valueForKey:@"name"];
	npc.greeting = [npcDictionary valueForKey:@"text"];
	
	npc.closing = [npcDictionary valueForKey:@"closing"];
	if ((NSNull *)npc.closing == [NSNull null]) npc.closing = @"";
    
	npc.description = [npcDictionary valueForKey:@"description"];
	npc.mediaId = [[npcDictionary valueForKey:@"media_id"] intValue];
	npc.iconMediaId = [[npcDictionary valueForKey:@"icon_media_id"] intValue];
    
	return npc;	
}

- (Tab *)parseTabFromDictionary:(NSDictionary *)tabDictionary{
    Tab *tab = [[[Tab alloc] init] autorelease];
    tab.tabName = [tabDictionary valueForKey:@"tab"];
    tab.tabIndex = [[tabDictionary valueForKey:@"tab_index"] intValue];
    return tab;
}

-(WebPage *)parseWebPageFromDictionary: (NSDictionary *)webPageDictionary {
	WebPage *webPage = [[[WebPage alloc] init] autorelease];
	webPage.webPageId = [[webPageDictionary valueForKey:@"web_page_id"] intValue];
	webPage.name = [webPageDictionary valueForKey:@"name"];
	webPage.url = [webPageDictionary valueForKey:@"url"];    
	webPage.iconMediaId = [[webPageDictionary valueForKey:@"icon_media_id"] intValue];
    
	return webPage;	
}

-(Panoramic *)parsePanoramicFromDictionary: (NSDictionary *)panoramicDictionary {
	Panoramic *pan = [[[Panoramic alloc] init] autorelease];
    pan.panoramicId  = [[panoramicDictionary valueForKey:@"aug_bubble_id"] intValue];
    pan.name = [panoramicDictionary valueForKey:@"name"];
	pan.description = [panoramicDictionary valueForKey:@"description"];    
    pan.alignMediaId = [[panoramicDictionary valueForKey:@"alignment_media_id"] intValue];
    pan.iconMediaId = [[panoramicDictionary valueForKey:@"icon_media_id"] intValue];
    
    
    
    /*NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
     NSArray *activeQuests = [questListDictionary objectForKey:@"active"];
     NSEnumerator *activeQuestsEnumerator = [activeQuests objectEnumerator];
     NSDictionary *activeQuest;
     while ((activeQuest = [activeQuestsEnumerator nextObject])) {
     //We have a quest, parse it into a quest abject and add it to the activeQuestObjects array
     Quest *quest = [[Quest alloc] init];
     quest.questId = [[activeQuest objectForKey:@"quest_id"] intValue];
     quest.name = [activeQuest objectForKey:@"name"];
     quest.description = [activeQuest objectForKey:@"description"];
     quest.iconMediaId = [[activeQuest objectForKey:@"icon_media_id"] intValue];
     [activeQuestObjects addObject:quest];
     [quest release];
     }
     */
    
    
    //parse out the active quests into quest objects
	NSMutableArray *media = [[NSMutableArray alloc] init];
	NSArray *incomingPanMediaArray = [panoramicDictionary objectForKey:@"media"];
	NSEnumerator *incomingPanMediaEnumerator = [incomingPanMediaArray objectEnumerator];
    NSDictionary* currentPanMediaDictionary;
	while (currentPanMediaDictionary = (NSDictionary*)[incomingPanMediaEnumerator nextObject]) {
        PanoramicMedia *pm = [[PanoramicMedia alloc]init];
        pm.text = [currentPanMediaDictionary objectForKey:@"text"];
        if ([currentPanMediaDictionary objectForKey:@"media_id"] != [NSNull null] && [[currentPanMediaDictionary objectForKey:@"media_id"] intValue] > 0)
            pm.mediaId = [[currentPanMediaDictionary objectForKey:@"media_id"] intValue];
		[media addObject:pm];
		[pm release];
	}
    
    pan.media = [NSArray arrayWithArray: media];
    [media release];

	return pan;	
}
-(void)parseGameNoteListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"Parsing Game Note List");

    if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].gameNoteListHash]) {
		NSLog(@"AppModel: Hash is same as last game note list update, continue");
		return;
	}
	
	//Save this hash for later comparisions
	[AppModel sharedAppModel].gameNoteListHash = [jsonResult.hash copy];
    
    
	NSArray *noteListArray = (NSArray *)jsonResult.data;
    NSMutableDictionary *tempNoteList = [[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedNoteList" object:nil]];
	//NSMutableArray *tempNoteList = [[NSMutableArray alloc] initWithCapacity:10];
	NSEnumerator *enumerator = [((NSArray *)noteListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
        Note *tmpNote = [self parseNoteFromDictionary:dict];
        [tempNoteList setObject:tmpNote forKey:[NSNumber numberWithInt:tmpNote.noteId]];
	}
    /*NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"noteId"
                                                  ascending:NO] autorelease];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    
    tempNoteList = [tempNoteList sortedArrayUsingDescriptors:sortDescriptors];*/
	[AppModel sharedAppModel].gameNoteList = tempNoteList;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewNoteListReady" object:nil]];
    NSLog(@"DONE Parsing Game Note List");

	//[tempNoteList release];
}

-(void)parsePlayerNoteListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"Parsing Player Note List");
    if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].playerNoteListHash]) {
		NSLog(@"AppModel: Hash is same as last player note list update, continue");
		return;
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
	[tempNoteList release];
    NSLog(@"DONE Parsing Player Note List");

}
-(void)parseConversationNodeOptionsFromJSON: (JSONResult *)jsonResult {
	
    [self fetchInventory];
    [self fetchQuestList];
    
    NSArray *conversationOptionsArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *conversationNodeOptions = [[NSMutableArray alloc] initWithCapacity:3];
	
	NSEnumerator *conversationOptionsEnumerator = [conversationOptionsArray objectEnumerator];
	NSDictionary *conversationDictionary;
	
	while ((conversationDictionary = [conversationOptionsEnumerator nextObject])) {	
		//Make the Node Option and add it to the Npc
		int optionNodeId = [[conversationDictionary valueForKey:@"node_id"] intValue];
		NSString *text = [conversationDictionary valueForKey:@"text"]; 
        BOOL hasViewed = [[conversationDictionary valueForKey:@"has_viewed"] boolValue];
		NodeOption *option = [[NodeOption alloc] initWithText:text andNodeId: optionNodeId andHasViewed:hasViewed];
		[conversationNodeOptions addObject:option];
		[option release];
	}
	
	//return conversationNodeOptions;
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConversationNodeOptionsReady" object:conversationNodeOptions]];
	
}

-(void)parseLoginResponseFromJSON: (JSONResult *)jsonResult{
	NSLog(@"AppModel: parseLoginResponseFromJSON");
	
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate removeNewWaitingIndicator];
    
	if ((NSNull *)jsonResult.data != [NSNull null] && jsonResult.data != nil) {
		[AppModel sharedAppModel].loggedIn = YES;
		[AppModel sharedAppModel].playerId = [((NSDecimalNumber*)jsonResult.data) intValue];
        [[AppServices sharedAppServices]setShowPlayerOnMap];

	}
	else {
		[AppModel sharedAppModel].loggedIn = NO;	
	}
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLoginResponseReady" object:nil]];
}



-(void)parseSelfRegistrationResponseFromJSON: (JSONResult *)jsonResult{
    
	
	if (!jsonResult) {
		NSLog(@"AppModel registerNewUser: No result Data, return");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationFailed" object:nil]];
	}
    
    int newId = [(NSDecimalNumber*)jsonResult.data intValue];
    
	if (newId > 0) {
		NSLog(@"AppModel: Result from new user request successfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationSucceeded" object:nil]];
	}
	else { 
		NSLog(@"AppModel: Result from new user request unsuccessfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SelfRegistrationFailed" object:nil]];
	}
}

- (Game *)parseGame:(NSDictionary *)gameSource {
    //create a new game
    Game *game = [[[Game alloc] init]autorelease];
    
    game.gameId = [[gameSource valueForKey:@"game_id"] intValue];
    //NSLog(@"AppModel: Parsing Game: %d", game.gameId);		
    
    game.name = [gameSource valueForKey:@"name"];
    if ((NSNull *)game.name == [NSNull null]) game.name = @"";
    
    NSString *isLocational = [gameSource valueForKey:@"is_locational"];
    if ((NSNull *)isLocational != [NSNull null]) game.isLocational = [isLocational boolValue];
    else game.isLocational = NO;

    NSString *inventoryWC = [gameSource valueForKey:@"inventory_weight_cap"];
    if ((NSNull *)inventoryWC != [NSNull null]) game.inventoryWeightCap = [inventoryWC intValue];
    else game.inventoryWeightCap = 0;
    
    game.description = [gameSource valueForKey:@"description"];
    if ((NSNull *)game.description == [NSNull null]) game.description = @"";
    
    NSString *rating = [gameSource valueForKey:@"rating"];
    if ((NSNull *)rating != [NSNull null]) game.rating = [rating intValue];
    else game.rating = 0;
    
    NSString *pc_media_id = [gameSource valueForKey:@"pc_media_id"];
    if ((NSNull *)pc_media_id != [NSNull null]) game.pcMediaId = [pc_media_id intValue];
    else game.pcMediaId = 0;
    
    NSString *distance = [gameSource valueForKey:@"distance"];
    if ((NSNull *)distance != [NSNull null]) game.distanceFromPlayer = [distance doubleValue];
    else game.distanceFromPlayer = 999999999;
    
    NSString *latitude = [gameSource valueForKey:@"latitude"];
    NSString *longitude = [gameSource valueForKey:@"longitude"];
    if ((NSNull *)latitude != [NSNull null] && (NSNull *)longitude != [NSNull null] )
        game.location = [[[CLLocation alloc] initWithLatitude:[latitude doubleValue]
                                                    longitude:[longitude doubleValue]] autorelease];
    else game.location = [[CLLocation alloc] init];
    
    game.authors = [gameSource valueForKey:@"editors"];
    if ((NSNull *)game.authors == [NSNull null]) game.authors = @"";
    
    NSString *numPlayers = [gameSource valueForKey:@"numPlayers"];
    if ((NSNull *)numPlayers != [NSNull null]) game.numPlayers = [numPlayers intValue];
    else game.numPlayers = 0;
    
    game.iconMediaUrl = [gameSource valueForKey:@"icon_media_url"];
    
    game.mediaUrl = [gameSource valueForKey:@"media_url"];	
    
    NSString *completedQuests = [gameSource valueForKey:@"completedQuests"];	
    if ((NSNull *)completedQuests != [NSNull null]) game.completedQuests = [completedQuests intValue];
    else game.completedQuests = 0;
    
    NSString *totalQuests = [gameSource valueForKey:@"totalQuests"];
    if ((NSNull *)totalQuests != [NSNull null]) game.totalQuests = [totalQuests intValue];
    else game.totalQuests = 1;
    
    NSString *on_launch_node_id = [gameSource valueForKey:@"on_launch_node_id"];
    if ((NSNull *)on_launch_node_id != [NSNull null]) game.launchNodeId = [on_launch_node_id intValue];
    else game.launchNodeId = 0;
    
    NSString *game_complete_node_id = [gameSource valueForKey:@"game_complete_node_id"];
    if ((NSNull *)game_complete_node_id != [NSNull null]) game.completeNodeId = [game_complete_node_id intValue];
    else game.completeNodeId = 0;
    
    NSString *calculatedScore = [gameSource valueForKey:@"calculatedScore"];
    if ((NSNull *)calculatedScore != [NSNull null]) game.calculatedScore = [calculatedScore intValue];
    
    NSString *numComments = [gameSource valueForKey:@"numComments"];
    if ((NSNull *)numComments != [NSNull null]) game.numReviews = [numComments intValue];
    
    game.allowsPlayerTags = [[gameSource valueForKey:@"allow_player_tags"]boolValue];

    NSArray *comments = [gameSource valueForKey:@"comments"];
    for (NSDictionary *comment in comments) {
        //This is returning an object with playerId,tex, and rating. Right now, we just want the text
        //TODO: Create a Comments object
        Comment *c = [[Comment alloc] init];
        c.text = [comment objectForKey:@"text"];
        c.playerName = [comment objectForKey:@"username"];
        NSString *cRating = [comment objectForKey:@"rating"];
        if ((NSNull *)cRating != [NSNull null]) c.rating = [cRating intValue];
        [game.comments addObject:c];
    }
    
    
    //NSLog(@"Model: Adding Game: %@", game.name);
    return game;
}

-(void)parseGameListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"AppModel: parseGameListFromJSON Beginning");		
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedGameList" object:nil]];
    
	NSArray *gameListArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
	
	NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];	
	NSDictionary *gameDictionary;
	while ((gameDictionary = [gameListEnumerator nextObject])) {
		[tempGameList addObject:[self parseGame:(gameDictionary)]]; 
	}
    
	[AppModel sharedAppModel].gameList = tempGameList;
	[tempGameList release];
    
    NSLog(@"AppModel: parseGameListFromJSON Complete, sending notification");
    
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewGameListReady" object:nil]];
    currentlyFetchingGamesList = NO;

    
}

-(void)parseRecentGameListFromJSON: (JSONResult *)jsonResult{
    NSLog(@"AppModel: parseGameListFromJSON Beginning");		
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RecievedGameList" object:nil]];
    
	NSArray *gameListArray = (NSArray *)jsonResult.data;
	
	NSMutableArray *tempGameList = [[NSMutableArray alloc] init];
	
	NSEnumerator *gameListEnumerator = [gameListArray objectEnumerator];	
	NSDictionary *gameDictionary;
	while ((gameDictionary = [gameListEnumerator nextObject])) {
		[tempGameList addObject:[self parseGame:(gameDictionary)]]; 
	}
    
	[AppModel sharedAppModel].recentGameList = tempGameList;
	[tempGameList release];
    
    NSLog(@"AppModel: parseGameListFromJSON Complete, sending notification");
    
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewRecentGameListReady" object:nil]];
    currentlyFetchingGamesList = NO;
    
    
}



- (void)saveComment:(NSString*)comment game:(int)gameId starRating:(int)rating{
	NSLog(@"AppModel: Save Comment Requested");
	NSArray *arguments = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", [AppModel sharedAppModel].playerId], [NSString stringWithFormat:@"%d", gameId], [NSString stringWithFormat:@"%d", rating], comment, nil];
	JSONConnection *jsonConnection = [[JSONConnection alloc] initWithServer:[AppModel sharedAppModel].serverURL 
                                                             andServiceName: @"games" 
                                                              andMethodName:@"saveComment"
                                                               andArguments:arguments andUserData:nil]; 
	
	[jsonConnection performAsynchronousRequestWithHandler:@selector(parseSaveCommentResponseFromJSON:)]; 
	[jsonConnection release];
	
}

- (void)parseSaveCommentResponseFromJSON: (JSONResult *)jsonResult{
	
	if (!jsonResult) {
		NSLog(@"AppModel saveComment: No result Data, return");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SaveCommentFailed" object:nil]];
	}
	else { 
		NSLog(@"AppModel: Result from save comment request unsuccessfull");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"SaveCommentFailed" object:nil]];
	}
}

- (void)parseLocationListFromJSON: (JSONResult *)jsonResult{
    
	NSLog(@"AppModel: Parsing Location List");
	
    currentlyFetchingLocationList = NO;
    
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedLocationList" object:nil]];
    
	//Check for an error
	
	//Compare this hash to the last one. If the same, stop hee
	
	if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].locationListHash]) {
		NSLog(@"AppModel: Hash is same as last location list update, continue");
		return;
	}
    
	//Save this hash for later comparisions
	[AppModel sharedAppModel].locationListHash = [jsonResult.hash copy];
	
	//Continue parsing
	NSArray *locationsArray = (NSArray *)jsonResult.data;
	
	
	//Build the location list
	NSMutableArray *tempLocationsList = [[NSMutableArray alloc] init];
	NSEnumerator *locationsEnumerator = [locationsArray objectEnumerator];	
	NSDictionary *locationDictionary;
	while ((locationDictionary = [locationsEnumerator nextObject])) {
		//create a new location
        Location *location = [self parseLocationFromDictionary:locationDictionary];
		
		NSLog(@"AppServices: Adding Location: %@ - Type:%@ Id:%d Hidden:%d ForceDisp:%d QuickTravel:%d Qty:%d", 
			  location.name, location.objectType, location.objectId, 
			  location.hidden, location.forcedDisplay, location.allowsQuickTravel, location.qty);
		[tempLocationsList addObject:location];
		[location release];
	}
	
	[AppModel sharedAppModel].locationList = tempLocationsList;
	[tempLocationsList release];
	
	//Tell everyone
	NSLog(@"AppServices: Finished fetching locations from server, model updated");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewLocationListReady" object:nil]];
	
}


-(Location*)parseLocationFromDictionary: (NSDictionary*)locationDictionary {
    NSLog(@"AppServices: parseLocationFromDictionary");

    Location *location = [[Location alloc] init];
    location.locationId = [[locationDictionary valueForKey:@"location_id"] intValue];
    location.name = [locationDictionary valueForKey:@"name"];
    location.iconMediaId = [[locationDictionary valueForKey:@"icon_media_id"] intValue];
    CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:[[locationDictionary valueForKey:@"latitude"] doubleValue]
                                                         longitude:[[locationDictionary valueForKey:@"longitude"] doubleValue]];
    location.location = tmpLocation;
    [tmpLocation release];
    location.error = [[locationDictionary valueForKey:@"error"] doubleValue];
    location.objectType = [locationDictionary valueForKey:@"type"];
    location.objectId = [[locationDictionary valueForKey:@"type_id"] intValue];
    location.hidden = [[locationDictionary valueForKey:@"hidden"] boolValue];
    location.forcedDisplay = [[locationDictionary valueForKey:@"force_view"] boolValue];
    location.allowsQuickTravel = [[locationDictionary valueForKey:@"allow_quick_travel"] boolValue];
    location.qty = [[locationDictionary valueForKey:@"item_qty"] intValue];
    
    return location;
}


-(void)parseGameMediaListFromJSON: (JSONResult *)jsonResult{
    
	NSArray *mediaListArray = (NSArray *)jsonResult.data;
    
	NSMutableDictionary *tempMediaList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [mediaListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		NSInteger uid = [[dict valueForKey:@"media_id"] intValue];
		NSString *fileName = [dict valueForKey:@"file_name"];
		NSString *urlPath = [dict valueForKey:@"url_path"];
        
		NSString *type = [dict valueForKey:@"type"];
		
		if (uid < 1) {
			NSLog(@"AppModel fetchGameMediaList: Invalid media id: %d", uid);
			continue;
		}
		if ([fileName length] < 1) {
			NSLog(@"AppModel fetchGameMediaList: Empty fileName string for media #%d.", uid);
			continue;
		}
		if ([type length] < 1) {
			NSLog(@"AppModel fetchGameMediaList: Empty type for media #%d", uid);
			continue;
		}
		
		
		NSString *fullUrl = [NSString stringWithFormat:@"%@%@", urlPath, fileName];
		NSLog(@"AppModel fetchGameMediaList: Full URL: %@", fullUrl);
		
		Media *media = [[Media alloc] initWithId:uid andUrlString:fullUrl ofType:type];
		[tempMediaList setObject:media forKey:[NSNumber numberWithInt:uid]];
		[media release];
	}
	
	[AppModel sharedAppModel].gameMediaList = tempMediaList;
	[tempMediaList release];
}


-(void)parseGameItemListFromJSON: (JSONResult *)jsonResult{
	NSArray *itemListArray = (NSArray *)jsonResult.data;
    
	NSMutableDictionary *tempItemList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [itemListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Item *tmpItem = [self parseItemFromDictionary:dict];
		
		[tempItemList setObject:tmpItem forKey:[NSNumber numberWithInt:tmpItem.itemId]];
		//[item release];
	}
	
	[AppModel sharedAppModel].gameItemList = tempItemList;
	[tempItemList release];
}


-(void)parseGameNodeListFromJSON: (JSONResult *)jsonResult{
	NSArray *nodeListArray = (NSArray *)jsonResult.data;
	NSMutableDictionary *tempNodeList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [nodeListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Node *tmpNode = [self parseNodeFromDictionary:dict];
		
		[tempNodeList setObject:tmpNode forKey:[NSNumber numberWithInt:tmpNode.nodeId]];
		//[node release];
	}
	
	[AppModel sharedAppModel].gameNodeList = tempNodeList;
	[tempNodeList release];
}

-(void)parseGameTabListFromJSON: (JSONResult *)jsonResult{
	NSArray *tabListArray = (NSArray *)jsonResult.data;
	NSArray *tempTabList = [[NSMutableArray alloc] initWithCapacity:10];
	NSEnumerator *enumerator = [tabListArray objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Tab *tmpTab = [self parseTabFromDictionary:dict];
		tempTabList = [tempTabList arrayByAddingObject:tmpTab];
		//[node release];
	}
	
	[AppModel sharedAppModel].gameTabList = tempTabList;
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate changeTabBar];
	//[tempTabList release];
}


-(void)parseGameNpcListFromJSON: (JSONResult *)jsonResult{
	NSArray *npcListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempNpcList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)npcListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Npc *tmpNpc = [self parseNpcFromDictionary:dict];
		
		[tempNpcList setObject:tmpNpc forKey:[NSNumber numberWithInt:tmpNpc.npcId]];
	}
	
	[AppModel sharedAppModel].gameNpcList = tempNpcList;
	[tempNpcList release];
}

-(void)parseGameWebPageListFromJSON: (JSONResult *)jsonResult{
	NSArray *webpageListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempWebPageList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)webpageListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		WebPage *tmpWebpage = [self parseWebPageFromDictionary:dict];
		
		[tempWebPageList setObject:tmpWebpage forKey:[NSNumber numberWithInt:tmpWebpage.webPageId]];
	}
	
	[AppModel sharedAppModel].gameWebPageList = tempWebPageList;
	[tempWebPageList release];
}
-(void)parseGamePanoramicListFromJSON: (JSONResult *)jsonResult{
	NSArray *panListArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempPanoramicList = [[NSMutableDictionary alloc] init];
	NSEnumerator *enumerator = [((NSArray *)panListArray) objectEnumerator];
	NSDictionary *dict;
	while ((dict = [enumerator nextObject])) {
		Panoramic *tmpPan = [self parsePanoramicFromDictionary:dict];
		
		[tempPanoramicList setObject:tmpPan forKey:[NSNumber numberWithInt:tmpPan.panoramicId]];
	}
	
	[AppModel sharedAppModel].gamePanoramicList = tempPanoramicList;
	[tempPanoramicList release];
}


-(void)parseInventoryFromJSON: (JSONResult *)jsonResult{
	NSLog(@"AppModel: Parsing Inventory");
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedInventory" object:nil]];
    
    currentlyFetchingInventory = NO;
    
    
	//Check for an error
	
	//Compare this hash to the last one. If the same, stop hee	
	
    
	if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].inventoryHash]) {
		NSLog(@"AppModel: Hash is same as last inventory listy update, continue");
		return;
	}
	
	
	//Save this hash for later comparisions
	[AppModel sharedAppModel].inventoryHash = [jsonResult.hash copy];
	
	//Continue parsing
	NSArray *inventoryArray = (NSArray *)jsonResult.data;
	
	NSMutableDictionary *tempInventory = [[NSMutableDictionary alloc] initWithCapacity:10];
    NSMutableDictionary *tempAttributes = [[NSMutableDictionary alloc] initWithCapacity:10];

	NSEnumerator *inventoryEnumerator = [((NSArray *)inventoryArray) objectEnumerator];	
	NSDictionary *itemDictionary;
	while ((itemDictionary = [inventoryEnumerator nextObject])) {
		Item *item = [[Item alloc] init];
		item.itemId = [[itemDictionary valueForKey:@"item_id"] intValue];
		item.name = [itemDictionary valueForKey:@"name"];
		item.description = [itemDictionary valueForKey:@"description"];
		item.mediaId = [[itemDictionary valueForKey:@"media_id"] intValue];
		item.iconMediaId = [[itemDictionary valueForKey:@"icon_media_id"] intValue];
		item.dropable = [[itemDictionary valueForKey:@"dropable"] boolValue];
		item.destroyable = [[itemDictionary valueForKey:@"destroyable"] boolValue];
		item.qty = [[itemDictionary valueForKey:@"qty"] intValue];
        item.isAttribute = [[itemDictionary valueForKey:@"is_attribute"] boolValue];
        item.weight = [[itemDictionary valueForKey:@"weight"] intValue];
        item.url = [itemDictionary valueForKey:@"url"];
        item.type = [itemDictionary valueForKey:@"type"];
        item.creatorId = [[itemDictionary valueForKey:@"creator_player_id"] intValue];
		NSLog(@"Model: Adding Item: %@", item.name);
        if(item.isAttribute)[tempAttributes setObject:item forKey:[NSString stringWithFormat:@"%d",item.itemId]]; 
            else [tempInventory setObject:item forKey:[NSString stringWithFormat:@"%d",item.itemId]]; 
		[item release];
	}
    
    
        
	[AppModel sharedAppModel].inventory = tempInventory;
    [AppModel sharedAppModel].attributes = tempAttributes;
    [tempAttributes release];
	[tempInventory release];
	
	NSLog(@"AppModel: Finished fetching inventory from server, model updated");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewInventoryReady" object:nil]];
	
	//Note: The inventory list VC listener will add the badge now that it knows something is different
	
}

/*
- (void)parseGetBestImageMatchFromJSON: (JSONResult *)jsonResult {
    
    NSLog(@"AppModel: parseGetBestImageMatchFromJSON");
		
	//Continue parsing
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Data from Server" 
                                                   message:(NSString *)jsonResult.data 
                                                  delegate:nil 
                                         cancelButtonTitle:nil 
                                         otherButtonTitles: nil];
    
    [alert show];
    [alert release];
    
}
*/

-(void)parseQRCodeObjectFromJSON: (JSONResult *)jsonResult {
    
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeNewWaitingIndicator];
    
	NSObject<QRCodeProtocol> *qrCodeObject = nil;
    
	if ((NSNull*)jsonResult.data != [NSNull null]) {
		NSDictionary *qrCodeDictionary = (NSDictionary *)jsonResult.data;
        NSString *type = [qrCodeDictionary valueForKey:@"link_type"];
        NSDictionary *objectDictionary = [qrCodeDictionary valueForKey:@"object"];

		if ([type isEqualToString:@"Location"]) qrCodeObject = [self parseLocationFromDictionary:objectDictionary];

	}
	
	[[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName:@"QRCodeObjectReady" object:qrCodeObject]];
    
	
}


-(void)parseStartOverFromJSON:(JSONResult *)jsonResult{
	NSLog(@"AppModel: Parsing start over result and firing off fetches");
	[self silenceNextServerUpdate];
	[self fetchAllPlayerLists];
}


-(void)parseUpdateServerWithPlayerLocationFromJSON:(JSONResult *)jsonResult{
    NSLog(@"AppModel: parseUpdateServerWithPlayerLocationFromJSON");
    currentlyUpdatingServerWithPlayerLocation = NO;
}

-(void)parseQuestListFromJSON: (JSONResult *)jsonResult{
    
	NSLog(@"AppModel: Parsing Quests");
    
    currentlyFetchingQuestList = NO;
	
	//Check for an error
	
	//Tell everyone we just recieved the questList
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedQuestList" object:nil]];
	
	//Compare this hash to the last one. If the same, stop here
	if ([jsonResult.hash isEqualToString:[AppModel sharedAppModel].questListHash]) {
		NSLog(@"AppModel: Hash is same as last quest list update, continue");
		return;
	}
	
	//Save this hash for later comparisions
	[AppModel sharedAppModel].questListHash = [jsonResult.hash copy];
	
	//Continue parsing
    
	NSDictionary *questListDictionary = (NSDictionary *)jsonResult.data;	
	
	//parse out the active quests into quest objects
	NSMutableArray *activeQuestObjects = [[NSMutableArray alloc] init];
	NSArray *activeQuests = [questListDictionary objectForKey:@"active"];
	NSEnumerator *activeQuestsEnumerator = [activeQuests objectEnumerator];
	NSDictionary *activeQuest;
	while ((activeQuest = [activeQuestsEnumerator nextObject])) {
		//We have a quest, parse it into a quest abject and add it to the activeQuestObjects array
		Quest *quest = [[Quest alloc] init];
		quest.questId = [[activeQuest objectForKey:@"quest_id"] intValue];
		quest.name = [activeQuest objectForKey:@"name"];
		quest.description = [activeQuest objectForKey:@"description"];
		quest.iconMediaId = [[activeQuest objectForKey:@"icon_media_id"] intValue];
		[activeQuestObjects addObject:quest];
		[quest release];
	}
    
	//parse out the completed quests into quest objects	
	NSMutableArray *completedQuestObjects = [[NSMutableArray alloc] init];
	NSArray *completedQuests = [questListDictionary objectForKey:@"completed"];
	NSEnumerator *completedQuestsEnumerator = [completedQuests objectEnumerator];
	NSDictionary *completedQuest;
	while ((completedQuest = [completedQuestsEnumerator nextObject])) {
		//We have a quest, parse it into a quest abject and add it to the completedQuestObjects array
		Quest *quest = [[Quest alloc] init];
		quest.questId = [[completedQuest objectForKey:@"quest_id"] intValue];
		quest.name = [completedQuest objectForKey:@"name"];
		quest.description = [completedQuest objectForKey:@"text_when_complete"];
		quest.iconMediaId = [[completedQuest objectForKey:@"icon_media_id"] intValue];
		[completedQuestObjects addObject:quest];
		[quest release];
	}
  

	//Package the two object arrays in a Dictionary
	NSMutableDictionary *tmpQuestList = [[NSMutableDictionary alloc] init];
	[tmpQuestList setObject:activeQuestObjects forKey:@"active"];
	[tmpQuestList setObject:completedQuestObjects forKey:@"completed"];	
	[AppModel sharedAppModel].questList = tmpQuestList;

    
         //Update Game Object   
	[AppModel sharedAppModel].currentGame.completedQuests = [completedQuestObjects count];
	[AppModel sharedAppModel].currentGame.activeQuests = [activeQuestObjects count];
	NSString *totalQuests = [questListDictionary valueForKey:@"totalQuests"];
	if ((NSNull *)totalQuests != [NSNull null]) [AppModel sharedAppModel].currentGame.totalQuests = [totalQuests intValue];
	else [AppModel sharedAppModel].currentGame.totalQuests = 1;
	
	[activeQuestObjects release];
	[completedQuestObjects release];
	[tmpQuestList release];
    
	//Sound the alarm
	NSLog(@"AppModel: Finished fetching quests from server, model updated");
	[[NSNotificationCenter defaultCenter] postNotification: [NSNotification notificationWithName:@"NewQuestListReady" object:nil]];
}


@end