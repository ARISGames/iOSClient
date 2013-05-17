//
//  LoadingViewController.m
//  ARIS
//
//  Created by Brian Thiel on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"

@interface LoadingViewController()
{
    id<LoadingViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation LoadingViewController

@synthesize splashImage;
@synthesize progressBar;
@synthesize progressLabel;
@synthesize receivedData;

- (id) initWithDelegate:(id<LoadingViewControllerDelegate>)d;
{
    if(self = [super initWithNibName:@"LoadingViewController" bundle:nil])
    {
        delegate = d;
        
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
    
    progressLabel.text = NSLocalizedString(@"ARISAppDelegateFectchingGameListsKey", @"");
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
    float actual = ((float)receivedData/7.0f);//<- What. '8'? Where did that number come from?
    progressBar.progress = actual;
    [progressBar setNeedsLayout];
    [progressBar setNeedsDisplay];
    [progressLabel setNeedsDisplay];
    [progressLabel setNeedsLayout];
    
    if(actual >= 0.999)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        [delegate loadingViewControllerDidComplete];
        receivedData = 0;
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

-(NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end
