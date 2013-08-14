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
- (void) ARISCollapseView:(ARISCollapseView *)a opened:(BOOL)o;
@end

@interface ARISCollapseView : UIView
- (id) initWithView:(UIView *)v frame:(CGRect)f open:(BOOL)o delegate:(id<ARISCollapseViewDelegate>)d;
- (void) setOpenFrame:(CGRect)f;
- (void) setOpenFrameHeight:(CGFloat)h;
@end
