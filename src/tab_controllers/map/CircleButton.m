//
//  CircleButton.m
//  ARIS
//
//  Created by Justin Moeller on 2/27/14.
//
//

#import "CircleButton.h"
#import "UIColor+ARISColors.h"

@implementation CircleButton

- (void) drawRect:(CGRect)rect
{
    CGMutablePathRef circlePath = CGPathCreateMutable(); 
    CGPathAddArc(circlePath,nil,self.bounds.origin.x+self.bounds.size.height/2,self.bounds.origin.y+self.bounds.size.width/2,(self.bounds.size.width/2)-2,0,2*M_PI,YES);
    CGPathCloseSubpath(circlePath);
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath);
    if(self.enabled) [[UIColor ARISColorDarkBlue] set];  
    else             [[UIColor ARISColorLightBlue] set];  
    CGContextFillPath(UIGraphicsGetCurrentContext());
    
    CGContextAddPath(UIGraphicsGetCurrentContext(), circlePath); 
    if(self.enabled) [[UIColor whiteColor] set];  
    else             [[UIColor grayColor] set];   
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0f);
    CGContextStrokePath(UIGraphicsGetCurrentContext()); 
    
    if(self.enabled) [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; 
    else             [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal]; 
}

@end
