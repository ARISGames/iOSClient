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
@synthesize splashImage, progressBar,progressLabel,receivedData;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([AppModel sharedAppModel].currentGame.splashMedia) {
        self.splashImage.image = [UIImage imageWithData:[AppModel sharedAppModel].currentGame.splashMedia.image];
    }
    else self.splashImage.image = [UIImage imageNamed:@"Default.png"];
    progressBar.progress = 0.0;
    [self performSelectorOnMainThread:@selector(moveProgressBar) withObject:nil waitUntilDone:YES];
}

- (void)moveProgressBar {
    
    float actual = (receivedData/(float)11);
    if (actual < 1) {
        progressBar.progress =actual;
        [self performSelector:@selector(moveProgressBar) withObject:nil afterDelay:.1];
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(moveProgressBar) userInfo:nil repeats:NO];

    }
    else{
                ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
        
           if ([AppModel sharedAppModel].currentGame.completedQuests < 1)
               [appDelegate performSelector:@selector(displayIntroNode) withObject:nil afterDelay:.1];
        [self dismissModalViewControllerAnimated:NO];

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
