//
//  NoteCell.h
//  ARIS
//
//  Created by Brian Thiel on 8/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Note;

@interface NoteCell : UITableViewCell
- (void) setupWithNote:(Note *)n delegate:(id)d;
@end
