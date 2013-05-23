//
//  NoteCommentViewController.h
//  ARIS
//
//  Created by Brian Thiel on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;
@interface NoteCommentViewController : UIViewController
- (id)initWithNote:(Note *)n delegate:(id)d;
@end
