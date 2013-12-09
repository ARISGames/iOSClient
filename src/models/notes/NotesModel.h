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
- (Note *) noteForId:(int)noteId;
- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) mapNotes;

- (int) listComplete;

@end
