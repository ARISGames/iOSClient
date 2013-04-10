//
//  LoadingViewControllerViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
@interface LoadingViewController ()

@end

@implementation LoadingViewController
@synthesize splashImage;
@synthesize progressBar;
@synthesize progressLabel;
@synthesize receivedData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        receivedData = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived) name:@"GamePieceReceived" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    progressBar.progress = 0.0;
    [self moveProgressBar];
}

-(void) dataReceived
{
    receivedData++;
    [self moveProgressBar];
}

- (void)moveProgressBar
{
    float actual = (receivedData/(float)10);//<- What. '10'? Where did that number come from?
    if (actual < 1)
    {
        progressBar.progress = actual;
        [progressBar setNeedsLayout];
        [progressBar setNeedsDisplay];
        [progressLabel setNeedsDisplay];
        [progressLabel setNeedsLayout];
    }
    else if(actual >= 0.999)
    {
        NSLog(@"NSNotification: GameFinishedLoading");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GameFinishedLoading" object:nil userInfo:nil]];
        [self dismissModalViewControllerAnimated:NO];//<- depricated
        receivedData = 0;
    }
    else if(actual > 1)
    {
        NSLog(@"loadingviewcontroller got more than asked for... uh oh...");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end