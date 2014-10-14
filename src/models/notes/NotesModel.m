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

  NSArray *playerNotes;
  NSArray *listNotes;
  NSArray *notesMatchingTag;
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

- (NSArray *) playerNotes
{
  if(playerNotes) return playerNotes;
  playerNotes = @[];
  return playerNotes;
}

- (NSArray *) listNotes
{
  if(listNotes) return listNotes;
  listNotes = @[];
  return listNotes;
}

- (NSArray *) notesMatchingTag:(Tag *)tag
{
  if(notesMatchingTag) return notesMatchingTag;
  notesMatchingTag = @[];
  return notesMatchingTag;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
