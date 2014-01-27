//
//  NotesModel.h
//  ARIS
//
//  Created by Phil Dougherty on 11/11/13.
//
//

#import <Foundation/Foundation.h>
#import "Note.h"

@interface NotesModel : NSObject

- (void) clearData;

- (void) getNextNotes;
- (int) listComplete;
- (void) getNoteTags;

- (Note *) noteForId:(int)noteId;
- (void) getDetailsForNote:(Note *)n;

- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) mapNotes;

- (NSArray *) gameNoteTags;
- (NSArray *) playerNoteTags;

@end
