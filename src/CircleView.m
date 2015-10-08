//
//  CircleButton.m
//  ARIS
//
//  Created by Justin Moeller on 2/27/14.
//
//

#import "CircleView.h"

@interface CircleView()
{
    UIColor *fillColor;
    UIColor *strokeColor;
    long strokeWidth;
}
@end

@implementation CircleView

- (id) initWithFillColor:(UIColor *)fc strokeColor:(UIColor *)sc strokeWidth:(long)sw
{
    if(self = [super init])
    {
        fillColor = fc;
        strokeColor = sc;
        strokeWidth = sw;
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddArc(circlePath,nil,self.bounds.origin.x+self.bounds.size.height/2,self.bounds.origin.y+self.bounds.size.width/2,(self.bounds.size.width/2)-2,0,2*M_PI,YES);
    CGPathCloseSubpath(circlePath);

    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath);
    [fillColor set];
    CGContextFillPath(UIGraphicsGetCurrentContext());

    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath);
    [strokeColor set];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), strokeWidth);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
}

@end
