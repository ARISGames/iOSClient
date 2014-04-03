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
    NSMutableDictionary *notesMatchingTags;
    
    NSMutableArray *currentNoteTags;
    
    NSArray *gameNoteTags;
    NSArray *playerNoteTags;  
    
    NoteTag *unlabeledTag;
    
    int curServerPage;
    int listComplete;
}

@end

@implementation NotesModel

- (id) init
{
    if(self = [super init])
    {
        unlabeledTag = [[NoteTag alloc] init];
        unlabeledTag.text = @"Unlabeled";
        unlabeledTag.noteTagId = -1;
        unlabeledTag.playerCreated = NO;  
        
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestNotesReceived:) name:@"LatestNoteListReceived" object:nil]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestNoteTagsReceived:) name:@"LatestNoteTagListReceived" object:nil];  
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteDataReceived:)    name:@"NoteDataReceived"       object:nil];  
    }
    return self;
}

- (void) clearData
{
    currentNotes    = [[NSMutableArray alloc] init];
    currentNoteTags = [[NSMutableArray alloc] init]; 
    curServerPage = 0;
    listComplete  = 0;
    [self invalidateNoteCaches];
    [self invalidateNoteTagCaches]; 
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

- (int) listComplete
{
    return listComplete;
}

- (void) getNoteTags
{
    [[AppServices sharedAppServices] fetchNoteTagLists]; 
}

- (void) getDetailsForNote:(Note *)n
{
    [[AppServices sharedAppServices] fetchNoteWithId:n.noteId]; 
}

- (void) latestNotesReceived:(NSNotification *)n
{
    [self mergeInNotesArray:[n.userInfo objectForKey:@"notes"]];
    
    curServerPage++;
    if([[n.userInfo objectForKey:@"notes"] count] == 0) listComplete = 1;
    NSLog(@"NSNotificaiton: NewNoteListAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewNoteListAvailable" object:nil];
}

- (void) noteDataReceived:(NSNotification *)n
{
    [self mergeInNotesArray:[[NSArray alloc] initWithObjects:[n.userInfo objectForKey:@"note"], nil]];
    [self invalidateNotesMatchingTagsCache];  
        
    NSLog(@"NSNotificaiton: NoteDataAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteDataAvailable" object:nil userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:[n.userInfo objectForKey:@"note"],@"note",nil]];
}

- (void) mergeInNotesArray:(NSArray *)newNotes
{
    BOOL noteExists = NO;
    for(int i = 0; i < [newNotes count]; i++)
    { 
        noteExists = NO;
        for(int j = 0; j < [currentNotes count] && !noteExists; j++)
        {
            if(((Note *)[newNotes objectAtIndex:i]).noteId == ((Note *)[currentNotes objectAtIndex:j]).noteId)
            {
                noteExists = YES;
                [((Note *)[currentNotes objectAtIndex:j]) mergeDataFromNote:((Note *)[newNotes objectAtIndex:i])];
                [self mergeInNoteTagsArray:((Note *)[currentNotes objectAtIndex:j]).tags]; //if new/modified tags, this will handle it
            }
        }
        if(!noteExists) 
        {
            [currentNotes addObject:[newNotes objectAtIndex:i]];
            [self mergeInNoteTagsArray:((Note *)[newNotes objectAtIndex:i]).tags]; //if new/modified tags, this will handle it 
        }
    }
    [self invalidateNoteCaches];      
}

- (void) latestNoteTagsReceived:(NSNotification *)n
{
    [self mergeInNoteTagsArray:[n.userInfo objectForKey:@"noteTags"]];
    
    NSLog(@"NSNotificaiton: NewNoteTagsListAvailable");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewNoteTagsListAvailable" object:nil];
}

- (void) mergeInNoteTagsArray:(NSArray *)newNoteTags
{
    BOOL noteTagExists = NO;
    for(int i = 0; i < [newNoteTags count]; i++)
    { 
        noteTagExists = NO;
        for(int j = 0; j < [currentNoteTags count] && !noteTagExists; j++)
        {
            if(((NoteTag *)[newNoteTags objectAtIndex:i]).noteTagId == ((NoteTag *)[currentNoteTags objectAtIndex:j]).noteTagId)
            {
                noteTagExists = YES;
                [((NoteTag *)[currentNoteTags objectAtIndex:j]) mergeDataFromNoteTag:((NoteTag *)[newNoteTags objectAtIndex:i])];
            }
        }
        if(!noteTagExists) 
        {
            [currentNoteTags addObject:[newNoteTags objectAtIndex:i]];
            [self invalidateNoteTagCaches];   
        }
    }
}

- (void) invalidateNoteCaches
{
    playerNotes = nil;
    listNotes = nil; 
    mapNotes = nil;  
    [self invalidateNotesMatchingTagsCache];
}

- (void) invalidateNotesMatchingTagsCache
{
    notesMatchingTags = [[NSMutableDictionary alloc] init];   
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

- (NSArray *) notesMatchingTag:(NoteTag *)t
{
    if(![notesMatchingTags objectForKey:t.text])
    {
        NSMutableArray *constructListNotes = [[NSMutableArray alloc] initWithCapacity:10];
        for(Note *n in currentNotes)
        {
            if(n.stubbed) [self getDetailsForNote:n];
            for(int i = 0; i < [n.tags count]; i++)
                if([((NoteTag *)[n.tags objectAtIndex:i]).text isEqualToString:t.text])
                    [constructListNotes addObject:n];
        }
        [notesMatchingTags setObject:constructListNotes forKey:t.text];
    }
    return [notesMatchingTags objectForKey:t.text];
}

- (void) invalidateNoteTagCaches
{
    gameNoteTags = nil;
    playerNoteTags = nil; 
}

- (NSArray *) gameNoteTags
{
    if(!gameNoteTags)
    {
        NSMutableArray *constructGameNoteTags = [[NSMutableArray alloc] initWithCapacity:10];
        for(NoteTag *nt in currentNoteTags)
            if(!nt.playerCreated) [constructGameNoteTags addObject:nt];
        gameNoteTags = constructGameNoteTags;
    }
    return gameNoteTags;
}

- (NSArray *) playerNoteTags
{
    if(!playerNoteTags)
    {
        NSMutableArray *constructPlayerNoteTags = [[NSMutableArray alloc] initWithCapacity:10];
        for(NoteTag *nt in currentNoteTags)
            if(nt.playerCreated) [constructPlayerNoteTags addObject:nt];
        playerNoteTags = constructPlayerNoteTags;
    }
    return playerNoteTags;
}

- (Note *) noteForId:(int)noteId
{
    for(int i = 0; i < [currentNotes count]; i++)
        if(((Note *)[currentNotes objectAtIndex:i]).noteId == noteId) return [currentNotes objectAtIndex:i]; 
    Note *n = [[Note alloc] init];
    n.noteId = noteId;
    n.publicToList = YES; //assume it's accessible if it's being accessed
    n.publicToMap = YES; //assume it's accessible if it's being accessed 
    [self mergeInNotesArray:[NSArray arrayWithObject:n]]; //when data arrives, it will be merged into placeholder note
    return n;
}

- (NoteTag*) unlabeledTag
{
    return unlabeledTag;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
