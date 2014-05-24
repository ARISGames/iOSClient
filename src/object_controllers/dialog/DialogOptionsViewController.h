//
//  DialogOptionsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Dialog;
@class DialogScriptOption;
@class Media;
@protocol DialogOptionsViewControllerDelegate
- (void) leaveConversationRequested;
- (void) optionChosen:(DialogScriptOption *)o;
- (void) optionsRequestsTitle:(NSString *)t;
@end

@interface DialogOptionsViewController : ARISViewController
- (id) initWithFrame:(CGRect)f delegate:(id<DialogOptionsViewControllerDelegate>)d;
- (void) loadOptionsForDialog:(Dialog *)n afterViewingOption:(DialogScriptOption *)o;
- (void) setDefaultTitle:(NSString *)t;
- (void) setDefaultMedia:(Media *)m;
- (void) setShowLeaveConversationButton:(BOOL)s;
- (void) setLeaveConversationTitle:(NSString *)t;
@end
