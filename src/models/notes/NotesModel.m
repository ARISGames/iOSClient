//
//  NotesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import "AppModel.h"
#import "NotesModel.h"

@interface NotesModel()
{
    NSArray *playerNotes;
    NSArray *listNotes;
    NSArray *mapNotes; 
}

@end

@implementation NotesModel

@synthesize currentNotes;

- (id) init
{
    if(self = [super init])
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestNotesReceived:) name:@"LatestNoteListReceived" object:nil]; 
    }
    return self;
}

- (void) clearData
{
    self.currentNotes = [[NSArray alloc] init];
}

- (void) latestNotesReceived:(NSNotification *)n
{
    playerNotes = nil;
    listNotes = nil; 
    mapNotes = nil;  
    
    currentNotes = [n.userInfo objectForKey:@"notes"];
    NSLog(@"NSNotificaiton: NewNoteListAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewNoteListAvailable" object:nil];
}

- (NSArray *) playerNotes
{
    if(!playerNotes)
    {
        NSMutableArray *constructPlayerNotes = [[NSMutableArray alloc] initWithCapacity:10];
        for(Note *n in currentNotes)
            if(n.creatorId == [AppModel sharedAppModel].player.playerId) [constructPlayerNotes addObject:n];
        playerNotes = constructPlayerNotes;
    }
    return playerNotes;
}

- (NSArray *) listNotes
{
    if(!listNotes)
    {
        NSMutableArray *constructListNotes = [[NSMutableArray alloc] initWithCapacity:10];
        for(Note *n in currentNotes)
            if(n.showOnList) [constructListNotes addObject:n];
        listNotes = constructListNotes;
    }
    return listNotes;
}

- (NSArray *) mapNotes
{
    if(!mapNotes)
    {
        NSMutableArray *constructMapNotes = [[NSMutableArray alloc] initWithCapacity:10];
        for(Note *n in currentNotes)
            if(n.showOnList) [constructMapNotes addObject:n];
        mapNotes = constructMapNotes;
    }
    return mapNotes;
}

- (Note *) noteForId:(int)noteId
{
   for(int i = 0; i < [currentNotes count]; i++)
       if(((Note *)[currentNotes objectAtIndex:i]).noteId == noteId) return [currentNotes objectAtIndex:i]; 
    return nil;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
