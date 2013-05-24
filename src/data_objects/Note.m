//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "NoteContent.h"
#import "Tag.h"
#import "NoteDetailsViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Note

@synthesize noteId;
@synthesize name;
@synthesize text;
@synthesize creatorId;
@synthesize username;
@synthesize displayname;
@synthesize comments;
@synthesize contents;
@synthesize tags;
@synthesize numRatings;
@synthesize shared;
@synthesize dropped;
@synthesize showOnMap;
@synthesize showOnList;
@synthesize userLiked;
@synthesize parentNoteId;
@synthesize parentRating;
@synthesize hasImage;
@synthesize hasAudio;
@synthesize latitude;
@synthesize longitude;

- (Note *) init
{
    if (self = [super init])
    {
        self.noteId = 0;
        self.name = @"Note";
        self.text = @"";
        self.creatorId = 0;
        self.username = @"Owner";
        self.displayname = @"Owner";
        self.comments = [[NSMutableArray alloc] init];
        self.contents = [[NSMutableArray alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.numRatings = 0;
        self.shared = NO;
        self.dropped = NO;
        self.showOnMap = NO;
        self.showOnList = NO;
        self.userLiked = NO;
        self.parentNoteId = 0;
        self.parentRating = 0;
        self.hasImage = NO;
        self.hasAudio = NO;
        self.latitude = 0.0;
        self.longitude = 0.0;
    }
    return self;	
}

- (Note *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.dropped       = [dict validBoolForKey:@"dropped"];
        self.showOnMap     = [dict validBoolForKey:@"public_to_map"];
        self.showOnList    = [dict validBoolForKey:@"public_to_notebook"];
        self.userLiked     = [dict validBoolForKey:@"player_liked"];
        self.noteId        = [dict validIntForKey:@"note_id"];
        self.parentNoteId  = [dict validIntForKey:@"parent_note_id"];
        self.parentRating  = [dict validIntForKey:@"parent_rating"];
        self.numRatings    = [dict validIntForKey:@"likes"];
        self.creatorId     = [dict validIntForKey:@"owner_id"];
        self.latitude      = [dict validDoubleForKey:@"lat"];
        self.longitude     = [dict validDoubleForKey:@"lon"];
        self.username      = [dict validObjectForKey:@"username"];
        self.displayname   = [dict validStringForKey:@"displayname"];
        self.name          = [dict validObjectForKey:@"title"];
        self.text          = [dict validObjectForKey:@"text"];
        
        NSArray *contentDicts = [dict validObjectForKey:@"contents"];
        self.contents = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *contentDict in contentDicts)
             [self.contents addObject:[[NoteContent alloc] initWithDictionary:contentDict]];
               
        NSArray *tagDicts = [dict validObjectForKey:@"tags"];
        self.tags = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *tagDict in tagDicts)
            [self.tags addObject:[[Tag alloc] initWithDictionary:tagDict]];
        
        NSArray *commentDicts = [dict validObjectForKey:@"comments"];
        self.comments = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *commentDict in commentDicts)
            [self.comments addObject:[[Note alloc] initWithDictionary:commentDict]];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO]];
        self.comments = [[self.comments sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    }
    return self;
}

- (GameObjectType) type
{
    return GameObjectNote;
}

- (int) iconMediaId
{
    return 71;
}

- (NoteDetailsViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
    return [[NoteDetailsViewController alloc] initWithNote:self delegate:d];
}

-(Note *)copy
{
    Note *c = [[Note alloc] init];
    //TODO
    return c;
}

- (int)compareTo:(Note *)ob
{
	return (ob.noteId == self.noteId);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Note- Id:%d\tName:%@\tOwner:%@\t",self.noteId,self.name,self.username];
}

- (BOOL) isUploading
{
    for (int i = 0; i < [self.contents count]; i++)
    {
        if([[(NoteContent *)[self.contents objectAtIndex:i] type] isEqualToString:@"UPLOAD"])
            return  YES;
    }
    return  NO;
}

@end
