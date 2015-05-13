//
//  CircleButton.m
//  ARIS
//
//  Created by Justin Moeller on 2/27/14.
//
//

#import "CircleButton.h"

@interface CircleButton()
{
    UIColor *fillColor;
    UIColor *strokeColor;
    UIColor *titleColor;
    UIColor *disabledFillColor;
    UIColor *disabledStrokeColor;
    UIColor *disabledTitleColor;
    long strokeWidth;
}
@end

@implementation CircleButton

- (id) initWithFillColor:(UIColor *)fc strokeColor:(UIColor *)sc titleColor:(UIColor *)tc disabledFillColor:(UIColor *)dfc disabledStrokeColor:(UIColor *)dsc disabledtitleColor:(UIColor *)dtc strokeWidth:(long)sw
{
    if(self = [super init])
    {
        fillColor = fc;
        strokeColor = sc;
        titleColor = tc;
        disabledFillColor = dfc;
        disabledStrokeColor = dsc;
        disabledTitleColor = dtc;
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
    if(self.enabled) [fillColor set];
    else             [disabledFillColor set];
    CGContextFillPath(UIGraphicsGetCurrentContext());

    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath);
    if(self.enabled) [strokeColor set];
    else             [disabledStrokeColor set];
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), strokeWidth);
    CGContextStrokePath(UIGraphicsGetCurrentContext());

    if(self.enabled) [self setTitleColor:titleColor forState:UIControlStateNormal];
    else             [self setTitleColor:disabledTitleColor forState:UIControlStateNormal];
}

@end
