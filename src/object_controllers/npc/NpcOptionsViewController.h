//
//  NpcOptionsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import <UIKit/UIKit.h>

@class Npc;
@class NpcScriptOption;
@protocol NpcOptionsViewControllerDelegate
- (void) leaveConversationRequested;
- (void) optionChosen:(NpcScriptOption *)o;
- (void) optionsRequestsTitle:(NSString *)t;
- (void) optionsRequestsTextBoxSize:(int)s;
@end

@interface NpcOptionsViewController : UIViewController
- (id) initWithFrame:(CGRect)f delegate:(id<NpcOptionsViewControllerDelegate>)d;
- (void) loadOptionsForNpc:(Npc *)n afterViewingOption:(NpcScriptOption *)o;
- (void) setDefaultTitle:(NSString *)t;
- (void) setShowLeaveConversationButton:(BOOL)s;
- (void) setLeaveConversationTitle:(NSString *)t;
- (void) toggleNextTextBoxSize;
- (void) toggleTextBoxSize:(int)s;
@end
