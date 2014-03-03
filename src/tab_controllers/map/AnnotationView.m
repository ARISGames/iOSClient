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

@interface AnnotationView() <ARISMediaViewDelegate>
@end

@implementation AnnotationView

@synthesize titleRect;
@synthesize subtitleRect;
@synthesize textRect;
@synthesize titleFont;
@synthesize subtitleFont;
@synthesize icon;
@synthesize showTitle;
@synthesize iconView;
@synthesize shouldWiggle;
@synthesize totalWiggleOffsetFromOriginalPosition;
@synthesize incrementalWiggleOffset;
@synthesize xOnSinWave;

- (id) initWithAnnotation:(id<MKAnnotation>)location reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithAnnotation:location reuseIdentifier:reuseIdentifier])
    {
        Location *loc = (Location *)location;
        
        loc.title = nil;
        loc.subtitle = nil;
        if(![loc.name isEqualToString:@""])
            loc.title = loc.name;
        if(loc.gameObject.type == GameObjectItem && loc.qty > 1 && loc.title)
            loc.subtitle = [NSString stringWithFormat:@"x %d",loc.qty];
        
        self.titleFont    = [ARISTemplate ARISAnnotFont];
        self.subtitleFont = [ARISTemplate ARISSubtextFont];
        
        self.showTitle = (loc.showTitle && loc.title) ? YES : NO;
        self.shouldWiggle = loc.wiggle;
        self.totalWiggleOffsetFromOriginalPosition = 0;
        self.incrementalWiggleOffset = 0;
        self.xOnSinWave = 0;

        CGRect imageViewFrame = CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT); 
        titleRect    = CGRectMake(0,0,0,0);
        subtitleRect = CGRectMake(0,0,0,0);  
        
        if(self.showTitle)
        {
            CGSize titleSize    = CGSizeMake(0.0f,0.0f);
            CGSize subtitleSize = CGSizeMake(0.0f,0.0f); 
            if(loc.title)    titleSize    = [[loc.title uppercaseString] sizeWithFont:titleFont];
            if(loc.subtitle) subtitleSize = [loc.subtitle                sizeWithFont:subtitleFont];
            
            int maxWidth = titleSize.width > subtitleSize.width ? titleSize.width : subtitleSize.width;
            if(maxWidth > ANNOTATION_MAX_WIDTH) maxWidth = ANNOTATION_MAX_WIDTH;
            
            if(loc.title)    titleRect    = CGRectMake(0,                                        0, maxWidth,    titleSize.height);
            if(loc.subtitle) subtitleRect = CGRectMake(0, titleRect.origin.y+titleRect.size.height, maxWidth, subtitleSize.height);
            
            titleRect    = CGRectOffset(titleRect,    ANNOTATION_PADDING, IMAGE_HEIGHT+POINTER_LENGTH+ANNOTATION_PADDING);
            subtitleRect = CGRectOffset(subtitleRect, ANNOTATION_PADDING, IMAGE_HEIGHT+POINTER_LENGTH+ANNOTATION_PADDING);
            
            textRect=CGRectUnion(titleRect, subtitleRect);
            textRect.origin.x    -= ANNOTATION_PADDING;  
            textRect.origin.y    -= ANNOTATION_PADDING; 
            textRect.size.width  += ANNOTATION_PADDING*2;
            textRect.size.height += ANNOTATION_PADDING*2;
            
            if(IMAGE_WIDTH < textRect.size.width)
                self.centerOffset = CGPointMake((textRect.size.width-IMAGE_WIDTH)/2, (textRect.size.height+POINTER_LENGTH)/2); 
            else
                self.centerOffset = CGPointMake(0, (textRect.size.height+POINTER_LENGTH)/2);  
            
            [self setFrame:CGRectUnion(textRect, imageViewFrame)]; 
        }
        else
            [self setFrame:imageViewFrame];  
        
        if(loc.gameObject.iconMediaId != 0)
            self.iconView = [[ARISMediaView alloc] initWithFrame:imageViewFrame media:[[AppModel sharedAppModel] mediaForMediaId:loc.gameObject.iconMediaId] mode:ARISMediaDisplayModeAspectFit delegate:self];
        else
            self.iconView = [[ARISMediaView alloc] initWithFrame:imageViewFrame image:[UIImage imageNamed:@"logo.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
        
        [self addSubview:self.iconView];
        
        self.opaque = NO; 
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(self.showTitle)
    {
        CGFloat minx = self.textRect.origin.x+1;
        CGFloat maxx = self.textRect.origin.x+self.textRect.size.width-1; 
        CGFloat miny = self.textRect.origin.y+1; 
        CGFloat maxy = self.textRect.origin.y+self.textRect.size.height-1; 
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
        [[UIColor ARISColorRed] set]; 
        CGContextFillPath(UIGraphicsGetCurrentContext());
        [[UIColor ARISColorWhite] set];
        [[self.annotation.title uppercaseString] drawInRect:self.titleRect withFont:self.titleFont lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
        [self.annotation.subtitle drawInRect:self.subtitleRect withFont:self.subtitleFont lineBreakMode:NSLineBreakByTruncatingMiddle alignment:NSTextAlignmentCenter];
        CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2.0f);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
    }
    
    if(self.shouldWiggle)
    {
        self.xOnSinWave += WIGGLE_SPEED;
        float oldTotal = totalWiggleOffsetFromOriginalPosition;
        self.totalWiggleOffsetFromOriginalPosition = sin(xOnSinWave) * WIGGLE_DISTANCE;
        self.incrementalWiggleOffset = totalWiggleOffsetFromOriginalPosition-oldTotal;
        self.iconView.frame = CGRectOffset(self.iconView.frame, 0.0f, self.incrementalWiggleOffset);
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:WIGGLE_FRAMELENGTH];
    }
}	

- (void) dealloc
{
    self.iconView.delegate = nil;
}

@end
