//
//  NotesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "NoteComment.h"

@class Tag;
@class Media;
@class Trigger;

@interface NotesModel : NSObject
{
}

- (Note *) noteForId:(int)note_id;
- (void) requestNotes;

- (NoteComment *) noteCommentForId:(int)note_comment_id;
- (void) requestNoteComments;

- (void) clearGameData;

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) saveNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) deleteNoteId:(int)note_id;

- (void) createNoteComment:(NoteComment *)n;
- (void) saveNoteComment:(NoteComment *)n;
- (void) deleteNoteCommentId:(int)note_comment_id;

- (NSArray *) notes;
- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) notesMatchingTag:(Tag *)tag;
- (NSArray *) noteComments;
- (NSArray *) noteCommentsForNoteId:(int)note_id;

@end
