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
#import "AsyncImageView.h"
#import "webpageViewController.h"
#import "WebPage.h"

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
@synthesize node, tableView, scrollView,isLink,newHeight, hasMedia,spinner, mediaImageView,imageNewHeight,cellArray;
@synthesize continueButton;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieLoadStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:nil];
        self.isLink=NO;
        self.mediaImageView = [[AsyncImageView alloc]init];
        self.mediaImageView.delegate = self;
        self.spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }

    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    NSLog(@"NodeViewController: Displaying Node '%@'",self.node.name);
    self.title = self.node.name;
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent = YES;
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    webView.delegate = self;
    
    NSString *htmlDescription = [NSString stringWithFormat:kPlaqueDescriptionHtmlTemplate, self.node.text];
	[webView loadHTMLString:htmlDescription baseURL:nil];
    webView.backgroundColor =[UIColor clearColor];
    
    mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    mediaImageView.frame = CGRectMake(0, 0, 320, 200);
    self.imageNewHeight = mediaImageView.frame.size.height;

    //Create Image/AV Cell
    UITableViewCell *imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
    
    Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];

    //Check if the plaque has media
    if(([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"] || [media.type isEqualToString: @"Image"]) && media.url) hasMedia = YES;
    else hasMedia = NO;
    
    if(hasMedia){
        if(!mediaImageView.loaded)
        [mediaImageView loadImageFromMedia:media];
    }
    if ([media.type isEqualToString: @"Image"] && media.url) {
        NSLog(@"NodeVC: cellForRowAtIndexPath: This is an Image Plaque");
        if(!self.mediaImageView.loaded) {
            [self.mediaImageView loadImageFromMedia:media];
        }
        
        imageCell.backgroundView = mediaImageView;
        imageCell.backgroundView.layer.masksToBounds = YES;
        imageCell.backgroundView.layer.cornerRadius = 10.0;
        imageCell.userInteractionEnabled = NO;
    }
    else if(([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"])&& media.url)
    {
        NSLog(@"NodeVC: cellForRowAtIndexPath: This is an A/V Plaque");
        
        //Setup the Button
        mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        [mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        [mediaPlaybackButton setBackgroundImage:[UIImage imageNamed:@"clickToPlay.png"] forState:UIControlStateNormal];
        [mediaPlaybackButton setTitle:NSLocalizedString(@"PreparingToPlayKey",@"") forState:UIControlStateNormal];
        mediaPlaybackButton.enabled = NO;
        mediaPlaybackButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        imageSize = mediaPlaybackButton.frame.size;
        
        //Create movie player object
        mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];
        
        //Create thumbnail for button
        UIImage *videoThumb = [[mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionNearestKeyFrame] retain];
        //Resize thumb
        
        UIGraphicsBeginImageContext(CGSizeMake(320.0f, 240.0f));
        [videoThumb drawInRect:CGRectMake(0, 0, 320.0f, 240.0f)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
        UIGraphicsEndImageContext();
        [mediaPlaybackButton setBackgroundImage:newImage forState:UIControlStateNormal];
        
        imageCell.backgroundView = mediaPlaybackButton;
        imageCell.backgroundView.layer.masksToBounds = YES;
        imageCell.backgroundView.layer.cornerRadius = 10.0;
        imageCell.userInteractionEnabled = YES;
        imageCell.selectionStyle = UITableViewCellSelectionStyleNone;
        imageCell.frame = mediaPlaybackButton.frame;
    }

    
    //Create Image/AV Cell
    UITableViewCell *webCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
    
    webCell.userInteractionEnabled = NO;
    CGRect descriptionFrame = [webView frame];	
    descriptionFrame.origin.x = 15;
    descriptionFrame.origin.y = 15;
    [webView setFrame:descriptionFrame];
    webCell.backgroundView =webView;
    webCell.backgroundColor = [UIColor blackColor];


    //Create button cell
    UITableViewCell *buttonCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell3"];
    buttonCell.textLabel.text = @"Tap To Continue";
    buttonCell.textLabel.textAlignment = UITextAlignmentCenter;

    if(hasMedia)
    self.cellArray = [[NSArray alloc] initWithObjects:imageCell,webCell,buttonCell, nil];
    else
        self.cellArray = [[NSArray alloc] initWithObjects:webCell,buttonCell, nil];
 
}
-(void)viewWillAppear:(BOOL)animated{
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
   // self.isLink= NO;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //if (!self.isLink){
        float nHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
        self.newHeight = nHeight;
        CGRect descriptionFrame = [webView frame];	
        descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight+5);
        [webView setFrame:descriptionFrame];	

        [tableView reloadData];
    for(int x = 0; x < [webView.subviews count]; x ++){
        if([[webView.subviews objectAtIndex:x] isKindOfClass:[UIActivityIndicatorView class]])
            [[webView.subviews objectAtIndex:x] removeFromSuperview];
    }
   // }
    for(int x = 0; x < 2; x++){
    if([[(UITableViewCell *)[self.cellArray objectAtIndex:x] reuseIdentifier] isEqualToString:@"Cell2"]){
        [(UITableViewCell *)[self.cellArray objectAtIndex:x] setFrame:webView.frame];
    }
    }
    webLoaded = YES;
    if((webLoaded && imageLoaded && hasMedia) ||(webLoaded && !hasMedia))    [self.tableView reloadData];

}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(self.isLink) {
        webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
        WebPage *temp = [[WebPage alloc]init];
        temp.url = [[request URL]absoluteString];
        webPageViewController.webPage = temp;
        webPageViewController.delegate = self;
        [self.navigationController pushViewController:webPageViewController animated:NO];
        [webPageViewController release];
        
        return NO;
    }
    else{
           self.isLink = YES;
        [spinner startAnimating];
        spinner.center = webView.center;
        spinner.backgroundColor = [UIColor blackColor];
        [webView addSubview:spinner];
        return YES;}
}
- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId];
	
	
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:NO];
    ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent=NO;

}

- (IBAction)continueButtonTouchAction{
    NSLog(@"NodeViewController: Notify server of Node view and Dismiss view");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerNodeViewed:node.nodeId];
	
	
	//[self.view removeFromSuperview];
	[self dismissModalViewControllerAnimated:NO];
    if((node.nodeId == [AppModel sharedAppModel].currentGame.completeNodeId) && ([AppModel sharedAppModel].currentGame.completeNodeId != 0)){
        ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *tab;
        for(int i = 0;i < [appDelegate.tabBarController.customizableViewControllers count];i++)
        {
            tab = [[appDelegate.tabBarController.customizableViewControllers objectAtIndex:i] title];
            tab = [tab lowercaseString];
            
            if([tab isEqualToString:@"start over"])
            {
                appDelegate.tabBarController.selectedIndex = i;
            }
        }    }

}

