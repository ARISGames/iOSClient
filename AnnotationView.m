//
//  AnnotationView.m
//  ARIS
//
//  Created by Brian Deith on 8/11/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "AnnotationView.h"
#import "Annotation.h"
#import "Media.h"
#import "NearbyObjectProtocol.h"


@implementation AnnotationView

@synthesize titleRect;
@synthesize subtitleRect;
@synthesize contentRect;
@synthesize titleFont;
@synthesize subtitleFont;
@synthesize icon;


- (id)initWithAnnotation:(Annotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	UIFont *localTitleFont = [UIFont fontWithName:@"Arial" size:18];
	UIFont *localSubtitleFont = [UIFont fontWithName:@"Arial" size:12];
	CGRect localTitleRect;	//we use local copies until self is inited
	CGRect localSubtitleRect;
	CGRect localContentRect;
	if (annotation.title && annotation.title != @"") {  //if we have a title, we compute a size for it
		CGSize titleSize = [annotation.title sizeWithFont:localTitleFont];
		if (titleSize.width > 300) {
			titleSize.width = 300;
		}
		
		localTitleRect = CGRectMake(0, 0, titleSize.width, titleSize.height);
	} 
    else {
		localTitleRect = CGRectMake(0, 0, 0, 0);
	}
	if (annotation.subtitle) { //likewise for subtitle
		CGSize subtitleSize = [annotation.subtitle sizeWithFont:localSubtitleFont];
		if (subtitleSize.width > 300) {
			subtitleSize.width = 300;
		}
		localSubtitleRect = CGRectMake(0, localTitleRect.origin.x + localTitleRect.size.height, subtitleSize.width, subtitleSize.height);
	} 
    else {
		localSubtitleRect = CGRectMake(0, 0, 0, 0);
	}
	//now set both rects to be the same width, as when we draw the text, we'll center it within each rect.
	if (localTitleRect.size.width < localSubtitleRect.size.width) {
		localTitleRect.size.width = localSubtitleRect.size.width;
	} else {
		localSubtitleRect.size.width = localTitleRect.size.width;
	}
	localContentRect=CGRectUnion(localTitleRect, localSubtitleRect);
	localContentRect.size.width += 10.0;
	localContentRect.size.height += 10.0;
	localTitleRect=CGRectOffset(localTitleRect, 5.0, 5.0);
	localSubtitleRect=CGRectOffset(localSubtitleRect, 5.0, 5.0);
	
	if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        if((annotation.title != nil && annotation.title != @"") || annotation.kind == NearbyObjectPlayer) {
		//we have a view, so now we can set some instance variables
		[self setFrame:CGRectMake(0.0, 0.0, localContentRect.size.width, localContentRect.size.height + POINTER_LENGTH + IMAGE_HEIGHT)];
		self.centerOffset = CGPointMake(0.0, -(localContentRect.size.height+POINTER_LENGTH)/2.0);
		self.titleFont = localTitleFont;
		self.subtitleFont = localSubtitleFont;
		self.titleRect = localTitleRect;
		self.subtitleRect = localSubtitleRect;
		self.contentRect = localContentRect;
		iconView = [[AsyncMediaImageView alloc] init];
		CGRect imageViewFrame = CGRectMake(self.bounds.origin.x + 5.0, CGRectGetMaxY(self.contentRect)+POINTER_LENGTH, self.bounds.size.width - 10.0, IMAGE_HEIGHT);
		[iconView setFrame:imageViewFrame];
		iconView.contentMode =  UIViewContentModeScaleAspectFit;
		[self addSubview:iconView];
		
		//Only load the icon media if it is > 0, otherwise, lets load a default
		if (annotation.iconMediaId != 0) {
			Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: annotation.iconMediaId];
			[iconView loadImageFromMedia:iconMedia];
		}
		else if (annotation.kind == NearbyObjectItem) iconView.image = [UIImage imageNamed:@"item.png"];
		else if (annotation.kind == NearbyObjectNode) iconView.image = [UIImage imageNamed:@"page.png"];
		else if (annotation.kind == NearbyObjectNPC) iconView.image = [UIImage imageNamed:@"npc.png"];
		else if (annotation.kind == NearbyObjectPlayer) iconView.image = [UIImage imageNamed:@"player.png"];
        else if (annotation.kind == NearbyObjectWebPage) iconView.image = [UIImage imageNamed:@"page.png"];
        else if (annotation.kind == NearbyObjectNote) iconView.image = [UIImage imageNamed:@"noteicon.png"];

		self.opaque = NO;
	}
        else{
            iconView = [[AsyncMediaImageView alloc] init];
            CGRect imageViewFrame = CGRectMake(0, 0, IMAGE_WIDTH + 10, IMAGE_HEIGHT + 10);
            [iconView setFrame:imageViewFrame];
            [self setFrame: iconView.frame];
            self.contentRect = iconView.frame;
            iconView.contentMode =  UIViewContentModeScaleAspectFit;
            [self addSubview:iconView];
            
            //Only load the icon media if it is > 0, otherwise, lets load a default
            if (annotation.iconMediaId != 0) {
                Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: annotation.iconMediaId];
                [iconView loadImageFromMedia:iconMedia];
            }
            else if (annotation.kind == NearbyObjectItem) iconView.image = [UIImage imageNamed:@"item.png"];
            else if (annotation.kind == NearbyObjectNode) iconView.image = [UIImage imageNamed:@"page.png"];
            else if (annotation.kind == NearbyObjectNPC) iconView.image = [UIImage imageNamed:@"npc.png"];
            else if (annotation.kind == NearbyObjectPlayer) iconView.image = [UIImage imageNamed:@"player.png"];
            else if (annotation.kind == NearbyObjectWebPage) iconView.image = [UIImage imageNamed:@"page.png"];
            else if (annotation.kind == NearbyObjectNote) iconView.image = [UIImage imageNamed:@"noteicon.png"];
            
            self.opaque = NO; 
        }

    }
    return self;
}

