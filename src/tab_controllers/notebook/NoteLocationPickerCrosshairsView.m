//
//  NoteLocationPickerCrosshairsView.m
//  ARIS
//
//  Created by Phil Dougherty on 2/3/14.
//
//

#import "NoteLocationPickerCrosshairsView.h"
#import "ARISTemplate.h"

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

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGPoint mid = CGPointMake(rect.origin.x+(rect.size.width/2),rect.origin.y+(rect.size.height/2));
    
    CGMutablePathRef path = CGPathCreateMutable(); 
    CGPathMoveToPoint(path, NULL, mid.x, mid.y);
    CGPathAddLineToPoint(path, NULL, mid.x, rect.origin.y                 );
    CGPathAddLineToPoint(path, NULL, mid.x, rect.origin.y+rect.size.height); 
    CGPathAddLineToPoint(path, NULL, mid.x, mid.y); 
    CGPathAddLineToPoint(path, NULL, rect.origin.x                , mid.y);
    CGPathAddLineToPoint(path, NULL, rect.origin.x+rect.size.width, mid.y); 
    CGPathCloseSubpath(path);
    
    [[UIColor ARISColorTranslucentBlack] set];   
    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0); 
    CGContextStrokePath(UIGraphicsGetCurrentContext());
}

@end
