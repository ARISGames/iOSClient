//
//  ItemDetailsViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
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

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieLoadStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:nil];
    }
	
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: (ARISAppDelegate *)[[UIApplication sharedApplication] delegate] withObject: @"Loading..."];	
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate]showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
	
	
	//Setup the Toolbar Buttons
	dropButton.title = NSLocalizedString(@"ItemDropKey", @"");
	pickupButton.title = NSLocalizedString(@"ItemPickupKey", @"");
	deleteButton.title = NSLocalizedString(@"ItemDeleteKey",@"");
	detailButton.title = NSLocalizedString(@"ItemDetailKey", @"");
	
	if (inInventory == YES) {		
		dropButton.width = 75.0;
		deleteButton.width = 75.0;
		detailButton.width = 140.0;
		
		[toolBar setItems:[NSMutableArray arrayWithObjects: dropButton, deleteButton, detailButton,  nil] animated:NO];

		if (!item.dropable) dropButton.enabled = NO;
		if (!item.destroyable) deleteButton.enabled = NO;
	}
	else {
		pickupButton.width = 150.0;
		detailButton.width = 150.0;

		[toolBar setItems:[NSMutableArray arrayWithObjects: pickupButton,detailButton, nil] animated:NO];
	}
	
	//Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
	
	

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

		//Setup the Button
		mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 295)];
		[mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
		[mediaPlaybackButton setBackgroundImage:[UIImage imageNamed:@"clickToPlay.png"] forState:UIControlStateNormal];
		[mediaPlaybackButton setTitle:NSLocalizedString(@"PreparingToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = NO;
		mediaPlaybackButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
		[mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
		[scrollView addSubview:mediaPlaybackButton];	
				
		//Create movie player object
		mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
		[mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
		
		[mMoviePlayer.moviePlayer prepareToPlay];		
	}
	
	else {
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", item.mediaId);
	}

	//Stop Waiting Indicator
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
	
	[super viewDidLoad];
}


- (IBAction)dropButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Drop Button Pressed");
	
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"drop" shouldVibrate:YES];
	appDelegate.nearbyBar.hidden = NO;
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];
	
	[appModel updateServerDropItemHere:self.item.itemId];

	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ItemDroppedTitleKey",@"")
										message: NSLocalizedString(@"ItemDroppedMessageKey",@"") 
										delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey",@"") otherButtonTitles: nil];
	[alert show];
	[alert release];
	
	[appModel silenceNextServerUpdate];
	
	//Refresh Map Locations (To add this item)
	[appModel fetchLocationList];
	
	//Refresh the inventory (To remove this item)
	[appModel fetchInventory];
	
	//Dismiss Item Details View
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];

}

- (IBAction)deleteButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Destroy Button Pressed");

	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"drop" shouldVibrate:YES];
	appDelegate.nearbyBar.hidden = NO;
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];

	[appModel updateServerDestroyItem:self.item.itemId];
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ItemDestroyedTitleKey", @"")
													message: NSLocalizedString(@"ItemDestroyedMessageKey", @"")
												   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	[alert show];
	[alert release];
	 
	
	//Refresh the inventory
	[appModel silenceNextServerUpdate];
	[appModel fetchInventory];
		
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];

}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: Notify server of Item view and Dismiss Item Details View");
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];
	
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.nearbyBar.hidden = NO;
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
	
}

-(IBAction)playMovie:(id)sender {
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}


- (IBAction)pickupButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: pickupButtonTouched");
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];

	
	if ([appModel.inventory containsObject:self.item]) {
		[appDelegate playAudioAlert:@"error" shouldVibrate:YES];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ItemDuplicateTitleKey",@"")
														message: NSLocalizedString(@"ItemDuplicateMessageKey",@"")
													   delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey",@"") otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	[appModel updateServerPickupItem:self.item.itemId fromLocation:self.item.locationId];
	
	[appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ItemPickedUpTitleKey", @"")
													message: NSLocalizedString(@"ItemPickedUpMessageKey", @"") 
												   delegate: self 
										  cancelButtonTitle: @"OkKey" otherButtonTitles: nil];
	
	[alert show];
	[alert release];
	
	[appModel silenceNextServerUpdate];
	//Refresh Map Locations (to update quantities on the map)
	[appModel fetchLocationList];
	
	//Refresh the inventory (to show the new item)
	[appModel fetchInventory];
	
	//Notify the server this item was displayed
	[appModel updateServerItemViewed:item.itemId];
	
	appDelegate.nearbyBar.hidden = NO;
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    NSLog(@"Item Details View: Deallocating");
	
	// free our movie player
    [mMoviePlayer release];
	
	[mediaPlaybackButton release];
	
	//remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:mMoviePlayer];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerLoadStateDidChangeNotification
												  object:mMoviePlayer];	
	[super dealloc];
}


#pragma mark MPMoviePlayerController Notification Handlers


- (void)movieLoadStateChanged:(NSNotification*) aNotification{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
	
	if( state & MPMovieLoadStateUnknown ) {
		NSLog(@"ItemDetailsViewController: Unknown Load State");
	}
	if( state & MPMovieLoadStatePlayable ) {
		NSLog(@"ItemDetailsViewController: Playable Load State");
	} 
	if( state & MPMovieLoadStatePlaythroughOK ) {
		NSLog(@"ItemDetailsViewController: Playthrough OK Load State");
		[mediaPlaybackButton setTitle:NSLocalizedString(@"TouchToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = YES;	
	} 
	if( state & MPMovieLoadStateStalled ) {
		NSLog(@"ItemDetailsViewController: Stalled Load State");
	} 
	
}


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
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
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
	
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
