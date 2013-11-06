//
//  NoteViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "GameObjectViewController.h"

@class Note;
@protocol NoteViewControllerDelegate
@end

@interface NoteViewController : GameObjectViewController
- (id) initWithNote:(Note *)n delegate:(id<GameObjectViewControllerDelegate, NoteViewControllerDelegate>)d;
@end
