//
//  NpcOptionsViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import <UIKit/UIKit.h>
#import "ARISViewController.h"

@class Npc;
@class NpcScriptOption;
@class Media;
@protocol NpcOptionsViewControllerDelegate
- (void) leaveConversationRequested;
- (void) optionChosen:(NpcScriptOption *)o;
- (void) optionsRequestsTitle:(NSString *)t;
@end

@interface NpcOptionsViewController : ARISViewController
- (id) initWithFrame:(CGRect)f delegate:(id<NpcOptionsViewControllerDelegate>)d;
- (void) loadOptionsForNpc:(Npc *)n afterViewingOption:(NpcScriptOption *)o;
- (void) setDefaultTitle:(NSString *)t;
- (void) setDefaultMedia:(Media *)m;
- (void) setShowLeaveConversationButton:(BOOL)s;
- (void) setLeaveConversationTitle:(NSString *)t;
@end
