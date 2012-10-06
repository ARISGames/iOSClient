//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "NodeViewController.h"
#import "AppModel.h"
#import "AppServices.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "webpageViewController.h"
#import "WebPage.h"
#import <AVFoundation/AVFoundation.h>
#import "AsyncMediaPlayerButton.h"
#import "UIImage+Scale.h"

static NSString * const OPTION_CELL = @"option";

NSString *const kPlaqueDescriptionHtmlTemplate =
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
@"	a {color: #9999FF; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";


@implementation NodeViewController
@synthesize node, tableView, isLink, hasMedia,webViewSpinner, mediaImageView, cellArray;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
        
        self.isLink=NO;
        AsyncMediaImageView *mediaImageViewAlloc = [[AsyncMediaImageView alloc]init];
        self.mediaImageView = mediaImageViewAlloc;
        self.mediaImageView.delegate = self;
    }
    
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    NSLog(@"NodeViewController: Displaying Node '%@'",self.node.name);
    self.title = self.node.name;
    [RootViewController sharedRootViewController].modalPresent = YES;
    
    
    //Setup the Image View/Video Preview Image (if needed)
    Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];
    
    //Check if the plaque has media
    if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString: kMediaTypeAudio] || [media.type isEqualToString: kMediaTypeImage]) && media.url) hasMedia = YES;
    else hasMedia = NO;
    
    //Create Image/AV Cell
    UITableViewCell *mediaCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mediaCell"];
    
    if ([media.type isEqualToString: kMediaTypeImage] && media.url) {
        NSLog(@"NodeVC: cellForRowAtIndexPath: This is an Image Plaque");
        
        //self.mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if(!self.mediaImageView.loaded) {
            [self.mediaImageView loadImageFromMedia:media];
        }
        
        //Setup the cell as an image
        mediaCell.backgroundView = mediaImageView;
        mediaCell.backgroundView.layer.masksToBounds = YES;
        mediaCell.backgroundView.layer.cornerRadius = 5.0;
        mediaCell.userInteractionEnabled = NO;
        
        //By forcing these sizes now, the asyncimageview spinner displays in the correct location
        mediaCell.frame = CGRectMake(0, 0, 320, 320);
        self.mediaImageView.frame = CGRectMake(0, 0, 320, 320);
        
    }
    else if(([media.type isEqualToString: kMediaTypeVideo] || [media.type isEqualToString:kMediaTypeAudio]) && media.url)
    {
        NSLog(@"NodeVC: This is an A/V Plaque");
        
        
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presentingController:self preloadNow:NO];
        
        //Setup the cell as the video preview button
        mediaCell.selectionStyle = UITableViewCellSelectionStyleNone;
        mediaCell.frame =  CGRectMake(0, 0, 300, 240);
        mediaCell.backgroundColor = [UIColor clearColor];
        mediaCell.clipsToBounds = YES;
        [mediaCell addSubview:mediaButton];
        
        mediaCell.userInteractionEnabled = YES;
        
        
    }
    
    //Setup the Description Webview and begin loading content
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 300, 60)];
    webView.delegate = self;
    webView.backgroundColor =[UIColor clearColor];
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
    webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob
	[webView loadHTMLString:htmlDescription baseURL:nil];
    
    //Create Description Web View Cell
    UITableViewCell *webCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descriptionCell"];
    webCell.userInteractionEnabled = NO;
    CGRect descriptionFrame = [webView frame];
    [webView setFrame:descriptionFrame];
    webCell.backgroundView = webView;
    webCell.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *webViewSpinnerAlloc = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.webViewSpinner = webViewSpinnerAlloc;
    self.webViewSpinner.center = webCell.center;
    [self.webViewSpinner startAnimating];
    self.webViewSpinner.backgroundColor = [UIColor clearColor];
    [webCell addSubview:self.webViewSpinner];
    
    //Create continue button cell
    UITableViewCell *buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"continueButtonCell"];
    buttonCell.textLabel.text = NSLocalizedString(@"TapToContinueKey", @"");
    buttonCell.textLabel.textAlignment = UITextAlignmentCenter;
    
    //Setup the cellArray
    if(hasMedia){
        NSArray *cellArrayAlloc = [[NSArray alloc] initWithObjects:mediaCell,webCell,buttonCell, nil];
        self.cellArray = cellArrayAlloc;
    }
    else{
        NSArray *cellArrayAlloc = [[NSArray alloc] initWithObjects:webCell,buttonCell, nil];
        self.cellArray = cellArrayAlloc;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebViewDelegate Methods

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    webView.alpha = 1.00;
    
    //Calculate the height of the web content
    float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    CGRect descriptionFrame = [webView frame];
    descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight+5);
    [webView setFrame:descriptionFrame];
    
    //Find the webCell spinner and remove it
    [webViewSpinner removeFromSuperview];
    
    //Find the description cell and update it's frame with the new size
    for(int x = 0; x < 2; x++){
        if([[(UITableViewCell *)[self.cellArray objectAtIndex:x] reuseIdentifier] isEqualToString:@"descriptionCell"]){
            [(UITableViewCell *)[self.cellArray objectAtIndex:x] setFrame:webView.frame];
        }
    }
    
    [tableView reloadData];
    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType{
    
    if(self.isLink) {
        webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
        WebPage *temp = [[WebPage alloc]init];
        temp.url = [[request URL]absoluteString];
        webPageViewController.webPage = temp;
        webPageViewController.delegate = self;
        [self.navigationController pushViewController:webPageViewController animated:NO];
        
        return NO;
    }
    else return YES;
}

