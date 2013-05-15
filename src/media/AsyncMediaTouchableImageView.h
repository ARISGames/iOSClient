//
//  AsyncMediaTouchableImageView.h
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import "AsyncMediaImageView.h"

@protocol AsyncMediaTouchableImageViewDelegate <NSObject>
@optional
-(void) asyncMediaImageTouched:(id)sender;
@end

@interface AsyncMediaTouchableImageView : AsyncMediaImageView

@end
