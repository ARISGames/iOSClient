//
//  NearbyBar.m
//  Displayes a view to show nearby objects
//
//  Created by Brian Deith on 5/6/09.
//  Copyright 2009 Brian Deith. All rights reserved.
//

#import "NearbyBar.h"
#import "ARISAppDelegate.h"

@implementation NearbyBar

@synthesize fillColor;
@synthesize oldNearbyLocationList;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		maxScroll = 0.0;
		itemTouch = NO;
		
		CGRect buttonViewFrame = self.bounds;
		buttonViewFrame.size.height = kNearbyBarExposedHeight;
		buttonViewFrame = CGRectInset(buttonViewFrame, 5.0, 0.0); //how far to inset the items
		buttonView = [[UIView alloc] initWithFrame:buttonViewFrame];
		[buttonView setClipsToBounds:YES];

		[self addSubview:buttonView];
		
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"playerMoved" object:nil];		
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewLocationListReady" object:nil];			

		self.oldNearbyLocationList = [NSMutableArray arrayWithCapacity:5];

	
	}
    return self;
}


- (void)drawRect:(CGRect)rect {
	self.fillColor = [UIColor colorWithRed:27/255.0 green:76/255.0 blue:26/255.0 alpha:1.0];
	[self.fillColor set];
	UIRectFill(rect);
}
 


- (void)refreshViewFromModel{
	NSLog(@"NearbyBar: refreshViewFromModel");
	
	AppModel *appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSMutableArray *nearbyLocationList = [NSMutableArray arrayWithCapacity:5];
	NSObject <NearbyObjectProtocol> *forcedDisplayItem = nil;

	
	//Filter out the locations that meet some basic requirements
	for(Location *location in appModel.locationList) {
		if ([appModel.playerLocation distanceFromLocation:location.location] > location.error) continue;
		else if (location.kind == NearbyObjectItem && location.qty < 1 ) continue;
		else if (location.kind == NearbyObjectPlayer) continue;
		else [nearbyLocationList addObject:location];
	 }
		
	//Check if anything is new since last time
	BOOL newItem = NO;	//flag to see if at least one new item is in list
	for (Location *location in nearbyLocationList) {		
		BOOL match = NO;
		for (Location *oldLocation in oldNearbyLocationList) {
			if (oldLocation.locationId == location.locationId) match = YES;	
		}
		if (match == NO) {
			if (location.forcedDisplay) forcedDisplayItem = location; 
			newItem = YES;
		}
	}

	//If we have something new, alert the user
	if (newItem) {
		[appDelegate playAudioAlert:@"nearbyObject" shouldVibrate:YES];
	}

	//If we have a force display, do it
	if (forcedDisplayItem) {
		[forcedDisplayItem display];
	}
	
	//Update the view
	[self clearAllItems];
	
	if ([nearbyLocationList count] == 0) { 
		[appDelegate showNearbyBar:NO];
	}
	else {
		for (Location *location in nearbyLocationList) [self addItem:location];
		[appDelegate showNearbyBar:YES];
	}

	
	//Save this nearby list
	self.oldNearbyLocationList = nearbyLocationList;
}

#pragma mark Managing Nearby Items



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
		CGRect labelFrame = CGRectMake(0, 0, 70, kNearbyBarExposedHeight);
		UILabel *nearbyLabel = [[UILabel alloc]initWithFrame:labelFrame];
		nearbyLabel.text = NSLocalizedString(@"NearbyObjectsKey",@"");
		nearbyLabel.backgroundColor = [UIColor clearColor];
		nearbyLabel.textColor = [UIColor whiteColor];
		nearbyLabel.font = [UIFont systemFontOfSize:12.0];
		nearbyLabel.numberOfLines = 2;
		nearbyLabel.lineBreakMode = UILineBreakModeWordWrap;
		[buttonView addSubview:nearbyLabel];
		newX = nearbyLabel.frame.size.width + 10;
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
	itemTouch = YES;
	dragged = NO;
	UITouch *touch = [touches anyObject]; //should be just one
	lastTouch = [touch locationInView:self];
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
	if (myFrame.origin.x < 0) {
		myFrame.origin.x = 0;
	}	
	buttonView.bounds = myFrame;
	dragged = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ((!dragged) && itemTouch) {
		//NSLog(@"NearbyBar: I should open an item, it was not a drag");
		UITouch *touch = [touches anyObject]; //should be just one
		CGPoint touchPoint = [touch locationInView:buttonView];
		NSArray *myItems = [buttonView subviews];
		NSEnumerator *viewEnumerator = [myItems objectEnumerator];
		NearbyBarItemView *myView;
		while (myView = [viewEnumerator nextObject]) {
			if (CGRectContainsPoint([myView frame], touchPoint) && [myView respondsToSelector:@selector(title)]) {
				
				NSLog(@"NearbyBar: Found the object selected, displaying: %@", [myView title]);
				
				ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
				[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
				
				if ([myView respondsToSelector:@selector(nearbyObject)]) [[myView nearbyObject] display];
			}
		}
	}
}


#pragma mark Mamory Management
- (void)dealloc {
    [super dealloc];
}

@end
