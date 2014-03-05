//
//  AnnotationView.m
//  ARIS
//
//  Created by Brian Deith on 8/11/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "AnnotationView.h"
#import "ARISTemplate.h"
#import "Media.h"
#import "Location.h"
#import "AppModel.h"
#import "ARISMediaView.h"

@interface AnnotationView() <ARISMediaViewDelegate>
{
	CGRect titleRect;
	CGRect bubbleRect;
	UIView *iconBorderView;
   	ARISMediaView *iconView; 
    bool showTitle;
    bool shouldWiggle;
    float totalWiggleOffsetFromOriginalPosition;
    float incrementalWiggleOffset;
    float xOnSinWave;
}
@end

@implementation AnnotationView

- (id) initWithAnnotation:(id<MKAnnotation>)location reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithAnnotation:location reuseIdentifier:reuseIdentifier])
    {
        Location *loc = (Location *)location;
        
        loc.title = nil;
        if(![loc.name isEqualToString:@""])
            loc.title = loc.name;
        
        showTitle = (loc.showTitle && loc.title) ? YES : NO;
        shouldWiggle = loc.wiggle;
        totalWiggleOffsetFromOriginalPosition = 0;
        incrementalWiggleOffset = 0;
        xOnSinWave = 0;

        CGRect imageViewFrame = CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT); 
        CGSize titleSize = CGSizeMake(0.0f,0.0f); 
        titleRect = CGRectMake(0,0,0,0);
        
        if(showTitle)
        {
            if(loc.title) titleSize = [loc.title sizeWithFont:[ARISTemplate ARISAnnotFont]]; 
            int maxWidth = (titleSize.width < ANNOTATION_MAX_WIDTH) ? titleSize.width : ANNOTATION_MAX_WIDTH;
            if(loc.title) titleRect = CGRectMake(0, 0, maxWidth, titleSize.height-6);
            
            titleRect = CGRectOffset(titleRect, ANNOTATION_PADDING, IMAGE_HEIGHT+POINTER_LENGTH+ANNOTATION_PADDING);
            
            bubbleRect = titleRect;
            bubbleRect.origin.x    -= ANNOTATION_PADDING;  
            bubbleRect.origin.y    -= ANNOTATION_PADDING; 
            bubbleRect.size.width  += ANNOTATION_PADDING*2;
            bubbleRect.size.height += ANNOTATION_PADDING*2;
            
            titleRect.origin.y -=3;
            
            if(IMAGE_WIDTH < bubbleRect.size.width)
                self.centerOffset = CGPointMake((bubbleRect.size.width-IMAGE_WIDTH)/2, (bubbleRect.size.height+POINTER_LENGTH)/2); 
            else
                self.centerOffset = CGPointMake(0, (bubbleRect.size.height+POINTER_LENGTH)/2);  
            
            [self setFrame:CGRectUnion(bubbleRect, imageViewFrame)]; 
        }
        else
            [self setFrame:imageViewFrame];  
        
        iconBorderView = [[UIView alloc] initWithFrame:imageViewFrame];
        iconBorderView.backgroundColor = [UIColor whiteColor];
        iconBorderView.layer.borderColor = [UIColor ARISColorLightBlue].CGColor;
        iconBorderView.layer.borderWidth = 2.0f;
        
        CGRect imageInnerFrame = imageViewFrame;
        imageInnerFrame.origin.x += 2.0f;
        imageInnerFrame.origin.y += 2.0f; 
        imageInnerFrame.size.width -= 4.0f;
        imageInnerFrame.size.height -= 4.0f;  
        
        if(loc.gameObject.iconMediaId != 0)
            iconView = [[ARISMediaView alloc] initWithFrame:imageInnerFrame media:[[AppModel sharedAppModel] mediaForMediaId:loc.gameObject.iconMediaId] mode:ARISMediaDisplayModeAspectFit delegate:self];
        else
            iconView = [[ARISMediaView alloc] initWithFrame:imageInnerFrame image:[UIImage imageNamed:@"logo.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
        
        [iconBorderView addSubview:iconView];
        [self addSubview:iconBorderView];
        
        self.opaque = NO; 
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(showTitle)
    {
        CGFloat minx = bubbleRect.origin.x+1;
        CGFloat maxx = bubbleRect.origin.x+bubbleRect.size.width-1; 
        CGFloat miny = bubbleRect.origin.y+1; 
        CGFloat maxy = bubbleRect.origin.y+bubbleRect.size.height-1; 
        CGPoint pointerPoint = CGPointMake(minx+(IMAGE_HEIGHT/2), miny-POINTER_LENGTH);
        
        CGMutablePathRef calloutPath = CGPathCreateMutable(); 
        
        CGPathMoveToPoint(   calloutPath, NULL, pointerPoint.x, pointerPoint.y); //tip of point
        CGPathAddLineToPoint(calloutPath, NULL, minx+(IMAGE_HEIGHT/2)-POINTER_WIDTH/2, miny);  
        
        CGPathAddLineToPoint(calloutPath, NULL, minx, miny); //top-left
        CGPathAddLineToPoint(calloutPath, NULL, minx, maxy); //bottom-left
        CGPathAddLineToPoint(calloutPath, NULL, maxx, maxy); //bottom-right
        CGPathAddLineToPoint(calloutPath, NULL, maxx, miny); //top-right
        
        CGPathAddLineToPoint(calloutPath, NULL, minx+(IMAGE_HEIGHT/2)+POINTER_WIDTH/2, miny);   
        CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x, pointerPoint.y); //tip of point
        
        //loop around to add line between triangle and rect- comment out/delete next lines, and drawing should still be consistent, just without this line
        CGPathAddLineToPoint(calloutPath, NULL, minx+(IMAGE_HEIGHT/2)-POINTER_WIDTH/2, miny);   
        CGPathAddLineToPoint(calloutPath, NULL, minx+(IMAGE_HEIGHT/2)+POINTER_WIDTH/2, miny);    
        
        CGPathCloseSubpath(calloutPath);
        
        CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
        [[UIColor ARISColorLightBlue] set]; 
        CGContextFillPath(UIGraphicsGetCurrentContext());
        [[UIColor ARISColorWhite] set];
        [self.annotation.title drawInRect:titleRect withFont:[ARISTemplate ARISAnnotFont] lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter]; 
        CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0f);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
    }
    
    if(shouldWiggle)
    {
        xOnSinWave += WIGGLE_SPEED;
        float oldTotal = totalWiggleOffsetFromOriginalPosition;
        totalWiggleOffsetFromOriginalPosition = sin(xOnSinWave) * WIGGLE_DISTANCE;
        incrementalWiggleOffset = totalWiggleOffsetFromOriginalPosition-oldTotal;
        iconBorderView.frame = CGRectOffset(iconBorderView.frame, 0.0f, incrementalWiggleOffset);
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:WIGGLE_FRAMELENGTH];
    }
}	

- (void) enlarge
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.2];
    self.transform = CGAffineTransformMakeScale(2,2); 
    CGAffineTransform e = CGAffineTransformMakeScale(2,2);
    iconBorderView.transform = CGAffineTransformTranslate(e,IMAGE_WIDTH/4,-IMAGE_HEIGHT/4);    
    [UIView commitAnimations];  
}

- (void) shrinkToNormal
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.2];
    self.transform = CGAffineTransformMakeScale(1,1);  
    iconBorderView.transform = CGAffineTransformMakeScale(1,1);   
    [UIView commitAnimations];   
    
}

- (void) dealloc
{
    iconView.delegate = nil;
}

@end
