//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "Game.h"
#import "GameComment.h"
#import "NSDictionary+ValidParsers.h"
 
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
        self.authors = [NSMutableArray arrayWithCapacity:5];
        self.comments = [NSMutableArray arrayWithCapacity:5]; 
        self.play_log = [NSMutableArray arrayWithCapacity:5];  
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.authors = [NSMutableArray arrayWithCapacity:5];
        self.comments = [NSMutableArray arrayWithCapacity:5]; 
        self.play_log = [NSMutableArray arrayWithCapacity:5];   
        
        self.game_id = [dict validIntForKey:@"game_id"];
        self.name = [dict validStringForKey:@"name"];
        self.desc = [dict validStringForKey:@"description"]; 

        self.icon_media_id = [dict validIntForKey:@"icon_media_id"]; 
        self.media_id = [dict validIntForKey:@"media_id"];  

        self.map_type = [dict validStringForKey:@"map_type"];
        self.location = [[CLLocation alloc] initWithLatitude:[dict validDoubleForKey:@"latitude"] longitude:[dict validDoubleForKey:@"longitude"]]; 
        self.zoom_level = [dict validDoubleForKey:@"zoom_level"];

        self.show_player_location = [dict validBoolForKey:@"show_player_location"];
        self.full_quick_travel = [dict validBoolForKey:@"full_quick_travel"];

        self.allow_note_comments = [dict validBoolForKey:@"allow_note_comments"];
        self.allow_note_player_tags = [dict validBoolForKey:@"allow_note_player_tags"];
        self.allow_note_likes = [dict validBoolForKey:@"allow_note_likes"];

        self.inventory_weight_cap = [dict validIntForKey:@"inventory_weight_cap"];
        
        self.has_been_played = [dict validBoolForKey:@"has_been_played"]; 
        self.player_count = [dict validIntForKey:@"player_count"];  
    }
    return self;
}

- (void) mergeDataFromGame:(Game *)g
{
    
}

- (void) getReadyToPlay
{
    self.plaquesModel   = [[PlaquesModel   alloc] init];  
    self.itemsModel     = [[ItemsModel     alloc] init];  
    self.dialogsModel   = [[DialogsModel   alloc] init];  
    self.webPagesModel  = [[WebPagesModel  alloc] init];   
    self.notesModel     = [[NotesModel     alloc] init];
    self.questsModel    = [[QuestsModel    alloc] init];
    self.locationsModel = [[LocationsModel alloc] init];
    self.overlaysModel  = [[OverlaysModel  alloc] init];
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
    self.plaquesModel   = nil;
    self.itemsModel     = nil;
    self.dialogsModel   = nil;
    self.webPagesModel  = nil;
    self.notesModel     = nil;
    self.questsModel    = nil;
    self.locationsModel = nil; 
}

- (void) clearModels
{
    [self.plaquesModel   clearGameData];  
    [self.itemsModel     clearGameData];  
    [self.dialogsModel   clearGameData];  
    [self.webPagesModel  clearGameData];   
    [self.notesModel     clearData];
    [self.questsModel    clearData];
    [self.locationsModel clearData];
    [self.overlaysModel  clearData];
}

- (int) rating
{
    if(!self.comments.count) return 0;
    int rating = 0;
    for(int i = 0; i < self.comments.count; i++)
        rating += ((GameComment *)[self.comments objectAtIndex:i]).rating;
    return rating/self.comments.count;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Game- Id:%d\tName:%@",self.game_id,self.name];
}

- (void) dealloc
{
    
}

@end
