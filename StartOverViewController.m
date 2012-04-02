//
//  StartOverViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/20/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "StartOverViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "AppModel.h"

@implementation StartOverViewController
@synthesize alert;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.title = NSLocalizedString(@"StartOverTitleKey", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"StartOverIcon.png"];		
	}
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	warningLabel.text = NSLocalizedString(@"StartOverWarningKey", @"");
	[startOverButton setTitle:NSLocalizedString(@"StartOverKey",@"") forState:UIControlStateNormal];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction)startOverButtonPressed: (id) sender{
	NSLog(@"StartOverVC: Button Pressed");
	    
	[[AppServices sharedAppServices] startOverGame];
	
	self.alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"StartOverResetAlertTitleKey", @"")
													message: NSLocalizedString(@"StartOverResetAlertMessageKey", @"")
												   delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
	[self.alert show];
    [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:5.0];
}

-(void)dismissAlert{
    [self.alert dismissWithClickedButtonIndex:0 animated:YES];
    self.alert;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
