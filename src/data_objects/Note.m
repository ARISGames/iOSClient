//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "NotesModel.h"
#import "Game.h"
#import "NoteComment.h"
#import "User.h"
#import "Location.h"
#import "NoteTag.h"
#import "NSDictionary+ValidParsers.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "NoteViewController.h"

@implementation Note

@synthesize noteId;
@synthesize owner;
@synthesize name;
@synthesize desc;
@synthesize created;
@synthesize location;
@synthesize tags;
@synthesize contents;
@synthesize comments;
@synthesize publicToList;
@synthesize publicToMap;
@synthesize stubbed;

- (Note *) init
{
    if (self = [super init])
    {
        self.noteId = 0;
        self.owner = [[User alloc] init]; 
        self.name = @"";
        self.desc = @"";
        self.created = [[NSDate alloc] init]; 
        self.location = [[Location alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.contents = [[NSMutableArray alloc] init];
        self.comments = [[NSMutableArray alloc] init];
        self.publicToMap = NO;
        self.publicToList = NO;
        self.stubbed = YES;
    }
    return self;	
}

- (Note *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.noteId = [dict validIntForKey:@"note_id"]; 
        
        NSDictionary *ownerDict = [dict validObjectForKey:@"owner"]; 
        if(ownerDict) self.owner = [[User alloc] initWithDictionary:ownerDict];
       
        self.name = [dict validStringForKey:@"title"];
        self.desc = [dict validStringForKey:@"description"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.created = [df dateFromString:[dict validStringForKey:@"created"]];
               
        NSDictionary *locationDict = [dict validObjectForKey:@"location"]; 
        if(locationDict) self.location = [[Location alloc] initWithDictionary:locationDict];  
        else             self.location = [[Location alloc] init];
                      
        NSArray *tagDicts = [dict validObjectForKey:@"tags"];
        self.tags = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *tagDict in tagDicts)
            [self.tags addObject:[[NoteTag alloc] initWithDictionary:tagDict]]; 
        if([tagDicts count] == 0)
            [self.tags addObject:_MODEL_GAME_.notesModel.unlabeledTag];
        
        NSArray *contentDicts = [dict validObjectForKey:@"contents"];
        self.contents = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *contentDict in contentDicts)
        {
            //For compatibility with previous model where text was just a notecontent
            if([[contentDict objectForKey:@"type"] isEqualToString:@"TEXT"])
                self.desc = [NSString stringWithFormat:@"%@%@",self.desc,[contentDict objectForKey:@"text"]];
            else
                [self.contents addObject:[_MODEL_MEDIA_ mediaForId:[contentDict validIntForKey:@"media_id"]]];
        }
        
        NSArray *commentDicts = [dict validObjectForKey:@"comments"];
        self.comments = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *commentDict in commentDicts)
            [self.comments addObject:[[NoteComment alloc] initWithDictionary:commentDict]];
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO]];
        self.comments = [[self.comments sortedArrayUsingDescriptors:sortDescriptors] mutableCopy]; 
               
        self.publicToList = [dict validBoolForKey:@"public_to_list"];
        self.publicToMap  = [dict validBoolForKey:@"public_to_map"];   
        
        self.stubbed = YES; 
    }
    return self;
}

- (void) mergeDataFromNote:(Note *)n //allows for notes to be updated easily- all things with this note pointer now have access to latest note data
{
    self.owner = n.owner;
    
    self.name = n.name;
    self.desc = n.desc;
    
    self.created = n.created;
    self.location = n.location;
    
    self.publicToList = n.publicToList;
    self.publicToMap = n.publicToMap; 
    
    if(n.stubbed) return; 
    self.tags = n.tags;
    self.contents = n.contents;
    self.comments = n.comments;
    self.stubbed = NO;
}

- (GameObjectType) type
{
    return GameObjectNote;
}

- (int) icon_media_id
{
    return 71;
}

- (GameObjectViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate, NoteViewControllerDelegate> *)d fromSource:(id)s
{
    return [[NoteViewController alloc] initWithNote:self delegate:d];
}

- (Note *) copy
{
    Note *c = [[Note alloc] init];
    //TODO
    return c;
}

- (int) compareTo:(Note *)ob
{
	return (ob.noteId == self.noteId);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Note- Id:%d\tName:%@\tOwner:%@\t",self.noteId,self.name,self.owner.user_name];
}

@end
