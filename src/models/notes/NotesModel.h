//
//  NotesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Note.h"

@class NoteTag;

@interface NotesModel : NSObject

- (void) clearData;

- (void) getNextNotes;
- (int) listComplete;
- (void) getNoteTags;

- (Note *) noteForId:(int)noteId;
- (void) getDetailsForNote:(Note *)n;
- (void) deleteNote:(Note *)n;

- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) mapNotes;
- (NSArray *) notesMatchingTag:(NoteTag *)t;

- (NSArray *) gameNoteTags;
- (NSArray *) playerNoteTags;

- (NoteTag *) unlabeledTag; //accessor for default tag

@end
