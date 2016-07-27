//
//  NotesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "ARISModel.h"
#import "Note.h"
#import "NoteComment.h"

@class Tag;
@class Media;
@class Trigger;

@interface NotesModel : ARISModel

- (Note *) noteForId:(long)note_id;
- (void) requestNotes;

- (NoteComment *) noteCommentForId:(long)note_comment_id;
- (void) requestNoteComments;

- (void) invalidateCaches;

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) saveNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) deleteNoteId:(long)note_id;

- (void) createNoteComment:(NoteComment *)n;
- (void) saveNoteComment:(NoteComment *)n;
- (void) deleteNoteCommentId:(long)note_comment_id;

- (NSArray *) notes;
- (NSArray *) playerNotes;
- (long) qtyPlayerMediaOfType:(NSString *)type Within:(long)distance Lat:(double)lat Long:(double)lng;
- (NSArray *) listNotes;
- (NSArray *) notesMatchingTag:(Tag *)tag;
- (NSArray *) noteComments;
- (NSArray *) noteCommentsForNoteId:(long)note_id;

@end

