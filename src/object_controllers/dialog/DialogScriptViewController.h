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
@class DialogScript;

@protocol DialogScriptViewControllerDelegate
- (void) dialogScriptChosen:(DialogScript *)s;
- (void) setNavTitle:(NSString *)s;
- (void) exitRequested;
@end

@protocol StateControllerProtocol;
@interface DialogScriptViewController : ARISViewController
- (id) initWithDialog:(Dialog *)n delegate:(id<DialogScriptViewControllerDelegate, StateControllerProtocol>)d;
- (void) loadScript:(DialogScript *)s guessedHeight:(int)h;
- (int) heightOfTextBox;
@end
