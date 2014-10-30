//
//  NotesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Note.h"

@class Tag;
@class Media;
@class Trigger;

@interface NotesModel : NSObject
{
}

- (Note *) noteForId:(int)note_id;
- (void) requestNotes;
- (void) clearGameData;

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) saveNote:(Note *)n withTag:(Tag *)t media:(Media *)m trigger:(Trigger *)tr;
- (void) deleteNoteId:(int)note_id;

- (NSArray *) notes;
- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) notesMatchingTag:(Tag *)tag;

@end