-(IBAction)playMovie:(id)sender {
    [mMoviePlayer.moviePlayer play];
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}
-(void)imageFinishedLoading{
    NSLog(@"NodeVC: imageFinishedLoading with size: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    if(self.mediaImageView.image.size.width > 0){
    [self.mediaImageView setContentScaleFactor:(float)(320/self.mediaImageView.image.size.width)];
    self.mediaImageView.frame = CGRectMake(0, 0, 320, self.mediaImageView.contentScaleFactor*self.mediaImageView.image.size.height);
        self.imageNewHeight = self.mediaImageView.frame.size.height;
        NSLog(@"NEWSize: %f, %f",self.mediaImageView.frame.size.width,self.mediaImageView.frame.size.height);
    }
    imageLoaded = YES;
    [(UITableViewCell *)[self.cellArray objectAtIndex:0] setFrame:mediaImageView.frame];

    if((webLoaded && imageLoaded && hasMedia) ||(webLoaded && !hasMedia))   [self.tableView reloadData];

}
- (int) calculateTextHeight:(NSString *)text {
	CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 200000);
	CGSize calcSize = [text sizeWithFont:[UIFont systemFontOfSize:18.0]
					   constrainedToSize:frame.size lineBreakMode:UILineBreakModeWordWrap];
	frame.size = calcSize;
	frame.size.height += 0;
	NSLog(@"Found height of %f", frame.size.height);
	return frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	NSLog(@"NodeViewController: Dealloc");
    
	[mMoviePlayer release];
	[node release];
	[tableView release];
	[scrollView release];
	[mediaPlaybackButton release];
    [continueButton release];
	//[aWebView release];
	//remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	
    [super dealloc];
}

#pragma mark MPMoviePlayerController Notification Handlers


- (void)movieLoadStateChanged:(NSNotification*) aNotification{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];

	if( state & MPMovieLoadStateUnknown ) {
		NSLog(@"NodeViewController: Unknown Load State");
	}
	if( state & MPMovieLoadStatePlayable ) {
		NSLog(@"NodeViewController: Playable Load State");
        [mediaPlaybackButton setTitle:NSLocalizedString(@"TouchToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = YES;	
		//[self playMovie:nil];
	} 
	if( state & MPMovieLoadStatePlaythroughOK ) {
		NSLog(@"NodeViewController: Playthrough OK Load State");

	} 
	if( state & MPMovieLoadStateStalled ) {
		NSLog(@"NodeViewController: Stalled Load State");
	} 
		
}


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
    else [self playMovie:nil];
}






@end
