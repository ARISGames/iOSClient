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
//#import "NoteDetailsViewController.h"
#import "NSDictionary+ValidParsers.h"

@implementation Note

@synthesize owner;
@synthesize noteId;
@synthesize name;
@synthesize ndescription;
@synthesize comments;
@synthesize contents;
@synthesize tags;
@synthesize numRatings;
@synthesize showOnMap;
@synthesize showOnList;
@synthesize parentNoteId;
@synthesize parentRating;
@synthesize latitude;
@synthesize longitude;
@synthesize created;

- (Note *) init
{
    if (self = [super init])
    {
        self.noteId = 0;
        self.name = @"Note";
        self.ndescription = @"";
        self.owner = [[Player alloc] init];
        self.comments = [[NSMutableArray alloc] init];
        self.contents = [[NSMutableArray alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.numRatings = 0;
        self.showOnMap = NO;
        self.showOnList = NO;
        self.parentNoteId = 0;
        self.parentRating = 0;
        self.latitude = 0.0;
        self.longitude = 0.0;
        self.created = [[NSDate alloc] init];
    }
    return self;	
}

- (Note *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        NSDictionary *ownerDict = [dict validObjectForKey:@"owner"]; 
        if(ownerDict) self.owner = [[Player alloc] initWithDictionary:ownerDict];
        
        self.showOnMap     = [dict validBoolForKey:@"public_to_map"];
        self.showOnList    = [dict validBoolForKey:@"public_to_list"];
        self.noteId        = [dict validIntForKey:@"note_id"];
        self.parentNoteId  = [dict validIntForKey:@"parent_note_id"];
        self.parentRating  = [dict validIntForKey:@"parent_rating"];
        self.numRatings    = [dict validIntForKey:@"likes"];
        self.latitude      = [dict validDoubleForKey:@"lat"];
        self.longitude     = [dict validDoubleForKey:@"lon"];
        self.name          = [dict validStringForKey:@"title"];
        self.ndescription  = [dict validStringForKey:@"description"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.created = [df dateFromString:[dict validStringForKey:@"created"]];
        
        NSArray *contentDicts = [dict validObjectForKey:@"contents"];
        self.contents = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *contentDict in contentDicts)
        {
            NoteContent *nc = [[NoteContent alloc] initWithDictionary:contentDict];
            if([nc.type isEqualToString:@"TEXT"]) self.ndescription = [NSString stringWithFormat:@"%@ %@",self.ndescription,nc.text];
            else [self.contents addObject:nc];
        }
               
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

- (GameObjectViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
    return nil;
}
/*
- (NoteDetailsViewController *) viewControllerForDelegate:(NSObject<GameObjectViewControllerDelegate> *)d fromSource:(id)s
{
    return [[NoteDetailsViewController alloc] initWithNote:self delegate:d];
}
 */

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
    return [NSString stringWithFormat:@"Note- Id:%d\tName:%@\tOwner:%@\t",self.noteId,self.name,self.owner.username];
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
