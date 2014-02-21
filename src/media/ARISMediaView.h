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
@optional
- (void) ARISMediaViewUpdated:(ARISMediaView *)amv;
- (void) ARISMediaViewFinishedPlayback:(ARISMediaView *)amv;
- (BOOL) ARISMediaViewShouldPlayButtonTouched:(ARISMediaView *)amv;
@end

@interface ARISMediaView : UIView

- (id) initWithDelegate:(id<ARISMediaViewDelegate>)d;
- (id) initWithFrame:(CGRect)f media:(Media *)m   mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;
- (id) initWithFrame:(CGRect)f image:(UIImage *)i mode:(ARISMediaDisplayMode)dm delegate:(id<ARISMediaViewDelegate>)d;
- (void) setFrame:(CGRect)f withMode:(ARISMediaDisplayMode)dm;
- (void) setMedia:(Media *)m;
- (void) setImage:(UIImage *)i;
- (void) setDelegate:(id<ARISMediaViewDelegate>)d;
- (void) play;

@property (nonatomic, readwrite) Media *media;

@end
