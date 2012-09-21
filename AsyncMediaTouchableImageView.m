//
//  AsyncMediaTouchableImageView.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import "AsyncMediaTouchableImageView.h"

@implementation AsyncMediaTouchableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:(@selector(asyncMediaImageTouched:))])
        [(UIView <AsyncMediaTouchableImageViewDelegate> *)self.delegate asyncMediaImageTouched:self];
}

@end
