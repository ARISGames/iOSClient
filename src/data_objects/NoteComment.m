//
//  NoteComment.m
//  ARIS
//
//  Created by Phil Dougherty on 1/23/14.
//
//

#import "NoteComment.h"
#import "NSDictionary+ValidParsers.h"
#import "User.h"

@implementation NoteComment

@synthesize noteId;
@synthesize commentId;
@synthesize owner;
@synthesize text;
@synthesize created;

- (id) init
{
    if(self = [super init])
    {
        self.noteId = 0;
        self.commentId = 0; 
        self.text = @""; 
        self.owner = [[User alloc] init];  
        self.created = [NSDate date]; 
    }
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dict
{
    if(self = [super init])
    {
        self.noteId    = [dict validIntForKey:@"note_id"];
        self.commentId = [dict validIntForKey:@"comment_id"]; 
        self.text      = [dict validStringForKey:@"text"]; 
        
        NSDictionary *ownerDict = [dict validObjectForKey:@"owner"];
        if(ownerDict) self.owner = [[User alloc] initWithDictionary:ownerDict];  
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.created = [df dateFromString:[dict validStringForKey:@"created"]]; 
    }
    return self;
}

@end
