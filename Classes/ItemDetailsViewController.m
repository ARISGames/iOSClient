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

NSString *const kItemDetailsDescriptionHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";



@implementation ItemDetailsViewController
@synthesize appModel, item, inInventory;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: @"Loading..."];	
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate]showWaitingIndicator:@"Loading..."];
		
	if (inInventory == YES) {		
		dropButton.width = 75.0;
		deleteButton.width = 75.0;
		detailButton.width = 140.0;
		
		[toolBar setItems:[NSMutableArray arrayWithObjects: dropButton, deleteButton, detailButton,  nil] animated:NO];

		if (!item.dropable) dropButton.enabled = NO;
		if (!item.destroyable) deleteButton.enabled = NO;
	}
	else {
		detailButton.width = 150.0;
		pickupButton.width = 150.0;
		
		[toolBar setItems:[NSMutableArray arrayWithObjects: pickupButton,detailButton, nil] animated:NO];
	}
	

	NSLog(@"ItemDetailsViewController: View Loaded. Current item: %@", item.name);


	//Set Up General Stuff
	NSString *htmlDescription = [NSString stringWithFormat:kItemDetailsDescriptionHtmlTemplate, item.description];
	[itemDescriptionView loadHTMLString:htmlDescription baseURL:nil];

	Media *media = [appModel mediaForMediaId: item.mediaId];

	if ([media.type isEqualToString: @"Image"] && media.url) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		[itemImageView loadImageFromMedia:media];
	}
	else if (([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"]) && media.url) {
		NSLog(@"ItemDetailsViewController:  AV Layout Selected");

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
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];
	[super viewDidLoad];
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

#pragma mark Zooming delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	NSLog(@"got a viewForZooming.");
	return itemImageView;
}

- (void) scrollViewDidEndZooming: (UIScrollView *) scrollView withView: (UIView *) view atScale: (float) scale
{
	NSLog(@"got a scrollViewDidEndZooming. Scale: %f", scale);
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, scale, scale);
	itemImageView.transform = transform;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch       *touch = [touches anyObject];
	NSLog(@"got a touchesEnded.");
	
    if([touch tapCount] == 2) {
		//NSLog(@"TouchCount is 2.");
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformScale(transform, 1.0, 1.0);
		itemImageView.transform = transform;
    }
}

#pragma mark Animate view show/hide

- (void)showView:(UIView *)aView {
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height - 175;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void)hideView:(UIView *)aView {
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void)toggleDescription:(id)sender {
	if (descriptionShowing) { //description is showing, so hide
		[self hideView:itemDescriptionView];
		//[notesButton setStyle:UIBarButtonItemStyleBordered]; //set button style
		descriptionShowing = NO;
	} else {  //description is not showing, so show
		[self showView:itemDescriptionView];
		//[notesButton setStyle:UIBarButtonItemStyleDone];
		descriptionShowing = YES;
	}
}


@end
