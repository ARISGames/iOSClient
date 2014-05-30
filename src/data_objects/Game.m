//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//


// Functions both as "Game" data object and Game Model

#import "Game.h"
#import "User.h"
#import "GameComment.h"
#import "NSDictionary+ValidParsers.h"

const int gameDatasToReceive = 7;
const int playerDatasToReceive = 4;

@interface Game()
{
    int receivedGameData;
    BOOL gameDataReceived; 
    
    int receivedPlayerData;
    BOOL playerDataReceived;  
}
@end
 
@implementation Game

@synthesize game_id;
@synthesize name;
@synthesize desc; 

@synthesize icon_media_id; 
@synthesize media_id;  

@synthesize map_type;
@synthesize location;
@synthesize zoom_level;

@synthesize show_player_location;
@synthesize full_quick_travel;

@synthesize allow_note_comments;
@synthesize allow_note_player_tags;
@synthesize allow_note_likes;

@synthesize inventory_weight_cap;
@synthesize has_been_played;
@synthesize player_count;

@synthesize authors;
@synthesize comments;
@synthesize play_log;

@synthesize plaquesModel; 
@synthesize itemsModel; 
@synthesize dialogsModel; 
@synthesize webPagesModel; 
@synthesize notesModel;
@synthesize questsModel;
@synthesize locationsModel;
@synthesize overlaysModel;

- (id) init
{
    if(self = [super init])
    {
        [self initialize]; 
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        [self initialize];
        
        game_id = [dict validIntForKey:@"game_id"];
        name = [dict validStringForKey:@"name"];
        desc = [dict validStringForKey:@"description"]; 

        icon_media_id = [dict validIntForKey:@"icon_media_id"]; 
        media_id = [dict validIntForKey:@"media_id"];  

        map_type = [dict validStringForKey:@"map_type"];
        location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]]; 
        zoom_level = [dict validDoubleForKey:@"zoom_level"];

        show_player_location = [dict validBoolForKey:@"show_player_location"];
        full_quick_travel = [dict validBoolForKey:@"full_quick_travel"];

        allow_note_comments = [dict validBoolForKey:@"allow_note_comments"];
        allow_note_player_tags = [dict validBoolForKey:@"allow_note_player_tags"];
        allow_note_likes = [dict validBoolForKey:@"allow_note_likes"];

        inventory_weight_cap = [dict validIntForKey:@"inventory_weight_cap"];
        
        has_been_played = [dict validBoolForKey:@"has_been_played"]; 
        player_count = [dict validIntForKey:@"player_count"];  
        
        NSArray *authorDicts;
        for(int i = 0; (authorDicts || (authorDicts = [dict objectForKey:@"authors"])) && i < authorDicts.count; i++)
            [authors addObject:[[User alloc] initWithDictionary:authorDicts[i]]];
    }
    return self;
}

- (void) initialize //call in all init funcs (why apple doesn't provide functionality for this, I have no idea)
{
    receivedGameData = 0;
    gameDataReceived = NO;   
        
    receivedPlayerData = 0;
    playerDataReceived = NO;    
               
    authors  = [NSMutableArray arrayWithCapacity:5];
    comments = [NSMutableArray arrayWithCapacity:5]; 
    play_log = [NSMutableArray arrayWithCapacity:5];   
}

- (void) mergeDataFromGame:(Game *)g
{
    game_id = g.game_id;
    name = g.name;
    desc = g.desc; 

    icon_media_id = g.icon_media_id; 
    media_id = g.media_id;  

    map_type = g.map_type;
    location = g.location;
    zoom_level = g.zoom_level;

    show_player_location = g.show_player_location;
    full_quick_travel = g.full_quick_travel;

    allow_note_comments = g.allow_note_comments;
    allow_note_player_tags = g.allow_note_player_tags;
    allow_note_likes = g.allow_note_likes;

    inventory_weight_cap = g.inventory_weight_cap;
    has_been_played = g.has_been_played;
    player_count = g.player_count;

    authors  = g.authors;
    comments = g.comments;
}

- (void) getReadyToPlay
{
    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PIECE_RECEIVED",self,@selector(gamePieceReceived),nil);
    _ARIS_NOTIF_LISTEN_(@"MODEL_GAME_PLAYER_PIECE_RECEIVED",self,@selector(gamePlayerPieceReceived),nil); 
    
    receivedGameData = 0;
    gameDataReceived = NO;    
    
    receivedPlayerData = 0;
    playerDataReceived = NO;      
    
    plaquesModel   = [[PlaquesModel   alloc] init];  
    itemsModel     = [[ItemsModel     alloc] init];  
    dialogsModel   = [[DialogsModel   alloc] init];  
    webPagesModel  = [[WebPagesModel  alloc] init];   
    notesModel     = [[NotesModel     alloc] init];
    questsModel    = [[QuestsModel    alloc] init];
    locationsModel = [[LocationsModel alloc] init];
    overlaysModel  = [[OverlaysModel  alloc] init];
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
    
    receivedGameData = 0;
    gameDataReceived = NO;     
    
    receivedPlayerData = 0;
    playerDataReceived = NO;       
    
    plaquesModel   = nil;
    itemsModel     = nil;
    dialogsModel   = nil;
    webPagesModel  = nil;
    notesModel     = nil;
    questsModel    = nil;
    locationsModel = nil; 
}

- (void) requestData
{
    [plaquesModel requestPlaques];
    [itemsModel requestItems];
    [dialogsModel requestDialogs];
    [webPagesModel requestWebPages];
    [questsModel requestQuests];
    
    notesModel     = nil;
    locationsModel = nil;  
}

- (void) gamePieceReceived
{
    receivedGameData++;
    [self percentLoadedChanged]; 
}

- (void) gamePlayerPieceReceived
{
    receivedPlayerData++;
    [self percentLoadedChanged];
}

- (void) percentLoadedChanged
{
    NSNumber *percentReceived = [NSNumber numberWithFloat:
                                 (float)(receivedGameData+receivedPlayerData)/(float)(gameDatasToReceive+playerDatasToReceive)
                                 ];
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PERCENT_LOADED", nil, @{@"percent":percentReceived});  
}

- (void) clearModels
{
    receivedGameData = 0;
    gameDataReceived = NO;     
    
    receivedPlayerData = 0;
    playerDataReceived = NO;       
    
    [plaquesModel   clearGameData];  
    [itemsModel     clearGameData];  
    [dialogsModel   clearGameData];  
    [webPagesModel  clearGameData];   
    [questsModel    clearGameData]; 
    
    [itemsModel     clearPlayerData];  
    [questsModel    clearPlayerData];  
    [notesModel     clearData];
    [locationsModel clearData];
    [overlaysModel  clearData];
}

- (int) rating
{
    if(!comments.count) return 0;
    int rating = 0;
    for(int i = 0; i < comments.count; i++)
        rating += ((GameComment *)[comments objectAtIndex:i]).rating;
    return rating/comments.count;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Game- Id:%d\tName:%@",game_id,name];
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
