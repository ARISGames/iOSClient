//
//  ItemDetailsViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemDetailsViewController.h"

@implementation ItemDetailsViewController

@synthesize appModel;
@synthesize item;
@synthesize inInventory;
@synthesize descriptionView;
@synthesize dropButton;
@synthesize deleteButton;
@synthesize backButton;
@synthesize pickupButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if (inInventory == YES) {
		pickupButton.hidden = YES;
		dropButton.hidden = NO;
		deleteButton.hidden = NO;
	}
	else {
		pickupButton.hidden = NO;
		dropButton.hidden = YES;
		deleteButton.hidden = YES;
	}
	NSString *mediaURL = [appModel getURLString:item.mediaURL];
	NSLog(@"ItemDetailsViewController: View Loaded. Current item: %@; mediaURL: %@", item.name, mediaURL);


	//Set Up General Stuff
	descriptionView.text = item.description;
	
	if ([item.type isEqualToString: @"Image"]) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		//Setup the image view
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:mediaURL]];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

		UIImage* image = [[UIImage alloc] initWithData:imageData];
		UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 360,220)];
		imageView.image = image;
		
		//Add the image view
		[[self view] addSubview:imageView];
		
		//clean up
		[imageData release];
		[image release];
		[imageView release];
	}
	else if ([item.type isEqualToString: @"AV"]) {
		NSLog(@"ItemDetailsViewController:  Video Layout Selected");

		//Create movie player object
		mMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:mediaURL]];
		
		// Register to receive a notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePreloadDidFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:mMoviePlayer];
				
		
		//Configure Movie Player
		mMoviePlayer.scalingMode = MPMovieScalingModeFill; // Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
		mMoviePlayer.movieControlMode = MPMovieControlModeDefault; //Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly, MPMovieControlModeHidden.
		mMoviePlayer.backgroundColor = [UIColor blackColor];
		
		//Add a button
		UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:CGRectMake(120, 120, 80, 80)];
		[button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:[UIImage imageNamed:@"playArrow.png"] forState:UIControlStateNormal];
		//[button setBackgroundColor:[UIColor whiteColor]];
		[[self view] addSubview:button];		
	}
	
	[mediaURL release];
	[super viewDidLoad];
}


//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{ 
}



- (IBAction)dropButtonTouchAction: (id) sender{
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:@"Inventory"];
	NSString *URLparams = [ NSString stringWithFormat:@"&controller=SimpleREST&event=dropItemHere&item_id=%d", self.item.itemId];
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"ItemDetailsViewController: Dropping Item Here using REST Call: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Item Dropped" message: @"Your Item was dropped here on the map. Other players will not see this object on their map." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	
	
	//Dismiss Item Details View
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	//Refresh the Nearby Locations
	[appModel updateServerLocationAndfetchNearbyLocationList];
	
	//Refresh Map Locations
	[appModel fetchLocationList];
	
	//Refresh the inventory
	[appModel fetchInventory];
	
}

- (IBAction)deleteButtonTouchAction: (id) sender{
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:@"Inventory"];
	NSString *URLparams = [ NSString stringWithFormat:@"&controller=SimpleREST&event=destroyPlayerItem&item_id=%d", self.item.itemId];
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"ItemDetailsViewController: Deleting all Items for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Item destroyed" message: @"This object was removed from your inventory" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
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

-(IBAction)playMovie:(id)sender
{
    [mMoviePlayer play];
}

- (IBAction)pickupButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: pickupButtonTouched");
	
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:@"Inventory"];
	NSString *URLparams = [ NSString stringWithFormat:@"&controller=SimpleREST&event=pickupItem&item_id=%d&location_id=%d", self.item.itemId, self.item.locationId];
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"ItemDetailsViewController: Telling server to pickup this item using URL: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Picked up an Item" message: @"It is available in your inventory" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	
	//Refresh the Nearby Locations
	[appModel updateServerLocationAndfetchNearbyLocationList];
	
	//Refresh Map Locations
	[appModel fetchLocationList];
	
	//Refresh the inventory
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
