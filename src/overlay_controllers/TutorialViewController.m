//
//  TutorialViewController.m
//  ARIS
//
//  Created by David J Gagnon on 2/18/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import "TutorialViewController.h"
#import "ARISAppDelegate.h"

@implementation TutorialViewController

- (void) loadView
{
    [super loadView];
    self.view.userInteractionEnabled = NO;
}

- (void) showTutorialPopupPointingToTabForViewController:(UIViewController*)vc title:(NSString *)title message:(NSString *)message
{	
	NSLog(@"TutorialViewController: showTutorialPopupPointingToTabForViewController");
	self.view.hidden = NO;

	TutorialPopupView *popup = [[TutorialPopupView alloc] init];
	popup.associatedViewController = vc;
    if(vc.navigationController)
        popup.associatedViewController = vc.navigationController;
	popup.title = title;
	popup.message = message;

	[self.view addSubview:popup];
}

- (void) dismissTutorials
{
	NSArray *popups = self.view.subviews;
	for(TutorialPopupView *tpv in popups) [tpv removeFromSuperview];
}

@end
