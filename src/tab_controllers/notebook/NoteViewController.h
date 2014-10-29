//
//  NoteViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 11/5/13.
//
//

#import "ARISViewController.h"
#import "InstantiableViewControllerProtocol.h"

@protocol StateControllerProtocol;
@protocol NoteViewControllerDelegate <InstantiableViewControllerDelegate>
@end

@class Instance;
@interface NoteViewController : ARISViewController <InstantiableViewControllerProtocol>
- (id) initWithInstance:(Instance *)i delegate:(id<NoteViewControllerDelegate>)d;
@end

