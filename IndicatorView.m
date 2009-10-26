//
//  IndicatorView.m
//  fun with button bars
//
//  Created by Brian Deith on 5/20/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "IndicatorView.h"

#define PI 3.141592653589793


@implementation IndicatorView

@synthesize expanded;
@synthesize fillColor;
@synthesize translationPoint;
@synthesize homePoint;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		expanded = NO;
		[self setFillColor:[UIColor blackColor]];
		homePoint = self.center;
    }
    return self;
}


- (void)setFillColor:(UIColor *)newColor {
	[fillColor release];
	fillColor = [newColor retain];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect    myFrame = self.bounds;
	
    CGContextSetLineWidth(context, 10);
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, myFrame.origin.x, myFrame.origin.y);
	CGContextAddLineToPoint(context, myFrame.origin.x + myFrame.size.width, myFrame.origin.y + (myFrame.size.height / 2.0));
	CGContextAddLineToPoint(context, myFrame.origin.x, myFrame.origin.y + myFrame.size.height);
	CGContextAddLineToPoint(context, myFrame.origin.x, myFrame.origin.y);
	CGContextClosePath(context);
	
    [self.fillColor set];
	CGContextFillPath(context);
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL)isOpaque {
	return NO;
}

- (void)setExpanded:(BOOL)newExpanded {
	if (newExpanded != expanded) {
		if (!expanded) {
			[UIView beginAnimations:nil context:nil];
			self.transform = CGAffineTransformMakeRotation(PI/2.0);
			self.center = translationPoint;
			[self setFillColor:[UIColor darkGrayColor]];
			[UIView commitAnimations];
			expanded = YES;
		} else {
			[UIView beginAnimations:nil context:nil];
			self.transform = CGAffineTransformMakeRotation(0.0);
			self.center = homePoint;
			[self setFillColor:[UIColor blackColor]];
			[UIView commitAnimations];
			expanded = NO;
		}
	}
}

@end
