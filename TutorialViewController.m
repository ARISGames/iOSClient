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

- (id)init {
    self = [super init];
    if (self) {
	}
    return self;
}



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
 -(BOOL)shouldAutorotate{
 return YES;
 }
 
 -(NSInteger)supportedInterfaceOrientations{
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
*/

- (void) showTutorialPopupPointingToTabForViewController:(UIViewController*)vc
											  type:(tutorialPopupType)type
											 title:(NSString *)title 
										   message:(NSString *)message{
	
	NSLog(@"TutorialViewController: showTutorialPopupPointingToTabForViewController");
	self.view.hidden = NO;
	
	
	TutorialPopupView *popup = [[TutorialPopupView alloc] init];
	popup.associatedViewController = vc;
	popup.type = type;
	popup.title = title;
	popup.message = message;
			
	//Show it
	popup.alpha = 0;
	[self.view addSubview:popup];	
	[UIView beginAnimations:@"tutorialPopup" context:nil];
	[UIView setAnimationDuration:0.5];
	popup.alpha = 1.0;
	[UIView commitAnimations];
}

- (void) dismissAllTutorials {
	NSArray *popups = self.view.subviews;
	for(TutorialPopupView *tpv in popups) [tpv removeFromSuperview];
}


- (void) dismissTutorialPopupWithType:(tutorialPopupType)type{
	//Find it
	NSArray *popups = self.view.subviews;
	for(TutorialPopupView *tpv in popups) {
		if (tpv.type == type) {
			[tpv removeFromSuperview];
		}
	}
	[self.view setNeedsDisplay];
	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
