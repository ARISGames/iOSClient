//
//  Playhead.m
//  ARIS
//
//  Created by Justin Moeller on 7/10/13.
//
//

#import "Playhead.h"
#import "UIColor+ARISColors.h"

@interface Playhead ()
{
    id<PlayheadControlDelegate> __unsafe_unretained delegate;
}
@end

@implementation Playhead

- (id) initWithFrame:(CGRect)f delegate:(id<PlayheadControlDelegate>)d
{
    if(self = [super initWithFrame:f])
    {
        delegate = d;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate playheadControl:self wasTouched:touches];
}

-(void) draw1PxStrokeForContext:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint color:(CGColorRef)color
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + .5, startPoint.y + .5);
    CGContextAddLineToPoint(context, endPoint.x + .5, endPoint.y + .5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (void) drawRect:(CGRect)rect
{
    CGContextRef cx = UIGraphicsGetCurrentContext();
    float currentPointX = (self.bounds.size.width) * [delegate getPlayProgress];
    CGPoint startPoint = CGPointMake(currentPointX, 0);
    CGPoint endPoint = CGPointMake(currentPointX, self.bounds.size.height);
    [self draw1PxStrokeForContext:cx startPoint:startPoint endPoint:endPoint color:[UIColor ARISColorRed].CGColor];
}

@end
