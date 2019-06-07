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

@protocol DialogScriptViewControllerDelegate <NSObject>
- (void) dialogScriptChosen:(DialogScript *)s;
- (void) setNavTitle:(NSString *)s;
- (void) exitRequested;
- (void) popupWithContent:(NSString *)s;
@end

@interface DialogScriptViewController : ARISViewController
{
    Dialog *dialog;
}
- (id) initWithDialog:(Dialog *)n delegate:(id<DialogScriptViewControllerDelegate>)d;
- (void) loadScript:(DialogScript *)s guessedHeight:(long)h;
- (void) clearText;
- (long) heightOfTextBox;
@property (nonatomic, strong) Dialog *dialog;
@end
