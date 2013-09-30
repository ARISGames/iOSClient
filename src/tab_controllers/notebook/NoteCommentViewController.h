//
//  NoteCommentViewController.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Note;
@interface NoteCommentViewController : ARISViewController
- (id) initWithNote:(Note *)n delegate:(id)d;
@end
