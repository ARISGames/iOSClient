//
//  GameDetails.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameDetails.h"

NSString *const kGameDetailsHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";





@implementation GameDetails

@synthesize map;
@synthesize descriptionWebView;
@synthesize game;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[descriptionWebView setBackgroundColor:[UIColor clearColor]];

}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"GameDetails: View Will Appear, Refresh");
	self.title = self.game.name;
	
	
	NSString *resourcePath = [[NSString stringWithFormat:@"file:/%@//", [[[[NSBundle mainBundle] resourcePath]
																stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
															   stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] retain];
	NSLog(@"GameDetails: Resource Path: %@", resourcePath);

	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.description];
	NSLog(@"GameDetails: HTML Description: %@", htmlDescription);
	[descriptionWebView loadHTMLString:htmlDescription baseURL:[NSURL URLWithString:resourcePath]];
	
	
	MKCoordinateRegion region = map.region;
	region.center = self.game.location.coordinate;
	region.span.latitudeDelta=0.1;
	region.span.longitudeDelta=0.1;
	[map setRegion:region animated:YES];
	[map regionThatFits:region];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


- (void)dealloc {
    [super dealloc];
}


@end
