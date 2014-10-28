//
//  NotesModel.m
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "AppModel.h"
#import "AppServices.h"
#import "NotesModel.h"
#import "User.h"

@interface NotesModel()
{
  NSMutableDictionary *notes;

  NSMutableArray *playerNotes;
  NSMutableArray *listNotes;
  NSMutableArray *notesMatchingTag;
}

@end

@implementation NotesModel

- (id) init
{
    if(self = [super init])
    {
      [self clearGameData];
      _ARIS_NOTIF_LISTEN_(@"SERVICES_NOTES_RECEIVED",self,@selector(notesReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    [self invalidateCaches];
    notes = [[NSMutableDictionary alloc] init];
}

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr
{
    [_SERVICES_ createNote:n withTag:t media:m trigger:tr]; //just forward to services
}
- (void) deleteNoteId:(int)note_id
{
    [_SERVICES_ deleteNoteId:note_id]; //just forward to services
    [notes removeObjectForKey:[NSNumber numberWithInt:note_id]];
    [self invalidateCaches];
}

- (void) invalidateCaches
{
  playerNotes = nil;
  listNotes = nil;
  notesMatchingTag = nil;
}

- (void) notesReceived:(NSNotification *)notif
{
  [self updateNotes:notif.userInfo[@"notes"]];
}

- (void) updateNotes:(NSArray *)newNotes
{
  [self invalidateCaches];
  Note *newNote;
  NSNumber *newNoteId;
  for(int i = 0; i < newNotes.count; i++)
  {
    newNote = [newNotes objectAtIndex:i];
    newNoteId = [NSNumber numberWithInt:newNote.note_id];
    if(!notes[newNoteId]) [notes setObject:newNote forKey:newNoteId];
  }
  _ARIS_NOTIF_SEND_(@"MODEL_NOTES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestNotes
{
  [_SERVICES_ fetchNotes];
}

// null note (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Note *) noteForId:(int)note_id
{
  if(!note_id) return [[Note alloc] init];
  return notes[[NSNumber numberWithInt:note_id]];
}

- (NSArray *) notes
{
    return [notes allValues];
}

- (NSArray *) playerNotes
{
  if(playerNotes) return playerNotes;
  playerNotes = [[NSMutableArray alloc] init];
  NSArray *ns = [notes allValues];
  for(int i = 0; i < ns.count; i++)
    if(((Note *)ns[i]).user_id == _MODEL_PLAYER_.user_id) [playerNotes addObject:ns[i]];
  return playerNotes;
}

- (NSArray *) listNotes
{
  if(listNotes) return listNotes;
  listNotes = [[NSMutableArray alloc] init];
  NSArray *ns = [notes allValues];
  for(int i = 0; i < ns.count; i++)
    if(((Note *)ns[i]).user_id == _MODEL_PLAYER_.user_id) [listNotes addObject:ns[i]];
  return listNotes;
}

- (NSArray *) notesMatchingTag:(Tag *)tag
{
  if(notesMatchingTag) return notesMatchingTag;
  notesMatchingTag = [[NSMutableArray alloc] init];
  NSArray *ns = [notes allValues];
  for(int i = 0; i < ns.count; i++)
    if(((Note *)ns[i]).user_id == _MODEL_PLAYER_.user_id) [notesMatchingTag addObject:ns[i]];
  return notesMatchingTag;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
