//
//  Note.m
//  ARIS
//
//  Created by Brian Thiel on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Note.h"
#import "Player.h"
#import "Location.h"
#import "Tag.h"
#import "NSDictionary+ValidParsers.h"
#import "AppModel.h"

@implementation Note

@synthesize noteId;
@synthesize owner;
@synthesize name;
@synthesize ndescription;
@synthesize created;
@synthesize location;
@synthesize tags;
@synthesize contents;
@synthesize comments;
@synthesize publicToList;
@synthesize publicToMap;

- (Note *) init
{
    if (self = [super init])
    {
        self.noteId = 0;
        self.owner = [[Player alloc] init]; 
        self.name = @"";
        self.ndescription = @"";
        self.created = [[NSDate alloc] init]; 
        self.location = [[Location alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.contents = [[NSMutableArray alloc] init];
        self.comments = [[NSMutableArray alloc] init];
        self.publicToMap = NO;
        self.publicToList = NO;
    }
    return self;	
}

- (Note *) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.noteId        = [dict validIntForKey:@"note_id"]; 
        
        NSDictionary *ownerDict = [dict validObjectForKey:@"owner"]; 
        if(ownerDict) self.owner = [[Player alloc] initWithDictionary:ownerDict];
       
        self.name          = [dict validStringForKey:@"title"];
        self.ndescription  = [dict validStringForKey:@"description"];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.created = [df dateFromString:[dict validStringForKey:@"created"]];
               
        NSDictionary *locationDict = [dict validObjectForKey:@"location"]; 
        if(locationDict) self.location = [[Location alloc] initWithDictionary:locationDict];  
                      
        NSArray *tagDicts = [dict validObjectForKey:@"tags"];
        self.tags = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *tagDict in tagDicts)
            [self.tags addObject:[[Tag alloc] initWithDictionary:tagDict]]; 
        
        NSArray *contentDicts = [dict validObjectForKey:@"contents"];
        self.contents = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *contentDict in contentDicts)
        {
            //For compatibility with previous model where text was just a notecontent
            if([[contentDict objectForKey:@"type"] isEqualToString:@"TEXT"])
                self.ndescription = [NSString stringWithFormat:@"%@ %@",self.ndescription,[contentDict objectForKey:@"text"]];
            else
                [self.contents addObject:[[AppModel sharedAppModel] mediaForMediaId:[contentDict validIntForKey:@"media_id"]]];
        }
        
        NSArray *commentDicts = [dict validObjectForKey:@"comments"];
        self.comments = [[NSMutableArray alloc] initWithCapacity:5];
        for(NSDictionary *commentDict in commentDicts)
            [self.comments addObject:[[Note alloc] initWithDictionary:commentDict]];
        NSArray *sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"noteId" ascending:NO]];
        self.comments = [[self.comments sortedArrayUsingDescriptors:sortDescriptors] mutableCopy]; 
               
        self.publicToList    = [dict validBoolForKey:@"public_to_list"];
        self.publicToMap     = [dict validBoolForKey:@"public_to_map"];   
        
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
    return [NSString stringWithFormat:@"Note- Id:%d\tName:%@\tOwner:%@\t",self.noteId,self.name,self.owner.username];
}

@end
