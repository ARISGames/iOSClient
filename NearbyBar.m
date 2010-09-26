//
//  NearbyBar.m
//  Displayes a view to show nearby objects
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBar.h"
#import "ARISAppDelegate.h"

#define kNearbyBarExposedHeight 40


@implementation NearbyBar

@synthesize fillColor;
@synthesize inactive;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		maxScroll = 0.0;
		itemTouch = NO;
		
		CGRect buttonViewFrame = self.bounds;
		buttonViewFrame.size.height = kNearbyBarExposedHeight;
		buttonViewFrame = CGRectInset(buttonViewFrame, 5.0, 0.0); //how far to inset the items
		buttonView = [[UIView alloc] initWithFrame:buttonViewFrame];
		[buttonView setClipsToBounds:YES];
		[buttonView setAlpha:1.0];
		[self addSubview:buttonView];
		
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(processNearbyLocationsList:) name:@"ReceivedNearbyLocationList" object:nil];		
	
		self.inactive = YES;

	
	}
    return self;
}




- (void)drawRect:(CGRect)rect {
	[self.fillColor set];
	UIRectFill(rect);
}

//We need to manually hide and unhide to make sure things line up just right
- (void)setHidden:(BOOL)newHidden {	
	if (newHidden) {
		[UIView beginAnimations: nil context: nil ]; // Tell UIView we're ready to start animations.
		CGRect myFrame = self.frame;
		myFrame.size.height = 0;
		self.frame = myFrame;
		self.alpha = 0.0;
		ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
		CGFloat newAppYOrigin = self.frame.origin.y + self.frame.size.height;
		[appDelegate setApplicationYOrigin:newAppYOrigin];
	
		[UIView commitAnimations];	
	}
	else {
		self.alpha = 1.0;
		[self setInactive:inactive];
	}	
}

 
- (void)setInactive:(BOOL)newInactive {
	
	[UIView beginAnimations: nil context: nil ];
	CGRect newFrame = self.frame;
	if (newInactive == YES) {
		//make bar inactive by hiding it completely
		inactive = YES;
		self.alpha=0.0;
		newFrame.size.height = 0;
	} else {
		inactive = NO;
		//bar is being exposed, so set alpha apropriate to shrunken state
		self.fillColor = [UIColor colorWithRed:27/255.0 green:76/255.0 blue:26/255.0 alpha:1.0];
		self.alpha = 1.0; 
		newFrame.size.height = kNearbyBarExposedHeight;
	}
	[self setFrame:newFrame];
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate setApplicationYOrigin:self.frame.origin.y + self.frame.size.height];
	
	[UIView commitAnimations];
}
			


- (void)setFillColor:(UIColor *)newColor {
	[fillColor release];
	fillColor = [newColor retain];
	[self setNeedsDisplay];
}
 


#pragma mark Managing Nearby Items

- (void)processNearbyLocationsList:(NSNotification *)notification {
    NSLog(@"NearbyBar: Recieved a Nearby Locations List Notification");
	NSArray *nearbyLocations = notification.object;
	NSObject <NearbyObjectProtocol> *forcedDisplayItem = nil;
	
	if ([nearbyLocations count] == 0) { 
		[self clearAllItems];
		self.inactive = YES;
		return;
	}
	
	BOOL newItem = NO;	//flag to see if at least one new item is in list
	
	for (NSObject <NearbyObjectProtocol> *unknownNearbyLocation in nearbyLocations) {
		//check each new object againt list
		BOOL match = NO;
		if ([unknownNearbyLocation kind] == NearbyObjectPlayer) continue;
		
		//This is not a player, so display the bar
		self.inactive = NO;
		
		for (NearbyBarItemView *anItemView in [buttonView subviews]) {
			NSObject <NearbyObjectProtocol> *existingItem = nil;
			if ([anItemView respondsToSelector:@selector(nearbyObject)]) existingItem = anItemView.nearbyObject;
			if (([[existingItem name] isEqualToString:[unknownNearbyLocation name]])
				&& ([existingItem kind] == [unknownNearbyLocation kind])) {
				match = YES;
			}
		}
		//did we find a match for this item? If not, we have a new item
		if (!match && [unknownNearbyLocation kind] != NearbyObjectPlayer) {
			newItem = YES;
			//also check to see if we should force a display.
			if ([unknownNearbyLocation forcedDisplay]) {
				forcedDisplayItem = unknownNearbyLocation;
			}
		}
	}
	
	//If we have a new item, vibrate and expand
	if (newItem) {
		ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate playAudioAlert:@"nearbyObject" shouldVibrate:YES];
	}
	[self clearAllItems];
	for (NSObject <NearbyObjectProtocol> *unknownNearbyLocation in nearbyLocations) {
		if ([unknownNearbyLocation kind] != NearbyObjectPlayer) [self addItem:unknownNearbyLocation];
	}

	if (forcedDisplayItem) {
		[forcedDisplayItem display];
	}
	
}



