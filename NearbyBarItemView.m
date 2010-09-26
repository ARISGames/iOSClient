//
//  NearbyBarItem.m
//  A single button, representing a nearby object, on a NearbyBar
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBarItemView.h"

#define RIGHT_STRING_MARGIN 5
#define ICON_WIDTH 30
#define kNearbyBarItemWidth 150
#define kNearbyBarItemHeight 30


@implementation NearbyBarItemView

@synthesize nearbyObject;
@synthesize title;
@synthesize iconImage;


- (id)init {
	CGRect frame = CGRectMake(0, 7, kNearbyBarItemWidth, kNearbyBarItemHeight);

	if (self = [self initWithFrame:frame]) {
		
		self.opaque = NO;
		
	}
	return self;
}

- (void)dealloc {
	[self setNearbyObject:nil];
	[super dealloc];
}

- (void)setNearbyObject:(NSObject <NearbyObjectProtocol> *)newObject {
	if (newObject != nearbyObject) {
		[nearbyObject release];
		nearbyObject = newObject;
		[nearbyObject retain];
		[self setTitle:[nearbyObject name]];
		switch ([nearbyObject kind]) {
			case NearbyObjectNPC:
				//NSLog(@"There's an NPC nearby.");
				self.iconImage = [UIImage imageNamed:@"person.png"];
				break;
			case NearbyObjectItem:
				//NSLog(@"There's an item nearby.");
				self.iconImage = [UIImage imageNamed:@"item.png"];
				break;
			case NearbyObjectNode:
				//NSLog(@"There's a node nearby.");
				self.iconImage = [UIImage imageNamed:@"page.png"];
				break;
			case NearbyObjectPlayer:
				//NSLog(@"There's a node nearby.");
				self.iconImage = [UIImage imageNamed:@"player.png"];
				break;
		}
		[self setNeedsDisplay];
	}
}

- (void)setTitle:(NSString *)newTitle {
	[title release];
	title = [newTitle copy];
	UIFont *font = [UIFont boldSystemFontOfSize:12.0];
	// Precalculate size of text and size of font so that text fits inside placard
	textSize = [title sizeWithFont:font minFontSize:12.0 actualFontSize:&fontSize forWidth:(self.bounds.size.width-RIGHT_STRING_MARGIN - ICON_WIDTH) lineBreakMode:UILineBreakModeTailTruncation];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	float radius = 8.0;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
	CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
				 radius, M_PI, M_PI / 2, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, 
						 rect.origin.y + rect.size.height);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, 
				 rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
				 radius, 0.0f, -M_PI / 2, 1);
	CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
	CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
	
	
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextClip(context);
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorspace;
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.5};
	
	CGFloat components[12] = { 
		40/255.0, 135/255.0, 31/255.0, 1.0,

		34/255.0, 92/255.0, 31/255.0, 1.0

	}; 
	 
	
	myColorspace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
												  locations, num_locations);
	CGPoint myStartPoint, myEndPoint;
	myStartPoint = self.bounds.origin;
	myEndPoint.x = self.bounds.origin.x;
	myEndPoint.y = self.bounds.origin.y + self.bounds.size.height;
	CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
	
	CGContextRestoreGState(context);
	CGContextAddPath(context, path);
	[[UIColor whiteColor] set];
	CGContextStrokePath(context);
	
	CGFloat x = (self.bounds.origin.x + ICON_WIDTH);
	CGFloat y = self.bounds.size.height/2 - textSize.height/2;
	CGPoint point;
	
	// Get the font of the appropriate size
	UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
	
	[[UIColor whiteColor] set];
	point = CGPointMake(x, y);
	[title drawAtPoint:point forWidth:(self.bounds.size.width - ICON_WIDTH - RIGHT_STRING_MARGIN) withFont:font fontSize:fontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignCenters]; 
	
	CGFloat iconImageX = self.bounds.origin.x + 5.0;
	CGFloat iconImageY = ((self.bounds.size.height - iconImage.size.height) / 2.0) + self.bounds.origin.y;
	[self.iconImage drawAtPoint:(CGPointMake(iconImageX, iconImageY))];
	
	CGPathRelease(path);
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
}

@end
