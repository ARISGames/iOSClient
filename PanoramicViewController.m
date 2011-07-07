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

@synthesize panoramic,plView,connection,data,media,imagePickerController,viewHasAlreadyAppeared;

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
    [panoramic release];
    
    [plView.motionManager stopGyroUpdates];
    plView.isGyroEnabled = NO;
    [plView removeFromSuperview];
    [plView stopAnimation];
    [plView removeAllTextures];
    [plView release];
    
    [imagePickerController release];
    [media release];
    
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
    NSLog(@"PanoVC: viewDidLoad");

    [super viewDidLoad];
    
    //Setup the PLView
    plView.isDeviceOrientationEnabled = NO;
	plView.type = PLViewTypeSpherical;
    
    if([plView.motionManager isGyroAvailable]){
        plView.isGyroEnabled = YES;
        plView.isAccelerometerEnabled = NO;
        plView.isScrollingEnabled = NO;
        plView.isInertiaEnabled = NO;
    }
    else {
        plView.isGyroEnabled = NO;
        plView.isAccelerometerEnabled = NO;
        plView.isScrollingEnabled = YES;
        plView.isInertiaEnabled = YES;
    }
    
    
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
    
    self.viewHasAlreadyAppeared = NO;
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"PanoVC: viewDidAppear");

    //Only do this the first time the view appears
    if (!self.viewHasAlreadyAppeared) {
        Media *panoMedia = [[AppModel sharedAppModel] mediaForMediaId: self.panoramic.mediaId];
        [self loadImageFromMedia:panoMedia];
    }
        
    self.viewHasAlreadyAppeared = YES;

}


-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"PanoVC: viewDidDisappear");
}


- (void)panoImageDidFinishLoading{
    NSLog(@"PanoVC: panoImageDidFinishLoading");
    
    NSLog(@"PanoVC: panoImageDidFinishLoading: Max Texture Size on this Device: %d", GL_MAX_TEXTURE_SIZE);


    [plView stopAnimation];
    [plView removeAllTextures];
    [plView addTextureAndRelease:[PLTexture textureWithImage:self.media.image]];
    [plView reset];
    [plView drawView];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                
        //Setup the UIImagePickerVC for aligning
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePickerController.sourceType];
        self.imagePickerController.allowsEditing = NO;
        self.imagePickerController.showsCameraControls = NO;
        self.imagePickerController.delegate = self;
        
        
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 27.0);
        imagePickerController.cameraViewTransform = translate;
        CGAffineTransform scale = CGAffineTransformScale(translate, 1, 1.25);
        imagePickerController.cameraViewTransform = scale;
        
        
        /*
        //Load the alignment image from the server
        UIImageView *alignmentImageView = [[UIImageView alloc] initWithImage:self.media.image];
        alignmentImageView.frame = self.plView.frame;
        alignmentImageView.contentMode = UIViewContentModeScaleAspectFill;            
        alignmentImageView.alpha = .5;
        self.imagePickerController.cameraOverlayView = alignmentImageView; 
        [alignmentImageView release];
         */
        
        //Capture a static alignment image from the plView
        UIImageView *alignmentImageView = [[UIImageView alloc] initWithImage:[plView getSnapshot]];
        alignmentImageView.alpha = .5;
        [self.imagePickerController.cameraOverlayView addSubview:alignmentImageView]; 
        [alignmentImageView release];
        
        if (self.plView.motionManager.gyroAvailable) {

        [self.plView.motionManager startDeviceMotionUpdates];
        [self.plView.motionManager startGyroUpdates];
            
        }
        
        //Put a button on screen
        UIButton *touchScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        [touchScreen setTitle:@"Line Up Views, Then\nTouch Screen To Continue" forState:UIControlStateNormal];
        touchScreen.titleLabel.font = [UIFont systemFontOfSize:24];
        touchScreen.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        touchScreen.titleLabel.textAlignment = UITextAlignmentCenter;
        touchScreen.titleLabel.numberOfLines = 2;
        touchScreen.frame = self.plView.frame;
        [self.imagePickerController.view addSubview:touchScreen];
        [touchScreen addTarget:self action:@selector(touchScreen) forControlEvents:UIControlEventTouchUpInside];
        
        [self presentModalViewController:self.imagePickerController animated:NO];
    }
    else {
        [self showPanoView];
    }
}


- (void)showPanoView{
    NSLog(@"PanoVC: showPanoView");

    if (self.plView.motionManager.gyroAvailable) {
        NSLog(@"PanoVC: enable Gyro");
        [self.plView enableGyro] ;
    }    
    [self.view addSubview:plView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Button Handlers

- (IBAction)backButtonTouchAction: (id) sender{
    NSLog(@"PanoVC: backButtonTouchAction");

	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerPanoramicViewed:self.panoramic.panoramicId];
	
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:NO];
}

-(IBAction) touchScreen {
    NSLog(@"PanoVC: touchScreen");
    
    [self dismissModalViewControllerAnimated:YES];

    [self showPanoView];
}

#pragma mark -
#pragma mark PLView Delegate
/*
- (BOOL)viewShouldReset:(PLViewBase *)plView{
    NSLog(@"PanoVC: viewShouldReset");
    return YES;      
}
*/
- (void)viewDidReset:(PLViewBase *)plView{
    NSLog(@"PanoVC: viewDidReset");    
}


#pragma mark Async Image Loading
- (void)loadImageFromMedia:(Media *) aMedia {
	self.media = aMedia;
	//check if the media already as the image, if so, just grab it

    if (!aMedia.url) {
        return;
    }
	
	//set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
		
	if (connection!=nil) { [connection release]; }
    NSURLRequest* request = [NSURLRequest requestWithURL:[[NSURL alloc]initWithString:aMedia.url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (self.data==nil) {
		self.data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//throw out the connection
    [self.connection release];
    self.connection=nil;
	
	//turn the data into an image
	UIImage* image = [UIImage imageWithData:data];
	
	//throw out the data
	[self.data release];
    self.data=nil;
	
	//Save the image in the media
	self.media.image = image;
	[self.media.image retain];
    [self panoImageDidFinishLoading];
	
	}


@end
