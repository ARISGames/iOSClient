//
//  NoteTagSelectorViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 3/19/14.
//
//

#import "ARISViewController.h"

@class NoteTagSelectorViewController;

@protocol NoteTagSelectorViewControllerDelegate
- (void) noteTagSelectorViewControllerRequestsDismissal:(NoteTagSelectorViewController *)n;
@end

@interface NoteTagSelectorViewController : ARISViewController
- (id) initWithDelegate:(id<NoteTagSelectorViewControllerDelegate>)d;
@end
