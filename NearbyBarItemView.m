//
//  InventoryBarItem.m
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBarItemView.h"

#define STRING_INDENT 20

@implementation NearbyBarItemView

@synthesize nearbyObject;
@synthesize title;
@synthesize placardImage;


- (id)init {
	UIImage *image = [UIImage imageNamed:@"NearbyBarButtonBackground.png"];
	CGRect frame = CGRectMake(0, 7, image.size.width, image.size.height);

	// Set self's frame to encompass the image
	if (self = [self initWithFrame:frame]) {
		
		self.opaque = NO;
		placardImage = image;
		
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
	}
}

- (void)setTitle:(NSString *)newTitle {
	[title release];
	title = [newTitle copy];
	UIFont *font = [UIFont systemFontOfSize:12.0];
	// Precalculate size of text and size of font so that text fits inside placard
	textSize = [title sizeWithFont:font minFontSize:9.0 actualFontSize:&fontSize forWidth:(self.bounds.size.width-STRING_INDENT) lineBreakMode:UILineBreakModeMiddleTruncation];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[placardImage drawAtPoint:(CGPointMake(0.0, 0.0))];

	CGFloat x = self.bounds.size.width/2 - textSize.width/2;
	CGFloat y = self.bounds.size.height/2 - textSize.height/2;
	CGPoint point;

	// Get the font of the appropriate size
	UIFont *font = [UIFont systemFontOfSize:fontSize];

	[[UIColor blackColor] set];
	point = CGPointMake(x, y + 0.5);
	[title drawAtPoint:point forWidth:(self.bounds.size.width-STRING_INDENT) withFont:font fontSize:fontSize lineBreakMode:UILineBreakModeMiddleTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

	[[UIColor whiteColor] set];
	point = CGPointMake(x, y);
	[title drawAtPoint:point forWidth:(self.bounds.size.width-STRING_INDENT) withFont:font fontSize:fontSize lineBreakMode:UILineBreakModeMiddleTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines]; 
}


#pragma mark Touches

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSLog(@"Start touch in barItemView");
////	UITouch *touch = [touches anyObject]; //should be just one
//}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
//	NSLog(@"Touch moved in barItemView");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	NSLog(@"Touch ended");
//}

@end
