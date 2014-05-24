//
//  DialogScriptViewController.h
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

@protocol DialogScriptViewControllerDelegate
- (void) scriptEndedExitToType:(NSString *)type title:(NSString *)title id:(int)typeId;
- (void) scriptRequestsTitle:(NSString *)t;
//Variable changes on the 'global' dialog level (an indication that these properties are being set on the wrong level of heirarchy)
- (void) scriptRequestsHideLeaveConversation:(BOOL)h;
- (void) scriptRequestsLeaveConversationTitle:(NSString *)t;
- (void) scriptRequestsOptionsPcTitle:(NSString *)s;
- (void) scriptRequestsOptionsPcMedia:(Media *)m;
@end

@interface DialogScriptViewController : ARISViewController
- (id) initWithDialog:(Dialog *)n frame:(CGRect)f delegate:(id<DialogScriptViewControllerDelegate>)d;
- (void) loadScriptOption:(DialogScriptOption *)s;
@end
