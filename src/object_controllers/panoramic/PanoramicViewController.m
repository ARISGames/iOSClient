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
#import "ARISAppDelegate.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "UIImage+Scale.h"
#import "UIDevice+Hardware.h"
#import "NpcViewController.h"

@interface PanoramicViewController() <ARISMediaViewDelegate>
{
    Panoramic *panoramic;
    IBOutlet PLView	*plView;
    ARISMediaView *imageLoader;
}
@property (nonatomic, strong) Panoramic *panoramic;
@property (nonatomic, strong) IBOutlet PLView *plView;
@property (nonatomic, strong) ARISMediaView *imageLoader;

@end

@implementation PanoramicViewController

@synthesize panoramic;
@synthesize plView;
@synthesize imageLoader;

- (id) initWithPanoramic:(Panoramic *)p delegate:(NSObject<GameObjectViewControllerDelegate> *)d
{
    if(self = [super initWithNibName:@"PanoramicViewController" bundle:nil])
    {
        delegate = d;

        self.panoramic = p;
        return self;
    }
    return nil;
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //Setup the PLView
    plView.isDeviceOrientationEnabled = NO;
	plView.type = PLViewTypeSpherical;
        
    if([[AppModel sharedAppModel].motionManager isGyroAvailable])
    {
        plView.isGyroEnabled = YES;
        plView.isAccelerometerEnabled = NO;
        plView.isScrollingEnabled = NO;
        plView.isInertiaEnabled = NO;
    }
    else
    {
        plView.isGyroEnabled = NO;
        plView.isAccelerometerEnabled = NO;
        plView.isScrollingEnabled = YES;
        plView.isInertiaEnabled = NO;
    }
    
    self.imageLoader = [[ARISMediaView alloc] initWithDelegate:self];
    self.imageLoader.media = [[AppModel sharedAppModel] mediaForMediaId:self.panoramic.mediaId];
    
    //Create a back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouchAction:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    if ([AppModel sharedAppModel].motionManager.gyroAvailable)
    {
        [[AppModel sharedAppModel].motionManager startDeviceMotionUpdates];
        [[AppModel sharedAppModel].motionManager startGyroUpdates];
        [self.plView enableGyro] ;
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[AppModel sharedAppModel].motionManager stopGyroUpdates];
    [plView.gyroTimer invalidate];
}

- (IBAction) backButtonTouchAction:(id)sender
{    
	[[AppServices sharedAppServices] updateServerPanoramicViewed:self.panoramic.panoramicId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
    UIImage *image;// = amv.image; //Don't use ARISMediaView just to get an image- we now have separate mediaLoader
    if([[[UIDevice currentDevice] platform] isEqualToString:@"iPhone2,1"] ||
       [[[UIDevice currentDevice] platform] isEqualToString:@"iPhone3,1"] ||
       [[[UIDevice currentDevice] platform] isEqualToString:@"iPad2,1"])
    {
        image = [image scaleToSize:CGSizeMake(2048, 2048)];
        NSLog(@"iOS version- %@ Scaled to 2048", [[UIDevice currentDevice] platform]);
    }
    else
    {
        image = [image scaleToSize:CGSizeMake(1024, 1024)];
        NSLog(@"iOS version- %@ Scaled to 1024", [[UIDevice currentDevice] platform]);
    }

    [self showPanoViewWithImage:image];
}

- (void) showPanoViewWithImage:(UIImage *)image
{
    [plView stopAnimation];
    [plView removeAllTextures];
    [plView addTextureAndRelease:[PLTexture textureWithImage:image]];
    [plView reset];
    [plView drawView];
    
    [self.view addSubview:plView];
}

- (void) dealloc
{
    [[AppModel sharedAppModel].motionManager stopGyroUpdates];
    plView.isGyroEnabled = NO;
    [plView removeFromSuperview];
    [plView stopAnimation];
    [plView removeAllTextures];
}

@end
