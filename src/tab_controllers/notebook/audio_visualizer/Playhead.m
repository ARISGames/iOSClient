//
//  Playhead.m
//  ARIS
//
//  Created by Justin Moeller on 7/10/13.
//
//

#import "Playhead.h"
#import "UIColor+ARISColors.h"

@implementation Playhead

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark -
#pragma mark Touch Handling
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate playheadControl:self wasTouched:touches];
}

-(void) draw1PxStrokeForContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(CGColorRef)color{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + .5, startPoint.y + .5);
    CGContextAddLineToPoint(context, endPoint.x + .5, endPoint.y + .5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef cx = UIGraphicsGetCurrentContext();
    float currentPointX = (self.bounds.size.width) * [self.delegate getPlayProgress];
    CGPoint startPoint = CGPointMake(currentPointX, 0);
    CGPoint endPoint = CGPointMake(currentPointX, self.bounds.size.height);
    [self draw1PxStrokeForContext:cx startPoint:startPoint endPoint:endPoint color:[UIColor ARISColorRed].CGColor];
}


@end
