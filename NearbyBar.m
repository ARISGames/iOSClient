//
//  InventoryBar.m
//  fun with button bars
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBar.h"
#import "AudioToolbox/AudioToolbox.h"


@implementation NearbyBar
@synthesize hidden;
@synthesize hiddenHeight;
@synthesize exposedHeight;
@synthesize fillColor;


- (void)setHidden:(BOOL)newHidden {
	CGRect myFrame;
	if (newHidden != [self hidden]) {
		[UIView beginAnimations: nil context: nil ]; // Tell UIView we're ready to start animations.
		myFrame = self.frame;
		if (newHidden == YES) {
			myFrame.size.height = hiddenHeight;
			buttonView.alpha = 0.0;
			//[self setFillColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3]];
			self.alpha = 0.5;
		} else {
			myFrame.size.height = exposedHeight;
			buttonView.alpha = 1.0;
			//[self setFillColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]];
			self.alpha = 1.0;
		}
		self.frame = myFrame;
		[UIView commitAnimations];
		hidden = newHidden;
	}
}

- (BOOL)isOpaque {
	return NO;
}

- (void)setFillColor:(UIColor *)newColor {
	[fillColor release];
	fillColor = [newColor retain];
	[self setNeedsDisplay];
}

- (void)finishInit {
	usedSpace = 20.0;
	maxScroll = 0.0;
	hiddenHeight = self.frame.size.height;
	hidden = YES;
	[self setAlpha:0.5];
	exposedHeight = 44.0;
	CGRect viewFrame = self.bounds;
	viewFrame.size.height = exposedHeight;
	viewFrame = CGRectInset(viewFrame, 30.0, 0);
	buttonView = [[UIView alloc] initWithFrame:viewFrame];
	[buttonView setClipsToBounds:YES];
	[buttonView setAlpha:0.0];
	[self addSubview:buttonView];
	viewFrame = self.bounds;
	viewFrame.origin.x +=3.0;
	viewFrame.origin.y +=3.0;
	viewFrame.size.width = 10.0;
	viewFrame.size.height = 10.0;
	IndicatorView *indicatorView = [[IndicatorView alloc] initWithFrame:viewFrame];
	[self addSubview:indicatorView];
	self.fillColor = [UIColor grayColor];
	NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
	[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];
	[indicatorView addObserver:self forKeyPath:@"expanded" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isMemberOfClass:[IndicatorView class]]) {  //should be, unless we start observing something else
		BOOL exposedState = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		[self setHidden:!exposedState];
	} else {
		NSLog(@"I seem to be observing something I'm not looking at. Weird.");
	}
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self finishInit];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self finishInit];
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[self.fillColor set];
	UIRectFill(rect);
}


- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"NearbyBar: Recieved a Nearby Locations List Notification");
	NSArray *nearbyLocations = notification.object;
	
	if ([nearbyLocations count] > 0) {
		//Check for a force View flag in one of the nearby locations and display if found
		
		BOOL newItem = NO;	//flag to see if at least one new item is in list
		for (NSObject <NearbyObjectProtocol> *unknownNearbyLocation in nearbyLocations) {
			//check each new object againt list
			BOOL match = NO;
			for (NearbyBarItemView *anItemView in [buttonView subviews]) {
				NSObject <NearbyObjectProtocol> *existingItem = anItemView.nearbyObject;
				if (([[existingItem name] isEqualToString:[unknownNearbyLocation name]])
					&& ([existingItem kind] == [unknownNearbyLocation kind])) {
					match = YES;
				}
			}
			//did we find a match for this item? If not, we have a new item
			if (!match) {
				newItem = YES;
			}
		}
		
		//If we have a new item, vibrate
		if (newItem) {
			AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
		}
		[self clearAllItems];
		for (NSObject <NearbyObjectProtocol> *unknownNearbyLocation in nearbyLocations) {
			[self addItem:unknownNearbyLocation];
		}
	}
	else {
		[self setHidden:YES];
	}
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
	float newX;
	if (lastView) newX = lastView.frame.origin.x + lastView.frame.size.width + 5;
	else newX = 0;
	
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
			NSLog(@"NearbyBar: Divide is %f", divide);
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
	NSLog(@"NearbyBar: ScrollTarget is %f",scrollTarget);
	float delta = buttonView.bounds.origin.x - scrollTarget;
	NSLog(@"NearbyBar: Delta is %f",delta);
	[self scroll:delta];
}

- (IBAction)scrollRight:(id)sender {
	float scrollTarget = [self rightmostDivide];
	NSLog(@"NearbyBar: ScrollTarget is %f",scrollTarget);
	float delta = (buttonView.bounds.origin.x + buttonView.bounds.size.width) - scrollTarget;
	NSLog(@"NearbyBar: Delta is %f",delta);
	[self scroll:delta];
}
	
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.hidden) {
		UITouch *touch = [touches anyObject]; //should be just one
		lastTouch = [touch locationInView:self];
		dragged = NO;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { 
	if (!self.hidden) {
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
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.hidden) {
		if (!dragged) {
			NSLog(@"NearbyBar: I should open an item, it was not a drag");
			UITouch *touch = [touches anyObject]; //should be just one
			CGPoint touchPoint = [touch locationInView:buttonView];
			NSArray *myItems = [buttonView subviews];
			NSEnumerator *viewEnumerator = [myItems objectEnumerator];
			NearbyBarItemView *myView;
			while (myView = [viewEnumerator nextObject]) {
				if (CGRectContainsPoint([myView frame], touchPoint)) {
					NSLog(@"NearbyBar: Found the object selected, displaying: %@", [myView title]);
					[[myView nearbyObject] display];
				}
			}
		}
	}
}


@end
