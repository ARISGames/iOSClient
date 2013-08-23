//
//  PopOverContentView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/7/13.
//
//

#import "PopOverContentView.h"

@implementation PopOverContentView

- (void) drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 0.9f);
    CGRect rrect = CGRectMake(2.0f,2.0f,self.frame.size.width-4.0f,self.frame.size.height-4.0f);
    CGFloat radius = 15.0f;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
