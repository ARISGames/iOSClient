//
//  ARISCollapseView.h
//  ARIS
//
//  Created by Phil Dougherty on 8/12/13.
//
//

#import <UIKit/UIKit.h>

@class ARISCollapseView;

@protocol ARISCollapseViewDelegate
@optional 
- (void) collapseView:(ARISCollapseView *)cv didStartOpen:(BOOL)o;
- (void) collapseView:(ARISCollapseView *)cv didFinishOpen:(BOOL)o;
@end

@interface ARISCollapseView : UIView
- (id) initWithView:(UIView *)v frame:(CGRect)f open:(BOOL)o showHandle:(BOOL)h draggable:(BOOL)d tappable:(BOOL)t delegate:(id<ARISCollapseViewDelegate>)del;
- (void) setOpenFrame:(CGRect)f;
- (void) setOpenFrameHeight:(CGFloat)h; //sets open frame while keeping bottom in same spot
- (void) open;
- (void) close;

//use to add drag/tap areas outside of the collapse view
- (void) handleTapped:(UITapGestureRecognizer *)g;
- (void) handlePanned:(UIPanGestureRecognizer *)g;

@end
