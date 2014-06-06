//
//  NoteLocationPickerCrosshairsView.m
//  ARIS
//
//  Created by Phil Dougherty on 2/3/14.
//
//

#import "NoteLocationPickerCrosshairsView.h"

@implementation NoteLocationPickerCrosshairsView

- (id) init
{
    if(self = [super init])
    {
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGPoint mid = CGPointMake(self.bounds.origin.x+(self.bounds.size.width/2),self.bounds.origin.y+(self.bounds.size.height/2));
    
    CGMutablePathRef path = CGPathCreateMutable(); 
    CGPathMoveToPoint(path, NULL, mid.x, mid.y);
    CGPathAddLineToPoint(path, NULL, mid.x, self.bounds.origin.y                       );
    CGPathAddLineToPoint(path, NULL, mid.x, self.bounds.origin.y+self.bounds.size.height); 
    CGPathAddLineToPoint(path, NULL, mid.x, mid.y); 
    CGPathAddLineToPoint(path, NULL, self.bounds.origin.x                      , mid.y);
    CGPathAddLineToPoint(path, NULL, self.bounds.origin.x+self.bounds.size.width, mid.y); 
    CGPathCloseSubpath(path);
    
    [[UIColor ARISColorTranslucentBlack] set];
    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0); 
    CGContextStrokePath(UIGraphicsGetCurrentContext());
}

@end
