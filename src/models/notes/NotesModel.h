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
    NSArray *currentNotes;
}

@property (nonatomic, strong) NSArray *currentNotes;

- (void) clearData;
- (Note *) noteForId:(int)noteId;
- (NSArray *) playerNotes;
- (NSArray *) listNotes;
- (NSArray *) mapNotes;

@end
