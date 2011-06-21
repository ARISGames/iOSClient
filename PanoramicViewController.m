//
//  PanoramicViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanoramicViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncImageView.h"

@implementation PanoramicViewController
@synthesize panoramic,plView,viewImageContainer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	if(viewImageContainer)
		[viewImageContainer release];
	if(plView)
		[plView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
    
    
    plView.isDeviceOrientationEnabled = NO;
	plView.isAccelerometerEnabled = NO;
	plView.isScrollingEnabled = NO;
	plView.isInertiaEnabled = NO;
    
	plView.type = PLViewTypeSpherical;
	[self loadImage:@"photo2"];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)backButtonTouchAction: (id) sender{
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerPanoramicViewed:self.panoramic.panoramicId];
	
	
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:NO];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadImage:(NSString *)name
{
	[plView stopAnimation];
	[plView removeAllTextures];
	[plView addTextureAndRelease:[PLTexture textureWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]]];
	[plView reset];
	[plView drawView];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	CGRect frame = plView.frame;
	switch (interfaceOrientation) 
	{
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			viewImageContainer.hidden = NO;
			frame.size.width = 320;
			frame.size.height = 340;
			plView.frame = frame;
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			viewImageContainer.hidden = YES;
			frame.size.width = 480;
			frame.size.height = 320;
			plView.frame = frame;
			break;
	}
    // Return YES for supported orientations
    return YES;

}


@end
