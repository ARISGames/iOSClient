//
//  TutorialPopupView.m
//  ARIS
//
//  Created by David J Gagnon on 2/16/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "TutorialPopupView.h"
#import "ARISAppDelegate.h"


@implementation TutorialPopupView

@synthesize pointerXpos;
@synthesize title;
@synthesize message;
@synthesize associatedViewController;

- (id) init
{
    if(self = [super initWithFrame:CGRectMake(10.0, 290.0, 300.0, 140.0)])
    {
		self.opaque = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointerPosition) name:@"TabBarItemsChanged" object:nil];
	}
    return self;
}

- (void) drawRect:(CGRect)rect
{
	[self updatePointerPosition];
	
	CGFloat pointerLength = 20.0;
	CGFloat pointerWidth = 20.0;
	CGFloat textMargin = 10.0;
	CGFloat titleHeight = 22.0;
	
	CGRect titleRect = CGRectMake(CGRectGetMinX(self.bounds) + textMargin, textMargin,
								  CGRectGetMaxX(self.bounds) - 2*textMargin, titleHeight);
	CGRect messageRect = CGRectMake(CGRectGetMinX(self.bounds) + textMargin, CGRectGetMaxY(titleRect) + textMargin, 
									CGRectGetMaxX(self.bounds) - 2*textMargin, CGRectGetMaxY(self.bounds));
		
	CGPoint pointerPoint = CGPointMake(self.pointerXpos,  CGRectGetMaxY(self.bounds));
	CGFloat radius = 7.0;
	
	CGMutablePathRef popupPath = CGPathCreateMutable();
	CGPathMoveToPoint(popupPath, NULL, CGRectGetMinX(self.bounds) + radius, CGRectGetMinY(self.bounds));
    CGPathAddArc(popupPath, NULL, CGRectGetMaxX(self.bounds) - radius, CGRectGetMinY(self.bounds) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGPathAddArc(popupPath, NULL, CGRectGetMaxX(self.bounds) - radius, CGRectGetMaxY(self.bounds) - radius - pointerLength, radius, 0, M_PI / 2, 0);
	CGPathAddLineToPoint(popupPath, NULL, pointerPoint.x + pointerWidth/2, CGRectGetMaxY(self.bounds) - pointerLength);
	CGPathAddLineToPoint(popupPath, NULL, pointerPoint.x, pointerPoint.y);
	CGPathAddLineToPoint(popupPath, NULL, pointerPoint.x - pointerWidth/2,  CGRectGetMaxY(self.bounds) - pointerLength);
    CGPathAddArc(popupPath, NULL, CGRectGetMinX(self.bounds) + radius, CGRectGetMaxY(self.bounds) - radius - pointerLength, radius, M_PI / 2, M_PI, 0);
    CGPathAddArc(popupPath, NULL, CGRectGetMinX(self.bounds) + radius, CGRectGetMinY(self.bounds) + radius, radius, M_PI, 3 * M_PI / 2, 0);	
    CGPathCloseSubpath(popupPath);
	
	CGContextAddPath(UIGraphicsGetCurrentContext(), popupPath);
	[[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.98] set];
	CGContextFillPath(UIGraphicsGetCurrentContext());
	[[UIColor whiteColor] set];
	[self.title drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:20] lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
	[self.message drawInRect:messageRect withFont: [UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
	CGContextAddPath(UIGraphicsGetCurrentContext(), popupPath);
	CGContextStrokePath(UIGraphicsGetCurrentContext());	 
}

-(void) updatePointerPosition
{
	NSLog(@"TutorialPopupView: updatePointerPosition");
	//PHIL int tabIndex = [[RootViewController sharedRootViewController].gamePlayTabBarController.viewControllers indexOfObject:self.associatedViewController];
	//PHIL self.pointerXpos = 22.0 + tabIndex * self.superview.frame.size.width / 5;
	[self setNeedsDisplay];  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