- (void)clearAllItems {
	NSArray *myItems = [buttonView subviews];
	NSEnumerator *viewEnumerator = [myItems objectEnumerator];
	NearbyBarItemView *myView;
	while (myView = [viewEnumerator nextObject]) {
		[myView removeFromSuperview];
	}
}

- (void)addItem:(NSObject <NearbyObjectProtocol> *)item {
	NearbyBarItemView *itemView = [[NearbyBarItemView alloc] init];
	[itemView setNearbyObject:item];
	[self addItemView:itemView];
}

- (void)addItemView:(NearbyBarItemView *)itemView {
	//get the last subview of the buttonView
	UIView *lastView = [[buttonView subviews] lastObject];
	float newX;
	if (lastView) {
		//At least one button is already here
		newX = lastView.frame.origin.x + lastView.frame.size.width + 5;
	} 
	else {
		CGRect labelFrame = CGRectMake(0, 0, 70, self.frame.size.height);
		UILabel *nearbyLabel = [[UILabel alloc]initWithFrame:labelFrame];
		nearbyLabel.text = @"Nearby Obejcts:";
		nearbyLabel.backgroundColor = [UIColor clearColor];
		nearbyLabel.textColor = [UIColor whiteColor];
		nearbyLabel.font = [UIFont systemFontOfSize:12.0];
		nearbyLabel.numberOfLines = 2;
		[buttonView addSubview:nearbyLabel];
		newX = 80;
	}
	
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



#pragma mark Managing Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.inactive) { //ignore touches while inactive
		itemTouch = YES;
		dragged = NO;
		UITouch *touch = [touches anyObject]; //should be just one
		lastTouch = [touch locationInView:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { 
	if (!self.inactive) { //ignore touches while inactive
		UITouch *touch = [touches anyObject]; //should be just one
		CGPoint touchPoint = [touch locationInView:self];
		float deltaX = touchPoint.x - lastTouch.x;
		lastTouch = touchPoint;
		CGRect myFrame = buttonView.bounds;
		myFrame.origin.x -= deltaX;
		if (myFrame.origin.x > maxScroll) {
			myFrame.origin.x = maxScroll;
		}
		if (myFrame.origin.x < 0) {
			myFrame.origin.x = 0;
		}	
		buttonView.bounds = myFrame;
		dragged = YES;
		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.inactive) { //ignore touches while inactive
		if ((!dragged) && itemTouch) {
			//NSLog(@"NearbyBar: I should open an item, it was not a drag");
			UITouch *touch = [touches anyObject]; //should be just one
			CGPoint touchPoint = [touch locationInView:buttonView];
			NSArray *myItems = [buttonView subviews];
			NSEnumerator *viewEnumerator = [myItems objectEnumerator];
			NearbyBarItemView *myView;
			while (myView = [viewEnumerator nextObject]) {
				if (CGRectContainsPoint([myView frame], touchPoint)) {
					
					NSLog(@"NearbyBar: Found the object selected, displaying: %@", [myView title]);
					
					ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
					[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
					
					if ([myView respondsToSelector:@selector(nearbyObject)]) [[myView nearbyObject] display];
				}
			}
		}
		
	}
}


#pragma mark Mamory Management
- (void)dealloc {
    [super dealloc];
}

@end
