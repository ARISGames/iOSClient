//
//  NpcScriptViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import <UIKit/UIKit.h>

@class Npc;
@class NpcScriptOption;

@protocol NpcScriptViewControllerDelegate
- (void) scriptEndedExitToType:(NSString *)type title:(NSString *)title id:(int)typeId;
- (void) scriptRequestsTitle:(NSString *)t;
//Variable changes on the 'global' npc level (an indication that these properties are being set on the wrong level of heirarchy)
- (void) scriptRequestsHideLeaveConversation:(BOOL)h;
- (void) scriptRequestsLeaveConversationTitle:(NSString *)t;
- (void) scriptRequestsOptionsPcTitle:(NSString *)s;
- (void) scriptRequestsTextBoxSize:(int)s;
@end

@interface NpcScriptViewController : UIViewController
- (id) initWithNpc:(Npc *)n frame:(CGRect)f delegate:(id<NpcScriptViewControllerDelegate>)d;
- (void) loadScriptOption:(NpcScriptOption *)s;
- (void) toggleNextTextBoxSize;
- (void) toggleTextBoxSize:(int)s;
@end
