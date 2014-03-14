//
//  CircleButton.m
//  ARIS
//
//  Created by Justin Moeller on 2/27/14.
//
//

#import "CircleView.h"
#import "UIColor+ARISColors.h"

@interface CircleView()
{
    UIColor *backgroundColor;
    UIColor *strokeColor; 
    int strokeWidth;
}
@end

@implementation CircleView

- (id) initWithBackgroundColor:(UIColor *)b strokeColor:(UIColor *)s
{
    if(self = [super init])
    {
        backgroundColor = b;
        strokeColor = s; 
        strokeWidth = 2; 
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    CGMutablePathRef circlePath = CGPathCreateMutable(); 
    CGPathAddArc(circlePath,nil,self.bounds.origin.x+self.bounds.size.height/2,self.bounds.origin.y+self.bounds.size.width/2,(self.bounds.size.width/2)-2,0,2*M_PI,YES);
    CGPathCloseSubpath(circlePath);
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath);
    [backgroundColor set];  
    CGContextFillPath(UIGraphicsGetCurrentContext());
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath); 
    [strokeColor set];   
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), strokeWidth);
    CGContextStrokePath(UIGraphicsGetCurrentContext()); 
}

@end
