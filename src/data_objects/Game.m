//
//  Game.m
//  ARIS
//
//  Created by Ben Longoria on 2/16/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "Game.h"
 
@implementation Game

@synthesize game_id;
@synthesize name;
@synthesize desc; 

@synthesize icon_media_id; 
@synthesize iconMedia;
@synthesize media_id;  
@synthesize media; 

@synthesize map_type;
@synthesize location;
@synthesize zoom_level;

@synthesize show_player_location;
@synthesize full_quick_travel;

@synthesize allow_note_comments;
@synthesize allow_note_player_tags;
@synthesize allow_note_likes;

@synthesize inventory_weight_cap;

@synthesize authors;
@synthesize comments;

@synthesize plaquesModel; 
@synthesize itemsModel; 
@synthesize npcsModel; 
@synthesize notesModel;
@synthesize questsModel;
@synthesize locationsModel;
@synthesize overlaysModel;

- (id) init
{
    if(self = [super init])
    {
        self.comments = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void) getReadyToPlay
{
    self.plaquesModel   = [[PlaquesModel    alloc] init];  
    self.itemsModel     = [[ItemsModel      alloc] init];  
    self.npcsModel      = [[NpcsModel      alloc] init];  
    self.notesModel     = [[NotesModel      alloc] init];
    self.questsModel    = [[QuestsModel     alloc] init];
    self.locationsModel = [[LocationsModel  alloc] init];
    self.overlaysModel  = [[OverlaysModel   alloc] init];
}

- (void) endPlay //to remove models while retaining the game stub for lists and such
{
    self.plaquesModel   = nil;  
    self.itemsModel     = nil;  
    self.npcsModel      = nil;   
    self.notesModel     = nil;
    self.questsModel    = nil;
    self.locationsModel = nil; 
}

- (void) clearLocalModels
{
    [self.plaquesModel   clearData];  
    [self.itemsModel     clearData];  
    [self.npcsModel      clearData];  
    [self.notesModel     clearData];
    [self.questsModel    clearData];
    [self.locationsModel clearData];
    [self.overlaysModel  clearData];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Game- Id:%d\tName:%@",self.game_id,self.name];
}

- (void) dealloc
{
    
}

@end
