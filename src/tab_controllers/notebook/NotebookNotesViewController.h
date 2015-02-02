//
//  NotebookViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/4/13.
//
//

#import "ARISViewController.h"

@class Tag;
@class NotebookNotesViewController;

@protocol NotebookNotesViewControllerDelegate
- (void) notesViewControllerRequestsDismissal:(NotebookNotesViewController *)n;
@end

@interface NotebookNotesViewController : ARISViewController

- (id) initWithDelegate:(id<NotebookNotesViewControllerDelegate>)d;

- (void) setModeAll;
- (void) setModeMine;
- (void) setModeTag:(Tag *)t;

@end
