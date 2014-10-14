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
{
}

- (Note *) noteForId:(int)note_id;
- (void) requestNotes;
- (void) clearGameData;

@end
