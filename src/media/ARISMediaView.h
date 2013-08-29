//
//  ARISMediaView.h
//  ARIS
//
//  Created by Phil Dougherty on 8/1/13.
//
//

#import <UIKit/UIKit.h>
#import "Media.h"

typedef enum
{
ARISMediaDisplayModeDefault,
ARISMediaDisplayModeAspectFill,
ARISMediaDisplayModeStretchFill,
ARISMediaDisplayModeAspectFit,
ARISMediaDisplayModeTopAlignAspectFitWidth,
ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight
} ARISMediaDisplayMode;

@class ARISMediaView;
@protocol ARISMediaViewDelegate
- (void) ARISMediaViewUpdated:(ARISMediaView *)amv;
@end

@interface ARISMediaView : UIView

- (id) initWithFrame:(CGRect)frame media:(Media *)m   mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;
- (id) initWithFrame:(CGRect)frame image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;

- (void) refreshWithFrame:(CGRect)f;
- (void) refreshWithFrame:(CGRect)frame media:(Media *)m   mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;
- (void) refreshWithFrame:(CGRect)frame image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;

- (UIImage *) image;

@end