- (void)dealloc {
	asyncData= nil;
	[iconView removeFromSuperview];
}


- (void)drawRect:(CGRect)rect {
	CGMutablePathRef calloutPath = CGPathCreateMutable();
	CGPoint pointerPoint = CGPointMake(self.contentRect.origin.x + 0.5 * self.contentRect.size.width,  self.contentRect.origin.y + self.contentRect.size.height + POINTER_LENGTH);
	CGFloat radius = 7.0;
	CGPathMoveToPoint(calloutPath, NULL, CGRectGetMinX(self.contentRect) + radius, CGRectGetMinY(self.contentRect));
    CGPathAddArc(calloutPath, NULL, CGRectGetMaxX(self.contentRect) - radius, CGRectGetMinY(self.contentRect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGPathAddArc(calloutPath, NULL, CGRectGetMaxX(self.contentRect) - radius, CGRectGetMaxY(self.contentRect) - radius, radius, 0, M_PI / 2, 0);
	
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x + 10.0, CGRectGetMaxY(self.contentRect));
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x, pointerPoint.y);
	CGPathAddLineToPoint(calloutPath, NULL, pointerPoint.x - 10.0,  CGRectGetMaxY(self.contentRect));
	
    CGPathAddArc(calloutPath, NULL, CGRectGetMinX(self.contentRect) + radius, CGRectGetMaxY(self.contentRect) - radius, radius, M_PI / 2, M_PI, 0);
    CGPathAddArc(calloutPath, NULL, CGRectGetMinX(self.contentRect) + radius, CGRectGetMinY(self.contentRect) + radius, radius, M_PI, 3 * M_PI / 2, 0);	
    CGPathCloseSubpath(calloutPath);
	
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	[[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.8] set];
	CGContextFillPath(UIGraphicsGetCurrentContext());
	[[UIColor whiteColor] set];
	[self.annotation.title drawInRect:self.titleRect withFont:self.titleFont lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
	[self.annotation.subtitle drawInRect:self.subtitleRect withFont:self.subtitleFont lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentCenter];
	CGContextAddPath(UIGraphicsGetCurrentContext(), calloutPath);
	CGContextStrokePath(UIGraphicsGetCurrentContext());
}	

@end
