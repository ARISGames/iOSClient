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

@interface NotesModel : NSObject
{
}

- (Note *) noteForId:(int)note_id;
- (void) requestNotes;
- (void) clearGameData;

- (void) createNote:(Note *)n withTag:(Tag *)t media:(Media *)m;

- (NSArray *) notes;
- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) notesMatchingTag:(Tag *)tag;

@end
