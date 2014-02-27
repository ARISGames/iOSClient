//
//  NpcScriptElementView.h
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import <UIKit/UIKit.h>
#import "Media.h"

@class ScriptElement;
@class NpcScriptElementView;

@protocol NpcScriptElementViewDelegate
- (void) scriptElementViewRequestsTitle:(NSString *)t;
- (void) scriptElementViewRequestsHideContinue:(BOOL)h;
@end

@interface NpcScriptElementView : UIView
- (id) initWithFrame:(CGRect)f media:(Media *)m   title:(NSString *)t delegate:(id)d;
- (id) initWithFrame:(CGRect)f image:(UIImage *)i title:(NSString *)t delegate:(id)d;
- (void) loadScriptElement:(ScriptElement *)s;
- (void) fadeWithCallback:(SEL)s;
- (void) stopVideoIfPlaying;
@end
