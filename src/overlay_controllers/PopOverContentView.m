//
//  PopOverContentView.m
//  ARIS
//
//  Created by Phil Dougherty on 1/7/13.
//
//

#import "PopOverContentView.h"

@implementation PopOverContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.6f, 0.6f, 0.6f, 1.0f);
    //CGRect rrect = CGRectMake(mainViewMedia.frame.origin.x+2.5f, mainViewMedia.frame.origin.y+2.5f, mainViewMedia.frame.size.width-5.0f, mainViewMedia.frame.size.height-5.0f);
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
