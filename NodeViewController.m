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

static NSString * const OPTION_CELL = @"option";

@implementation NodeViewController
@synthesize node, tableView, scrollView;
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
    }

    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"NodeViewController: Displaying Node '%@'",self.node.name);
	ARISAppDelegate *appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.modalPresent = YES;
    
    [self refreshView];
    [super viewDidLoad];
}

- (void) refreshView {
	self.title = self.node.name;
	int topMargin = 10;
	
	//Throw out an existing scroller subviews
	for(UIView *subview in [self.scrollView subviews]) {
		[subview removeFromSuperview];
	}
	
	Media *media = [[AppModel sharedAppModel] mediaForMediaId: self.node.mediaId];

	if ([media.type isEqualToString: @"Image"] && media.url) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		AsyncImageView* mediaImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)]; 
		[mediaImageView loadImageFromMedia:media];
				
		//Add the image view to the scroller
		[scrollView addSubview:mediaImageView];
		imageSize = mediaImageView.frame.size;
		[mediaImageView release];
	}
	else if (([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"]) && media.url) {
		NSLog(@"ItemDetailsViewController:  Video Layout Selected");
		
		//Setup the Button
		mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 295)];
		[mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
		[mediaPlaybackButton setBackgroundImage:[UIImage imageNamed:@"clickToPlay.png"] forState:UIControlStateNormal];
		[mediaPlaybackButton setTitle:NSLocalizedString(@"PreparingToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = NO;
		mediaPlaybackButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
		[mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
		[scrollView addSubview:mediaPlaybackButton];	
		
		imageSize = mediaPlaybackButton.frame.size;
		topMargin = 50; 

		//Create movie player object
		mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
		[mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
		mMoviePlayer.moviePlayer.shouldAutoplay = NO;
		[mMoviePlayer.moviePlayer prepareToPlay];
	}
	
	else {
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", node.mediaId);
	}
	
	
	//Set Up Text Area
	int sideMargin = 10;
	UILabel *nodeTextView = [[UILabel alloc] initWithFrame:CGRectMake(sideMargin, imageSize.height + topMargin, 320 - (2 * sideMargin),
																			 [self calculateTextHeight:self.node.text])];
	nodeTextView.text = self.node.text;
	nodeTextView.backgroundColor = [UIColor blackColor];
	nodeTextView.textColor = [UIColor whiteColor];
	nodeTextView.lineBreakMode = UILineBreakModeWordWrap;
	nodeTextView.numberOfLines = 0;
	[scrollView setContentSize:CGSizeMake(320, nodeTextView.frame.origin.y
										  + nodeTextView.frame.size.height + continueButton.frame.size.height+40)];
	//Add the text to the scroller
	[scrollView addSubview:nodeTextView];
	[nodeTextView release];
	
    //Create continue button
    [continueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateNormal];
	[continueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateHighlighted];	
    [continueButton addTarget:self action:@selector(continueButtonTouchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect continueButtonFrame = [continueButton frame];	
    if(scrollView.contentSize.height > scrollView.frame.size.height)
	continueButtonFrame.origin = CGPointMake(continueButtonFrame.origin.x, scrollView.contentSize.height-continueButton.frame.size.height-20);
    else
    continueButtonFrame.origin = CGPointMake(continueButtonFrame.origin.x, scrollView.frame.size.height-continueButton.frame.size.height-20);
	[continueButton setFrame:continueButtonFrame];
    [scrollView addSubview:continueButton];
    
	//Refresh the tableView
	[tableView reloadData];
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

- (IBAction)continueButtonTouchAction:(id) sender{
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
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
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
	
	//remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:mMoviePlayer];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerLoadStateDidChangeNotification
												  object:mMoviePlayer];	
	
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
	} 
	if( state & MPMovieLoadStatePlaythroughOK ) {
		NSLog(@"NodeViewController: Playthrough OK Load State");
		[mediaPlaybackButton setTitle:NSLocalizedString(@"TouchToPlayKey",@"") forState:UIControlStateNormal];
		mediaPlaybackButton.enabled = YES;	
		[self playMovie:nil];
	} 
	if( state & MPMovieLoadStateStalled ) {
		NSLog(@"NodeViewController: Stalled Load State");
	} 
		
}


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}





/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark PickerViewDelegate selectors

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect cellFrame = CGRectMake(0, 0, 300, 45);
	CGRect label1Frame = CGRectMake(10, 10, 290, 30);
	UILabel *lblTemp;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:cellFrame 
													reuseIdentifier:cellIdentifier] autorelease];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:label1Frame];
	lblTemp.tag = 1;
	lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.node.numberOfOptions;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [nibTableView dequeueReusableCellWithIdentifier:OPTION_CELL];	
	if(cell == nil) cell = [self getCellContentView:OPTION_CELL];
	
	UILabel *optionText = (UILabel *)[cell viewWithTag:1];
	optionText.text = [[self.node.options objectAtIndex:[indexPath row]] text];
		
	return cell;
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NodeOption *selectedOption = [self.node.options objectAtIndex:[indexPath row]];
	NSLog(@"Displaying option ``%@''", selectedOption.text);
	
	int newNodeId = selectedOption.nodeId;
	Node *newNode = [[AppModel sharedAppModel] nodeForNodeId: newNodeId];
	self.node = newNode;
	[self refreshView];
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	return @"Options";
}




@end
