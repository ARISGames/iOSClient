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
@synthesize splashImage, progressBar,progressLabel,receivedData, timer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        receivedData = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    progressBar.progress = 0.0;
    [self performSelectorOnMainThread:@selector(moveProgressBar) withObject:nil waitUntilDone:YES];
}
-(float)receivedData{
    return receivedData;
}
-(void)setReceivedData:(float)r{
    receivedData = r;
    [self performSelectorOnMainThread:@selector(moveProgressBar) withObject:nil waitUntilDone:YES];
}
- (void)moveProgressBar {
    
    float actual = (receivedData/(float)10);
    if (actual < 1)
    {
        progressBar.progress =actual;
        [progressBar setNeedsLayout];
        [progressBar setNeedsDisplay];
        [progressLabel setNeedsDisplay];
        [progressLabel setNeedsLayout];
       
    }
    else if(actual == 1)
    {
           if ([AppModel sharedAppModel].currentGame.completedQuests < 1)
               [[RootViewController sharedRootViewController] performSelector:@selector(displayIntroNode) withObject:nil afterDelay:.1];
        [self dismissModalViewControllerAnimated:NO];
        [RootViewController sharedRootViewController].loadingVC = nil;
    } 
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
