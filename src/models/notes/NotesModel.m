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
#import "NoteComment.h"

@interface NotesModel()
{
  NSMutableDictionary *notes;
  NSMutableDictionary *note_comments;

  NSMutableArray *playerNotes;
  NSMutableArray *listNotes;
  NSMutableArray *notesMatchingTag;
  long game_info_recvd;
}

@end

@implementation NotesModel

- (id) init
{
    if(self = [super init])
    {
      [self clearGameData];
      _ARIS_NOTIF_LISTEN_(@"SERVICES_NOTES_RECEIVED",self,@selector(notesReceived:),nil);
      _ARIS_NOTIF_LISTEN_(@"SERVICES_NOTE_RECEIVED",self,@selector(noteReceived:),nil);
      _ARIS_NOTIF_LISTEN_(@"MODEL_PLAYER_TRIGGERS_AVAILABLE",self,@selector(invalidateCaches),nil);
      _ARIS_NOTIF_LISTEN_(@"SERVICES_NOTE_COMMENTS_RECEIVED",self,@selector(noteCommentsReceived:),nil);
      _ARIS_NOTIF_LISTEN_(@"SERVICES_NOTE_COMMENT_RECEIVED",self,@selector(noteCommentReceived:),nil);
    }
    return self;
}

- (void) clearGameData
{
    [self invalidateCaches];
    notes         = [[NSMutableDictionary alloc] init];
    note_comments = [[NSMutableDictionary alloc] init];
    game_info_recvd = 0;
}

- (BOOL) gameInfoRecvd
{
  return game_info_recvd >= 2;
}

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr
{
    [_SERVICES_ createNote:n withTag:t media:m trigger:tr]; //just forward to services
}
- (void) saveNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr
{
    [_SERVICES_ updateNote:n withTag:t media:m trigger:tr]; //just forward to services
}
- (void) deleteNoteId:(long)note_id
{
    [_SERVICES_ deleteNoteId:note_id]; //just forward to services
    [notes removeObjectForKey:[NSNumber numberWithLong:note_id]];
    [self invalidateCaches];
}

- (void) createNoteComment:(NoteComment *)n
{
    [_SERVICES_ createNoteComment:n]; //just forward to services
}
- (void) saveNoteComment:(NoteComment *)n
{
    [_SERVICES_ updateNoteComment:n]; //just forward to services
}
- (void) deleteNoteCommentId:(long)note_comment_id
{
    [_SERVICES_ deleteNoteCommentId:note_comment_id]; //just forward to services
    [note_comments removeObjectForKey:[NSNumber numberWithLong:note_comment_id]];
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

- (void) noteReceived:(NSNotification *)notif
{
  [self updateNotes:@[notif.userInfo[@"note"]]];
}

- (void) updateNotes:(NSArray *)newNotes
{
  [self invalidateCaches];
  Note *newNote;
  NSNumber *newNoteId;
  for(long i = 0; i < newNotes.count; i++)
  {
    newNote = [newNotes objectAtIndex:i];
    newNoteId = [NSNumber numberWithLong:newNote.note_id];
    if(!notes[newNoteId]) [notes setObject:newNote forKey:newNoteId];
  }
  game_info_recvd++;
  _ARIS_NOTIF_SEND_(@"MODEL_NOTES_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestNotes
{
  [_SERVICES_ fetchNotes];
}

- (void) noteCommentsReceived:(NSNotification *)notif
{
  [self updateNoteComments:notif.userInfo[@"note_comments"]];
}

- (void) noteCommentReceived:(NSNotification *)notif
{
  [self updateNoteComments:@[notif.userInfo[@"note_comment"]]];
}

- (void) updateNoteComments:(NSArray *)newNoteComments
{
  NoteComment *newComment;
  NSNumber *newCommentId;
  for(long i = 0; i < newNoteComments.count; i++)
  {
    newComment = [newNoteComments objectAtIndex:i];
    newCommentId = [NSNumber numberWithLong:newComment.note_comment_id];
    if(!note_comments[newCommentId]) [note_comments setObject:newComment forKey:newCommentId];
  }
  game_info_recvd++;
  _ARIS_NOTIF_SEND_(@"MODEL_NOTE_COMMENTS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestNoteComments
{
  [_SERVICES_ fetchNoteComments];
}

// null note (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (Note *) noteForId:(long)note_id
{
  if(!note_id) return [[Note alloc] init];
  return notes[[NSNumber numberWithLong:note_id]];
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
  for(long i = 0; i < ns.count; i++)
    if(((Note *)ns[i]).user_id == _MODEL_PLAYER_.user_id) [playerNotes addObject:ns[i]];
  return playerNotes;
}

- (NSArray *) listNotes
{
  if(listNotes) return listNotes;
  listNotes = [[NSMutableArray alloc] init];

  for(long i = 0; i < _MODEL_TRIGGERS_.playerTriggers.count; i++)
  {
    Trigger  *trigger  = _MODEL_TRIGGERS_.playerTriggers[i];
    Instance *instance = [_MODEL_INSTANCES_ instanceForId:trigger.instance_id];

    if([instance.object_type isEqualToString:@"NOTE"])
    {
      Note *note = (Note *)instance.object;
      if(note) [listNotes addObject:note];
    }
  }

  return listNotes;
}

- (NSArray *) notesMatchingTag:(Tag *)tag
{
  if(notesMatchingTag) return notesMatchingTag;
  notesMatchingTag = [[NSMutableArray alloc] init];
  NSArray *ns = [notes allValues];
  for(long i = 0; i < ns.count; i++)
  {
      NSArray *tags = [_MODEL_TAGS_ tagsForObjectType:@"NOTE" id:((Note *)ns[i]).note_id];
      for(long j = 0; j < tags.count; j++)
          if(tag == tags[j]) [notesMatchingTag addObject:ns[i]];
  }
  return notesMatchingTag;
}

// null note (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (NoteComment *) noteCommentForId:(long)note_comment_id
{
  if(!note_comment_id) return [[NoteComment alloc] init];
  return note_comments[[NSNumber numberWithLong:note_comment_id]];
}

- (NSArray *) noteComments
{
    return [note_comments allValues];
}

- (NSArray *) noteCommentsForNoteId:(long)note_id
{
  NSMutableArray *noteCommentsMatchingNote = [[NSMutableArray alloc] init];
  NSArray *ncs = [note_comments allValues];
  for(long i = 0; i < ncs.count; i++)
    if(((NoteComment *)ncs[i]).note_id == note_id) [noteCommentsMatchingNote addObject:ncs[i]];
  return _ARIS_ARRAY_SORTED_ON_(noteCommentsMatchingNote,@"created");
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
