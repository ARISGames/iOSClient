//
//  AnnotationView.m
//  ARIS
//
//  Created by Brian Deith on 8/11/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "AnnotationView.h"
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
    bool turnTitleBackOn;
    Trigger *trigger;
    CGRect imageViewFrame;
    CGSize titleSize;
    CLLocationCoordinate2D coordinates;
    CGPoint prevOffset;
}
@end

@implementation AnnotationView

- (id) initWithAnnotation:(id<MKAnnotation>)location reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithAnnotation:location reuseIdentifier:reuseIdentifier])
    {
        trigger = (Trigger *)location;

        showTitle = (trigger.show_title && trigger.title && ![trigger.title isEqualToString:@""]) ? YES : NO;
        shouldWiggle = trigger.wiggle;
        totalWiggleOffsetFromOriginalPosition = 0;
        incrementalWiggleOffset = 0;
        xOnSinWave = 0;
        turnTitleBackOn = NO;

        iconBorderView = [[UIView alloc] init];
        iconView = [[ARISMediaView alloc] init];
        [iconView setDisplayMode:ARISMediaDisplayModeAspectFit];

        imageViewFrame = CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);
        titleSize = CGSizeMake(0.0f,0.0f);
        titleRect = CGRectMake(0,0,0,0);

        if(showTitle)
        {
            if(trigger.title) titleSize = [trigger.title sizeWithAttributes:@{NSFontAttributeName:[ARISTemplate ARISAnnotFont]}];
            long maxWidth = (titleSize.width < ANNOTATION_MAX_WIDTH) ? titleSize.width : ANNOTATION_MAX_WIDTH;
            if(trigger.title) titleRect = CGRectMake(0, 0, maxWidth+1, titleSize.height-2);

            titleRect = CGRectOffset(titleRect, ANNOTATION_PADDING, IMAGE_HEIGHT+POINTER_LENGTH+ANNOTATION_PADDING);

            bubbleRect = titleRect;
            bubbleRect.origin.x    -= ANNOTATION_PADDING;
            bubbleRect.origin.y    -= ANNOTATION_PADDING;
            bubbleRect.size.width  += ANNOTATION_PADDING*2;
            bubbleRect.size.height += ANNOTATION_PADDING*2;

            titleRect.origin.y -=3;
            iconBorderView.backgroundColor = [UIColor whiteColor];

            if(IMAGE_WIDTH < bubbleRect.size.width)
                self.centerOffset = CGPointMake((bubbleRect.size.width-IMAGE_WIDTH)/2, (bubbleRect.size.height+POINTER_LENGTH)/2);
            else
                self.centerOffset = CGPointMake(0, (bubbleRect.size.height+POINTER_LENGTH)/2);
        }

        [self formatFrame];
    }
    return self;
}

- (void) formatFrame
{
    if(showTitle) [self setFrame:CGRectUnion(bubbleRect, imageViewFrame)] ;
    else          [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, imageViewFrame.size.width, imageViewFrame.size.height)];

    iconBorderView.frame = imageViewFrame;
    if(showTitle)
    {
      iconBorderView.layer.borderColor = [UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1.0f].CGColor;
      iconBorderView.layer.borderWidth = 1.0f;
    }

    CGRect imageInnerFrame = imageViewFrame;
    imageInnerFrame.origin.x += 2.0f;
    imageInnerFrame.origin.y += 2.0f;
    imageInnerFrame.size.width -= 4.0f;
    imageInnerFrame.size.height -= 4.0f;

    [iconView setFrame:imageInnerFrame];
    [iconView setDelegate:self];

    if(trigger.icon_media_id)
    {
        [iconView setMedia:[_MODEL_MEDIA_ mediaForId:trigger.icon_media_id]];
    }
    // Should not be visible
    else
    {
        [iconView setImage:[UIImage imageNamed:@"star_blue.png"]];
    }

    [iconBorderView addSubview:iconView];
    [self addSubview:iconBorderView];

    self.opaque = NO;
    self.clipsToBounds = NO;
}

- (void)drawRect:(CGRect)rect
{
    shouldWiggle = trigger.wiggle;
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
        //[[UIColor ARISColorLightBlue] set];
        //UIColor *buttonBGColor = [UIColor colorWithRed:242/255.0 green:241/255.0 blue:237/255.0 alpha:1];
        //[buttonBGColor set];
        [[UIColor whiteColor] set];
        CGContextFillPath(UIGraphicsGetCurrentContext());
        //[[UIColor ARISColorWhite] set];
        [[UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1.0f] set];

        NSMutableParagraphStyle *paragraphStyle;
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
        paragraphStyle.alignment = NSTextAlignmentCenter;

        //draw rect give breathing room for 'g','y','q',etc...
        CGRect drawRect = CGRectMake(titleRect.origin.x,titleRect.origin.y,titleRect.size.width,titleRect.size.height+5);

        [self.annotation.title drawInRect:drawRect withAttributes:@{NSFontAttributeName:[ARISTemplate ARISAnnotFont],NSParagraphStyleAttributeName:paragraphStyle}];
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

- (void) turnOffTitle
{
    if (showTitle) {
        showTitle = NO;
        [self formatFrame];
        prevOffset = self.centerOffset;
        self.centerOffset = CGPointMake(0.0f, 0.0f);
        turnTitleBackOn = YES;
        [self setNeedsLayout];
    }
}

- (void) turnOnTitle
{
    if (turnTitleBackOn) {
        showTitle = YES;
        [self formatFrame];
        self.centerOffset = prevOffset;
    }
}

- (void) enlarge
{
    iconBorderView.frame = imageViewFrame;
    [self turnOffTitle];
    iconBorderView.layer.borderColor = [UIColor clearColor].CGColor;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:.2];
    self.transform = CGAffineTransformMakeScale(2,2);
    CGAffineTransform e = CGAffineTransformMakeScale(2,2);
    iconBorderView.transform = e;
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
    [self turnOnTitle];
    if (showTitle) {
        iconBorderView.layer.borderColor = [UIColor colorWithRed:93.0f/255.0f green:93.0f/255.0f blue:93.0f/255.0f alpha:1.0f].CGColor;
        iconBorderView.layer.borderWidth = 1.0f;
    }
}

- (void) dealloc
{
    iconView.delegate = nil;
}

@end
