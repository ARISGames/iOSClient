//
//  BogusSelectGameViewController.m
//  ARIS
//
//  Created by David J Gagnon on 6/8/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "BogusSelectGameViewController.h"
#import "ARISAppDelegate.h"

@implementation BogusSelectGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title = NSLocalizedString(@"BogusTitleKey", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"213-reply.png"];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [AppModel sharedAppModel].inGame = NO;
    ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate stopAudio];
    //[[RootViewController sharedRootViewController] cutOffGameNotifications];
    [[RootViewController sharedRootViewController] showGameSelectionTabBarAndHideOthers];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate{
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
