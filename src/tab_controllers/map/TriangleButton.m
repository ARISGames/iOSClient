//
//  TriangleButton.m
//  ARIS
//
//  Created by Justin Moeller on 3/14/14.
//
//

#import "TriangleButton.h"

@interface TriangleButton(){
    UIColor *triangleColor;
    BOOL isPointingLeft;
    Location *location;
}

@end

@implementation TriangleButton
@synthesize location;

- (id)initWithColor:(UIColor *)color isPointingLeft:(BOOL)pointingLeft
{
    self = [super init];
    if (self) {
        triangleColor = color;
        isPointingLeft = pointingLeft;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isPointingLeft) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMidY(rect));
        CGContextClosePath(context);
        //move the title label over
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    }
    else{
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMidY(rect));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGContextClosePath(context);
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f)];
    }

    
    const CGFloat *colorComponents = CGColorGetComponents(triangleColor.CGColor);
    CGContextSetRGBFillColor(context, colorComponents[0], colorComponents[1], colorComponents[2], 1);
    CGContextFillPath(context);
}

- (void) setLocation:(Location *)l
{
    location = l;
}


@end
