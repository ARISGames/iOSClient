//
//  GameDetails.m
//  ARIS
//
//  Created by David J Gagnon on 4/18/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "GameDetails.h"
#import "AppServices.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "commentsViewController.h"
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

@synthesize descriptionWebView;
@synthesize game;
@synthesize titleLabel;
@synthesize authorsLabel;
@synthesize descriptionLabel;
@synthesize locationLabel;
@synthesize iconView;
@synthesize scrollView;
@synthesize contentView;
@synthesize segmentedControl;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    self.title = self.game.name;
    self.authorsLabel.text = @"Author(s): "; 
    self.authorsLabel.text = [self.authorsLabel.text stringByAppendingString:self.game.authors];
    self.descriptionLabel.text = @"Description: "; 
    //self.descriptionLabel.text = [self.descriptionLabel.text stringByAppendingString:self.game.description];
	[descriptionWebView setBackgroundColor:[UIColor clearColor]];
    [self.segmentedControl setTitle:[NSString stringWithFormat: @"Rating: %d",game.rating] forSegmentAtIndex:0];
    
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"GameDetails: View Will Appear, Refresh");
	
	
	scrollView.contentSize = CGSizeMake(contentView.frame.size.width,contentView.frame.size.height);
	
	NSString *htmlDescription = [NSString stringWithFormat:kGameDetailsHtmlTemplate, self.game.description];
	NSLog(@"GameDetails: HTML Description: %@", htmlDescription);
	descriptionWebView.delegate = self;
	[descriptionWebView loadHTMLString:htmlDescription baseURL:nil];
    
    if ([self.game.mediaUrl length] > 0) {
		Media *splashMedia = [[Media alloc] initWithId:1 andUrlString:self.game.mediaUrl ofType:@"Splash"];
		[self.iconView loadImageFromMedia:splashMedia];
	}
	else self.iconView.image = [UIImage imageNamed:@"Icon.png"];
     	
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
	
	
}

- (IBAction)segmentedControlChanged:(id) sender{
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        commentsViewController *commentsVC = [[commentsViewController alloc]initWithNibName:@"commentsView" bundle:nil];
        commentsVC.game = self.game;
        [self.navigationController pushViewController:commentsVC animated:YES];
        [commentsVC release];
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {

        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:self.game
                                                               forKey:@"game"];
        
        [[AppServices sharedAppServices] silenceNextServerUpdate];
        NSNotification *gameSelectNotification = [NSNotification notificationWithName:@"SelectGame" object:self userInfo:dictionary];
        [[NSNotificationCenter defaultCenter] postNotification:gameSelectNotification];
        [self.navigationController popViewControllerAnimated:NO];
    }

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
    [descriptionWebView release];
    [game release];
    [authorsLabel release];
    [descriptionLabel release];
    [locationLabel release];
    [iconView release];
    [scrollView release];
    [contentView release];
    [super dealloc];
}


@end
