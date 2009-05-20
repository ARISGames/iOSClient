//
//  InventoryBar.m
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBar.h"


@implementation NearbyBar
@synthesize hidden;

- (void)setHidden:(BOOL)newHidden {
	CGRect myFrame;
	if (newHidden != [self hidden]) {
		myFrame = self.frame;
		if (newHidden == YES) {
			myFrame.origin.y -= 100.0; //We should calculate this!
		} else {
			myFrame.origin.y += 100.0;
		}
		[UIView beginAnimations: nil context: nil ]; // Tell UIView we're ready to start animations.
		[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
		[UIView setAnimationDuration: 0.25f ]; // Set the duration to 4/10ths of a second.
		self.frame = myFrame;
		[UIView commitAnimations];
		hidden = newHidden;
	}
}

- (id)initWithFrame:(CGRect)frame {
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];
	
	if (self = [super initWithFrame:frame]) {
		usedSpace = 20.0;
		maxScroll = 0.0;
		CGRect viewFrame = self.bounds;
		viewFrame = CGRectInset(viewFrame, 30.0, 0);
		buttonView = [[UIView alloc] initWithFrame:viewFrame];
		[buttonView setClipsToBounds:YES];
		[self addSubview:buttonView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		usedSpace = 20.0;
		maxScroll = 0.0;
		CGRect viewFrame = self.bounds;
		viewFrame = CGRectInset(viewFrame, 30.0, 0);
		buttonView = [[UIView alloc] initWithFrame:viewFrame];
		[buttonView setClipsToBounds:YES];
		[self addSubview:buttonView];
	}
	return self;
}

- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"App Delegate recieved Nearby Locations List Notification");
	NSArray *nearbyLocations = notification.object;
	//Check for a force View flag in one of the nearby locations and display if found
	[self clearAllItems];
	for (NSObject <NearbyObjectProtocol> *unknownNearbyLocation in nearbyLocations) {
		[self addItem:unknownNearbyLocation];
	}
}

- (void)drawRect:(CGRect)rect {
	[[UIColor grayColor] set];
	UIRectFill(rect);
}


- (void)dealloc {
    [super dealloc];
}

- (void)clearAllItems {
	NSArray *myItems = [buttonView subviews];
	NSEnumerator *viewEnumerator = [myItems objectEnumerator];
	NearbyBarItemView *myView;
	while (myView = [viewEnumerator nextObject]) {
		[myView removeFromSuperview];
	}
	[self setHidden:YES];
}

- (void)addItem:(NSObject <NearbyObjectProtocol> *)item {
	NearbyBarItemView *itemView = [[NearbyBarItemView alloc] init];
	[itemView setNearbyObject:item];
	[self addItemView:itemView];
	[self setHidden:NO];
}

- (void)addItemView:(NearbyBarItemView *)itemView {
	//get the last subview of the buttonView
	UIView *lastView = [[buttonView subviews] lastObject];
	float newX = lastView.frame.origin.x + lastView.frame.size.width + 5;
	CGRect newViewFrame = itemView.frame;
	newViewFrame.origin.x = newX;
	newViewFrame.origin.y = ((buttonView.bounds.size.height - newViewFrame.size.height) / 2.0) + buttonView.bounds.origin.y;
	itemView.frame = newViewFrame;
	[buttonView addSubview:itemView];
	[buttonView setNeedsDisplay];
	maxScroll = itemView.frame.origin.x + itemView.frame.size.width + 5 - buttonView.frame.size.width;
	if (maxScroll < 0.0) {
		maxScroll = 0.0;
	}
}

- (float)leftmostDivide {
	float divide;
	divide = buttonView.bounds.origin.x;
	NSArray *itemViews = [buttonView subviews];
	NSEnumerator *enumerator = [itemViews objectEnumerator];
	for (UIView *element in enumerator) {
		if (element.frame.origin.x > divide) {
			divide = element.frame.origin.x;
//			NSLog(@"Divide is %f", divide);
			break;
		}
	}
	return divide;
}

