//
//  PanoramicViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PanoramicViewController.h"
#import "PanoramicMedia.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "UIImage+Scale.h"
#import "UIDevice+Hardware.h"
#import "DialogViewController.h"

@implementation PanoramicViewController

@synthesize panoramic,plView,connection,data,media,imagePickerController,viewHasAlreadyAppeared,slider,numTextures,lblSpacing,delegate,showedAlignment;

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
    
    [plView.motionManager stopGyroUpdates];
    plView.isGyroEnabled = NO;
    [plView removeFromSuperview];
    [plView stopAnimation];
    [plView removeAllTextures];
    
    
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
    NSArray *textureArrayAlloc = [[NSArray alloc] init];
    self.panoramic.textureArray = textureArrayAlloc;
    
    self.slider.hidden = YES;
    self.slider.value = 1;
    self.slider.continuous = NO;
    //Setup the PLView
    plView.isDeviceOrientationEnabled = NO;
	plView.type = PLViewTypeSpherical;
    /*UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"garden_frame1" ofType:@"jpg"]];
    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"garden_frame2" ofType:@"jpg"]];
    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"garden_frame3" ofType:@"jpg"]];*/
    
   /* if ([self.panoramic.name isEqualToString: @"Garden Time Panoramic"]) {
        self.panoramic.textureArray = [NSArray arrayWithObjects:image1,image2,image3, nil];

    } */
    
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
    
    self.numTextures = [self.panoramic.media count];
        //[self loadImageFromMedia:[self.panoramic.textureArray objectAtIndex:(x-1)]];
        
    
    if(self.numTextures > 1){
        if (self.plView.motionManager.gyroAvailable) {
            
            [self.plView.motionManager startDeviceMotionUpdates];
            [self.plView.motionManager startGyroUpdates];
            
        }
        self.slider.hidden = NO;
        self.slider.minimumValue = 1;
        self.slider.maximumValue = self.numTextures;
        plView.frame = CGRectMake(plView.frame.origin.x, plView.frame.origin.y, plView.frame.size.width, plView.frame.size.height - 60);
        self.slider.frame = CGRectMake(15, plView.frame.origin.y + plView.frame.size.height + 5, 290, 20);

        self.lblSpacing = self.slider.frame.size.width/(self.numTextures-1);
        for(int x = 0;x < self.numTextures; x++)
        {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.slider.frame.origin.x + lblSpacing*x - 25, self.slider.frame.origin.y + 10, 50, 70)];
            lbl.text = [[self.panoramic.media objectAtIndex:x] text];
            lbl.textAlignment = UITextAlignmentLeft;
            lbl.transform = CGAffineTransformMakeRotation( M_PI/2 );
            lbl.textColor = [UIColor whiteColor];
            lbl.font = [UIFont systemFontOfSize:10];
            lbl.backgroundColor = [UIColor clearColor];
            [self.view addSubview:lbl];
            
Media *panoMedia = [[AppModel sharedAppModel] mediaForMediaId: [[self.panoramic.media objectAtIndex:x] mediaId]]; 
          self.panoramic.textureArray = [self.panoramic.textureArray arrayByAddingObject:panoMedia];
            //[panoMedia release];
        }
    }
    else {Media *panoMedia = [[AppModel sharedAppModel] mediaForMediaId: [[self.panoramic.media objectAtIndex:0] mediaId]]; 
        self.panoramic.textureArray = [self.panoramic.textureArray arrayByAddingObject:panoMedia]; }
    
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
    
    self.viewHasAlreadyAppeared = NO;
    self.showedAlignment = NO;
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"PanoVC: viewDidAppear");
    //Only do this the first time the view appears
    if (!self.viewHasAlreadyAppeared) {

        [self loadImageFromMedia:[self.panoramic.textureArray objectAtIndex:0]];
        if([self.panoramic.media count] < 2){
        
            self.slider.hidden = YES;
        }
        else self.slider.hidden = NO;
        }
    
    if (self.plView.motionManager.gyroAvailable) {
        
        [self.plView.motionManager startDeviceMotionUpdates];
        [self.plView.motionManager startGyroUpdates];
        NSLog(@"PanoVC: enable Gyro");
        [self.plView enableGyro] ;
        
    }
  
    self.viewHasAlreadyAppeared = YES;

}


-(void) viewDidDisappear:(BOOL)animated {
    NSLog(@"PanoVC: viewDidDisappear");
    [(Media *)[self.panoramic.textureArray objectAtIndex:0] setImage:nil];
    [plView.motionManager stopGyroUpdates];
    [plView.gyroTimer invalidate];
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
	[[AppServices sharedAppServices] updateServerPanoramicViewed:self.panoramic.panoramicId fromLocation:self.panoramic.locationId];
	
	//[self.view removeFromSuperview];
    if([self.delegate isKindOfClass:[DialogViewController class]])
	[self.navigationController popToRootViewControllerAnimated:YES];
    else{
        [RootViewController sharedRootViewController].modalPresent=NO;
        [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];}
    
    }


-(IBAction) sliderValueChanged: (id) sender{
    [self.slider setValue:roundf(self.slider.value) animated:YES];
    [self loadImageFromMedia: [self.panoramic.textureArray objectAtIndex: (int)self.slider.value-1]];
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
	[[RootViewController sharedRootViewController] showNewWaitingIndicator:@"Loading" displayProgressBar:YES];
	self.media = aMedia;
	//check if the media already as the image, if so, just grab it
    if(self.media.image) [self showPanoView];;
    if (!aMedia.url) {
        return;
    }
	
	//set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
		
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:aMedia.url]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (self.data==nil) {
		data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//end the UI indicator
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	//throw out the connection
    self.connection=nil;
	
	//turn the data into an image
	UIImage* image = [UIImage imageWithData:data];
    if([[[UIDevice currentDevice] platform] isEqualToString:@"iPhone2,1"]  || [[[UIDevice currentDevice] platform] isEqualToString:@"iPhone3,1"] || [[[UIDevice currentDevice] platform] isEqualToString:@"iPad2,1"]){
        image = [image scaleToSize:CGSizeMake(2048, 2048)];
        NSLog(@"iOS version- %@ Scaled to 2048", [[UIDevice currentDevice] platform]);
    }
    else{
        image = [image scaleToSize:CGSizeMake(1024, 1024)];
        NSLog(@"iOS version- %@ Scaled to 1024", [[UIDevice currentDevice] platform]);
    }
    
	//throw out the data
    self.data=nil;
	
	//Save the image in the media
	self.media.image = UIImageJPEGRepresentation(image, 1.0);
	if(self.media.image)
    [self showPanoView];
	
	}
- (void)showPanoView{
    NSLog(@"PanoVC: showPanoView");
	[[RootViewController sharedRootViewController] removeNewWaitingIndicator];
    [plView stopAnimation];
    [plView removeAllTextures];
    [plView addTextureAndRelease:[PLTexture textureWithImage:[UIImage imageWithData:self.media.image]]];
    [plView reset];
    [plView drawView];
 
    [self.view addSubview:plView];
}


@end
