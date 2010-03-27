//
//  ItemDetailsViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemDetailsViewController.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncImageView.h"

@implementation ItemDetailsViewController
@synthesize appModel, item, inInventory, dropButton;
@synthesize deleteButton, backButton, pickupButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: @"Loading..."];	
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate]showWaitingIndicator:@"Loading..."];

	if (inInventory == YES) {
		pickupButton.hidden = YES;
		dropButton.hidden = NO;
		deleteButton.hidden = NO;
		
		if (item.dropable) {
			dropButton.enabled = YES;
			dropButton.alpha = 1;
		}
		else {
			dropButton.enabled = NO;
			dropButton.alpha = .2;
		}
		
		if (item.destroyable) {
			deleteButton.enabled = YES;
			deleteButton.alpha = 1;
		}
		else {
			deleteButton.enabled = NO;
			deleteButton.alpha = .2;
		}
	}
	else {
		pickupButton.hidden = NO;
		dropButton.hidden = YES;
		deleteButton.hidden = YES;
	}
	

	NSLog(@"ItemDetailsViewController: View Loaded. Current item: %@", item.name);


	//Set Up General Stuff
	int margin = 10;
	UILabel *itemDescriptionView = [[UILabel alloc] initWithFrame:CGRectMake(margin, 220 + margin, 320 - (2 * margin),
																			 [self calculateTextHeight:item.description])];
	itemDescriptionView.text = item.description;
	itemDescriptionView.backgroundColor = [UIColor blackColor];
	itemDescriptionView.textColor = [UIColor whiteColor];
	itemDescriptionView.lineBreakMode = UILineBreakModeWordWrap;
	itemDescriptionView.numberOfLines = 0;
	
	[scrollView addSubview:itemDescriptionView];
	[scrollView setContentSize:CGSizeMake(320, itemDescriptionView.frame.origin.y
										  + itemDescriptionView.frame.size.height)];
	
	
	Media *media = [appModel mediaForMediaId: item.mediaId];

	if ([media.type isEqualToString: @"Image"] && media.url) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		
		AsyncImageView* mediaImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
		
		[mediaImageView loadImageFromMedia:media];

		//Add the image view
		[scrollView addSubview:mediaImageView];
		
	}
	else if (([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"]) && media.url) {
		NSLog(@"ItemDetailsViewController:  Video Layout Selected");

		//Create movie player object
		mMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
		
		// Register to receive a notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviePlayer];
		
		//Configure Movie Player
		mMoviePlayer.scalingMode = MPMovieScalingModeFill; // Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
		mMoviePlayer.movieControlMode = MPMovieControlModeDefault; //Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly, MPMovieControlModeHidden.
		mMoviePlayer.backgroundColor = [UIColor blackColor];
		
		//Add a button
		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] 
							initWithFrame:CGRectMake(0, 0, 320, 220)];
		[button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:[UIImage imageNamed:@"clickToPlay.png"] forState:UIControlStateNormal];
		[scrollView addSubview:button];		
	}
	
	else {
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", item.mediaId);
	}

	//Stop Waiting Indicator
	//[NSThread detachNewThreadSelector: @selector(removeWaitingIndicator) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: nil];
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];
	[super viewDidLoad];
}


- (int) calculateTextHeight:(NSString *)text {
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 200000);
	CGSize calcSize = [text sizeWithFont:[UIFont systemFontOfSize:18.0]
					   constrainedToSize:frame.size lineBreakMode:UILineBreakModeWordWrap];
	frame.size = calcSize;
	frame.size.height += 0;
	NSLog(@"Found height of %f", frame.size.height);
	return frame.size.height;
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification { }

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification { }

- (IBAction)dropButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Drop Button Pressed");
	
	[appModel updateServerDropItemHere:self.item.itemId];

	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Item Dropped" 
										message: @"Your Item was dropped here on the map for other players to see." 
										delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	//Refresh Map Locations (To add this item)
	[appModel fetchLocationList];
	
	//Refresh the Nearby Locations (This item should now be part of the list)
	[appModel updateServerLocationAndfetchNearbyLocationList];
	
	//Refresh the inventory (To remove this item)
	[appModel fetchInventory];
	
	//Dismiss Item Details View
	[self.navigationController popToRootViewControllerAnimated:YES];

}

- (IBAction)deleteButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Destroy Button Pressed");

	[appModel updateServerDestroyItem:self.item.itemId];
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Item Destroyed" 
													message: @"This object was removed from your inventory" 
												   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	[alert show];
	[alert release];
	 
	
	//Refresh the inventory
	[appModel fetchInventory];
	
	//Dismiss Item Details View
	[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: Dismiss Item Details View");
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)playMovie:(id)sender {
    [mMoviePlayer play];
}

- (IBAction)pickupButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: pickupButtonTouched");
	
	[appModel updateServerPickupItem:self.item.itemId fromLocation:self.item.locationId];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Picked up an Item" message: @"It is available in your inventory" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[alert release];
	
	//Refresh Map Locations (to update quantities on the map)
	[appModel fetchLocationList];
	
	//Refresh the Nearby Locations (in case this item is no longer here)
	[appModel updateServerLocationAndfetchNearbyLocationList];
	
	//Refresh the inventory (to show the new item)
	[appModel fetchInventory];
	
	[self.navigationController.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    NSLog(@"Item Details View: Deallocating");
	
	// free our movie player
    [mMoviePlayer release];
	[super dealloc];
}

@end
