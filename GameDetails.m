//
//  GameDetails.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameDetails.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import <MapKit/MKReverseGeocoder.h>

NSString *const kGameDetailsHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: transparent;"
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
@synthesize titleLabel;
@synthesize playersLabel;
@synthesize authorsLabel;
@synthesize locationLabel;
@synthesize iconView;
@synthesize scrollView;
@synthesize contentView;


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
	self.title = @"Details";
	
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width,contentView.frame.size.height);
	
	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.description];
	NSLog(@"GameDetails: HTML Description: %@", htmlDescription);
	[descriptionWebView loadHTMLString:htmlDescription baseURL:nil];
	
	
	MKCoordinateRegion region = map.region;
	region.center = self.game.location.coordinate;
	region.span.latitudeDelta=0.1;
	region.span.longitudeDelta=0.1;
	[map setRegion:region animated:YES];
	[map regionThatFits:region];
	
	playersLabel.text = [NSString stringWithFormat:@"Players: %d",game.numPlayers];
	authorsLabel.text = [NSString stringWithFormat:@"Authors: %@",game.authors];
	
	if (game.iconMediaId != 0) {
		AppModel *appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		Media *iconMedia = [appModel mediaForMediaId: game.iconMediaId];
		[iconView loadImageFromMedia:iconMedia];
	}
	else iconView.image = [UIImage imageNamed:@"Icon.png"];
	
	locationLabel.text = @"";
	MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.game.location.coordinate];
	reverseGeocoder.delegate = self;
	[reverseGeocoder start];
	
	titleLabel.text = game.name;
	
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark MKReverseGeocoderDelegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	locationLabel.text = [NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea];
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
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


- (void)dealloc {
    [super dealloc];
}


@end