#pragma mark AsyncImageView Delegate Methods
-(void)imageFinishedLoading{
    NSLog(@"NodeVC: imageFinishedLoading with size: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    /*
     if(self.mediaImageView.image.size.width > 0){
     [self.mediaImageView setContentScaleFactor:(float)(320/self.mediaImageView.image.size.width)];
     self.mediaImageView.frame = CGRectMake(0, 0, 300, self.mediaImageView.contentScaleFactor*self.mediaImageView.image.size.height);
     NSLog(@"NodeVC: Image resized to: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
     [(UITableViewCell *)[self.cellArray objectAtIndex:0] setFrame:mediaImageView.frame];
     }
     
     [tableView reloadData];
     */
}


#pragma mark Button Handlers
- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:node.locationId];
	
	
	//[self.view removeFromSuperview];
    [RootViewController sharedRootViewController].modalPresent=NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
    
}

- (IBAction)continueButtonTouchAction{
    NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId fromLocation:node.locationId];
	
    //Remove thyself from the screen
    [RootViewController sharedRootViewController].modalPresent=NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
    //Check if this was the game complete Node and if so, display the "Start Over" tab
    if((node.nodeId == [AppModel sharedAppModel].currentGame.completeNodeId) &&
       ([AppModel sharedAppModel].currentGame.completeNodeId != 0)){
        
        NSString *tab;
        for(int i = 0;i < [[RootViewController sharedRootViewController].tabBarController.customizableViewControllers count];i++){
            tab = [[[RootViewController sharedRootViewController].tabBarController.customizableViewControllers objectAtIndex:i] title];
            tab = [tab lowercaseString];
            
            if([tab isEqualToString:@"start over"])
                [RootViewController sharedRootViewController].tabBarController.selectedIndex = i;
        }
    }
    
}

/*-(IBAction)playMovie:(id)sender {
 [mMoviePlayer.moviePlayer play];
 [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
 }
 */

#pragma mark MPMoviePlayerController Notification Handlers

/*
 - (void)movieLoadStateChanged:(NSNotification*) aNotification{
 MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
 
 if( state & MPMovieLoadStateUnknown ) {
 NSLog(@"NodeViewController: Unknown Load State");
 }
 if( state & MPMovieLoadStatePlayable ) {
 NSLog(@"NodeViewController: Playable Load State");
 
 //Create a thumbnail for the button
 if (![mediaPlaybackButton backgroundImageForState:UIControlStateNormal]){
 UIImage *videoThumb = [mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];
 UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(300, 240)];
 [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
 }
 
 }
 if( state & MPMovieLoadStatePlaythroughOK ) {
 NSLog(@"NodeViewController: Playthrough OK Load State");
 
 }
 if( state & MPMovieLoadStateStalled ) {
 NSLog(@"NodeViewController: Stalled Load State");
 }
 
 }*/


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellArray count];
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.cellArray objectAtIndex:indexPath.section];
    
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [self.cellArray objectAtIndex:indexPath.section];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 2 || (indexPath.section == 1 && !hasMedia)) [self continueButtonTouchAction];
    // else [self playMovie:nil];
}


#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"NodeViewController: Dealloc");
    
    
    //remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end