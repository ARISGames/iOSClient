//
//  CircleButton.m
//  ARIS
//
//  Created by Justin Moeller on 2/27/14.
//
//

#import "CircleButton.h"
#import "UIColor+ARISColors.h"

@interface CircleButton (){
    CAShapeLayer *circleLayer;
    UIColor *color;
}
@end

@implementation CircleButton

- (void)drawCircleButton:(UIColor *)c
{
    color = c;
    circleLayer = [CAShapeLayer layer];
    [circleLayer setBounds:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height)];
    [circleLayer setPosition:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [circleLayer setPath:[path CGPath]];
    [circleLayer setStrokeColor:[color CGColor]];
    [circleLayer setLineWidth:2.0f];
    [circleLayer setFillColor:[[UIColor blueColor] CGColor]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self layer] addSublayer:circleLayer];
    if (self.enabled) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    [self bringSubviewToFront:self.titleLabel];
}

- (void) drawRect:(CGRect)rect
{
    [self drawCircleButton:[UIColor blueColor]];
}

@end
