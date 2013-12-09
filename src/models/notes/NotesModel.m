//
//  NotesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import "AppModel.h"
#import "AppServices.h"
#import "NotesModel.h"
#import "Player.h"

@interface NotesModel()
{
    NSMutableArray *currentNotes; 
    NSArray *playerNotes;
    NSArray *listNotes;
    NSArray *mapNotes; 
    
    int curServerPage;
    int listComplete;
}

@end

@implementation NotesModel

- (id) init
{
    if(self = [super init])
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestNotesReceived:) name:@"LatestNoteListReceived" object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataReceived:)    name:@"NoteDataReceived"       object:nil];  
    }
    return self;
}

- (void) clearData
{
    currentNotes = [[NSMutableArray alloc] init];
    curServerPage = 0;
    listComplete = 0;
}

- (int) listComplete
{
    return listComplete;
}

- (void) getNextNotes
{
    if(listComplete)
    {
        NSLog(@"NSNotificaiton: NewNoteListAvailable");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewNoteListAvailable" object:nil]; 
    }
    else
        [[AppServices sharedAppServices] fetchNoteListPage:curServerPage];
}

- (void) getDetailsForNote:(Note *)n
{
    [[AppServices sharedAppServices] fetchNoteWithId:n.noteId]; 
}

- (void) latestNotesReceived:(NSNotification *)n
{
    playerNotes = nil;
    listNotes = nil; 
    mapNotes = nil;  
    
    [currentNotes addObjectsFromArray:[n.userInfo objectForKey:@"notes"]];
    curServerPage++;
    if([[n.userInfo objectForKey:@"notes"] count] == 0) listComplete = 1;
    NSLog(@"NSNotificaiton: NewNoteListAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewNoteListAvailable" object:nil];
}

- (void) noteDataReceived:(NSNotification *)n
{
    Note *note = [n.userInfo objectForKey:@"note"];
    for(int i = 0; i < [currentNotes count]; i++)
    {
        if(((Note *)[currentNotes objectAtIndex:i]).noteId == note.noteId)
            [currentNotes setObject:note atIndexedSubscript:i];
    }
        
    NSLog(@"NSNotificaiton: NoteDataAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteDataAvailable" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:note,@"note",nil]];
}

- (NSArray *) playerNotes
{
    if(!playerNotes)
    {
        NSMutableArray *constructPlayerNotes = [[NSMutableArray alloc] initWithCapacity:10];
        for(Note *n in currentNotes)
            if(n.owner.playerId == [AppModel sharedAppModel].player.playerId) [constructPlayerNotes addObject:n];
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
            if(n.publicToList) [constructListNotes addObject:n];
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
            if(n.publicToList) [constructMapNotes addObject:n];
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
