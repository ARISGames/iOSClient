//
//  GameDetails.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
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
@"		margin: 0px;"
@"	}"
@"	a {color: #FFFFFF; text-decoration: underline; }"
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
@synthesize descriptionLabel;
@synthesize mapLabel;
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
	self.title = NSLocalizedString(@"GameDetailsTitleKey",@"");
	
	descriptionLabel.text = NSLocalizedString(@"DescriptionKey",@"");
	mapLabel.text = NSLocalizedString(@"MapKey",@"");

	
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width,contentView.frame.size.height);
	
	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.description];
	NSLog(@"GameDetails: HTML Description: %@", htmlDescription);
	descriptionWebView.delegate = self;
	[descriptionWebView loadHTMLString:htmlDescription baseURL:nil];
	
	
	MKCoordinateRegion region = map.region;
	region.center = self.game.location.coordinate;
	region.span.latitudeDelta=0.1;
	region.span.longitudeDelta=0.1;
	[map setRegion:region animated:YES];
	[map regionThatFits:region];
	
	playersLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"PlayersKey",@""),game.numPlayers];
	authorsLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"AuthorsKey",@""),game.authors];
	
	if (game.iconMediaId != 0) {
		AppModel *appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
		Media *iconMedia = [appModel mediaForMediaId: game.iconMediaId];
		[iconView loadImageFromMedia:iconMedia];
	}

	locationLabel.text = @"";
	MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.game.location.coordinate];
	reverseGeocoder.delegate = self;
	[reverseGeocoder start];
	[reverseGeocoder release];
	
	titleLabel.text = game.name;
	
}

- (void)webViewDidFinishLoad:(UIWebView *)descriptionView {
	//Content Loaded, now we can resize
	
	float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
	
	NSLog(@"GameDetails: Description View Calculated Height is: %f",newHeight);
	
	CGRect descriptionFrame = [descriptionView frame];	
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];	
	NSLog(@"GameDetails: description UIWebView frame set to {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
	
	//Move the Map Title and Map Down
	CGRect originalMapLabelFrame = mapLabel.frame;
	CGRect originalMapFrame = map.frame;
	float margin = 25;
	float newMapLabelYPosition = descriptionFrame.origin.y + descriptionFrame.size.height + margin;
	float newMapYPosition = newMapLabelYPosition + originalMapLabelFrame.size.height + margin;
	
	[mapLabel setFrame:CGRectMake(originalMapLabelFrame.origin.x, newMapLabelYPosition, 
								  originalMapLabelFrame.size.width, originalMapLabelFrame.size.height)];
	
	[map setFrame:CGRectMake(originalMapFrame.origin.x, newMapYPosition, 
							 originalMapFrame.size.width, originalMapFrame.size.height)];
}


- (BOOL)webView:(UIWebView *)webView  
      shouldStartLoadWithRequest:(NSURLRequest *)request  
      navigationType:(UIWebViewNavigationType)navigationType; {  
   
    NSURL *requestURL = [ [ request URL ] retain ];  
     // Check to see what protocol/scheme the requested URL is.  
     if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ]  
         || [ [ requestURL scheme ] isEqualToString: @"https" ] )  
         && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {  
         return ![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];  
     }  
     // Auto release  
     [ requestURL release ];  
     // If request url is something other than http or https it will open  
     // in UIWebView. You could also check for the other following  
     // protocols: tel, mailto and sms  
     return YES;  
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
