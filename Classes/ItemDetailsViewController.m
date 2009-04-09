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
@synthesize descriptionView;
@synthesize dropButton;
@synthesize deleteButton;
@synthesize backButton;


-(void) setModel:(AppModel *)model{
	if(appModel != model) {
		[appModel release];
		appModel = model;
		[appModel retain];
	}
	NSLog(@"Item Detail View: Model set");
}

-(void) setItem:(Item *)newItem{
	if(item != newItem) {
		[item release];
		item = newItem;
		[item retain];
	}
	
	NSLog(@"Item Detail View: Item set");
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	descriptionView.text = item.description;
	
	if ([item.type isEqualToString: @"Image"]) {
		NSLog(@"Item Detail View: Image Layout Selected");
		
		//Setup the image view
		NSString* imageURL = [item.mediaURL stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:imageURL]];
		UIImage* image = [[UIImage alloc] initWithData:imageData];
		UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 360,300)];
		[imageView setImage: image];
		
		//Add the image view
		[[self view] addSubview:imageView];
		
		//clean up
		[imageURL release];
		[imageData release];
		[image release];
		[imageView release];
	}
	
	if ([item.type isEqualToString: @"AV"]) {
		NSLog(@"Item Detail View: Video Layout Selected");
		
		
		
		//Create movie player object
		NSString* videoURL = [item.mediaURL stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		mMoviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
		
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
	NSString *baseURL = [appModel getURLStringForModule:@"RESTInventory"];
	NSString *URLparams = [ NSString stringWithFormat:@"&event=dropItemHere&item_id=%d", self.item.itemId];
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"Dropping Item Here using REST Call: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	
	//Refresh the inventory - CRASHES?
	//[appModel fetchInventory];
	
	//Dismiss Item Details View
	[self dismissModalViewControllerAnimated:NO];
	
}

- (IBAction)deleteButtonTouchAction: (id) sender{
	//Fire off a request to the REST Module and display an alert when it is successfull
	NSString *baseURL = [appModel getURLStringForModule:@"RESTInventory"];
	NSString *URLparams = [ NSString stringWithFormat:@"&event=destroyPlayerItem&item_id=%d", self.item.itemId];
	NSString *fullURL = [ NSString stringWithFormat:@"%@%@", baseURL, URLparams];
	
	NSLog([NSString stringWithFormat:@"Deleting all Items for this Player on server: %@", fullURL ]);
	
	NSString *result = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:fullURL]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success" message: result delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
	
	[alert show];
	[result release];
	[alert release];
	
	//Refresh the inventory - CRASHES?
	//[appModel fetchInventory];
	
	//Dismiss Item Details View
	[self dismissModalViewControllerAnimated:NO];
	
}
- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"Dismiss Item Details View");
	[self dismissModalViewControllerAnimated:NO];
}

-(IBAction)playMovie:(id)sender
{
    [mMoviePlayer play];
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