- (float)rightmostDivide {
	float divide;
	divide = buttonView.bounds.origin.x + buttonView.bounds.size.width;
	NSArray *itemViews = [buttonView subviews];
	NSEnumerator *enumerator = [itemViews reverseObjectEnumerator];
	for (UIView *element in enumerator) {
		if ((element.frame.origin.x + element.frame.size.width) < divide) {
			divide = element.frame.origin.x + element.frame.size.width;
			NSLog(@"Divide is %f", divide);
			break;
		}
	}
	return divide;
}

 	
- (void)scroll:(float)delta {
	//scroll by delta amount. -delta moves buttons to right,
	//+delta to left. Amount pinned to 0..maxScroll.
	CGRect myBounds = buttonView.bounds;
	myBounds.origin.x -= delta;
	if (myBounds.origin.x > maxScroll) {
		myBounds.origin.x = maxScroll;
	}
	if (myBounds.origin.x < 0.0) {
		myBounds.origin.x = 0.0;
	}
	[UIView beginAnimations: nil context: nil ]; // Tell UIView we're ready to start animations.
	[UIView setAnimationCurve: UIViewAnimationCurveEaseInOut ];
	[UIView setAnimationDuration: 0.4f ]; // Set the duration to 4/10ths of a second.
	buttonView.bounds = myBounds;
	[UIView commitAnimations];
}
	
- (IBAction)scrollLeft:(id)sender {
	float scrollTarget = [self leftmostDivide];
	NSLog(@"ScrollTarget is %f",scrollTarget);
	float delta = buttonView.bounds.origin.x - scrollTarget;
	NSLog(@"Delta is %f",delta);
	[self scroll:delta];
}

- (IBAction)scrollRight:(id)sender {
	float scrollTarget = [self rightmostDivide];
	NSLog(@"ScrollTarget is %f",scrollTarget);
	float delta = (buttonView.bounds.origin.x + buttonView.bounds.size.width) - scrollTarget;
	NSLog(@"Delta is %f",delta);
	[self scroll:delta];
//	[self scroll:75.0];
}

//- (void)addItem:(UIView *)itemView {
//	CGRect viewFrame = itemView.frame;
//	viewFrame.origin.x = usedSpace;
//	itemView.frame = viewFrame;
//	NSLog(@"Frame x:%f y:%f width:%f height:%f", viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
//
//	usedSpace = usedSpace + viewFrame.size.width + 5;
//	if (usedSpace > self.frame.size.width) {
//		CGRect myFrame = self.frame;
//		myFrame.size.width = usedSpace;
//		self.frame = myFrame;
//	}
//	[self addSubview:itemView];
//}
	
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject]; //should be just one
	lastTouch = [touch locationInView:self];
	dragged = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {  
	UITouch *touch = [touches anyObject]; //should be just one
	CGPoint touchPoint = [touch locationInView:self];
	float deltaX = touchPoint.x - lastTouch.x;
	lastTouch = touchPoint;
	CGRect myFrame = buttonView.bounds;
	myFrame.origin.x -= deltaX;
	if (myFrame.origin.x > maxScroll) {
		myFrame.origin.x = maxScroll;
	}
	if (myFrame.origin.x < 0.0) {
		myFrame.origin.x = 0.0;
	}
	buttonView.bounds = myFrame;
	dragged = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Touch ended");
	if (!dragged) {
		NSLog(@"I should open an item");
		UITouch *touch = [touches anyObject]; //should be just one
		CGPoint touchPoint = [touch locationInView:buttonView];
		NSArray *myItems = [buttonView subviews];
		NSEnumerator *viewEnumerator = [myItems objectEnumerator];
		NearbyBarItemView *myView;
		while (myView = [viewEnumerator nextObject]) {
			if (CGRectContainsPoint([myView frame], touchPoint)) {
				NSLog(@"Found me an object! %@", [myView title]);
				[[myView nearbyObject] display];
			} else {
				//NSLog(@"Nope! Not it.");
			}
		}
	}
}


@end
