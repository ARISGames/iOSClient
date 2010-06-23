//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NodeViewController.h"
#import "NodeOption.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Media.h"
#import "AsyncImageView.h"

static NSString * const OPTION_CELL = @"option";

@implementation NodeViewController
@synthesize appModel, node, tableView, scrollView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
    }

    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"NodeViewController: Displaying Node '%@'",self.node.name);
	[self refreshView];
    [super viewDidLoad];
}

- (void) refreshView {
	//Update the server
	[appModel updateServerNodeViewed:node.nodeId];
	
	self.title = self.node.name;
		
	//Throw out an existing scroller subviews
	for(UIView *subview in [self.scrollView subviews]) {
		[subview removeFromSuperview];
	}
	
	Media *media = [appModel mediaForMediaId: self.node.mediaId];

	if ([media.type isEqualToString: @"Image"] && media.url) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		AsyncImageView* mediaImageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)]; 
		[mediaImageView loadImageFromMedia:media];
				
		//Add the image view to the scroller
		[scrollView addSubview:mediaImageView];
		imageSize = mediaImageView.frame.size;
	}
	else if (([media.type isEqualToString: @"Video"] || [media.type isEqualToString: @"Audio"]) && media.url) {
		NSLog(@"ItemDetailsViewController:  Video Layout Selected");
		
		//Add a button
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
		[button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
		[button setImage:[UIImage imageNamed:@"clickToPlay.png"] forState:UIControlStateNormal];
		[scrollView addSubview:button];	
		imageSize = button.frame.size;
		
		//Create movie player object
		mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
		[mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
	}
	
	else {
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", node.mediaId);
	}
	
	
	//Set Up Text Area
	int margin = 10;
	UILabel *nodeTextView = [[UILabel alloc] initWithFrame:CGRectMake(margin, imageSize.height + margin, 320 - (2 * margin),
																			 [self calculateTextHeight:self.node.text])];
	nodeTextView.text = self.node.text;
	nodeTextView.backgroundColor = [UIColor blackColor];
	nodeTextView.textColor = [UIColor whiteColor];
	nodeTextView.lineBreakMode = UILineBreakModeWordWrap;
	nodeTextView.numberOfLines = 0;
	[scrollView setContentSize:CGSizeMake(320, nodeTextView.frame.origin.y
										  + nodeTextView.frame.size.height)];
	//Add the text to the scroller
	[scrollView addSubview:nodeTextView];
	
	//Refresh the tableView
	[tableView reloadData];
}

-(IBAction)playMovie:(id)sender {
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}

- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
										name:MPMoviePlayerPlaybackDidFinishNotification
										object:mMoviePlayer];
	[self dismissMoviePlayerViewControllerAnimated];
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
	Node *newNode = [appModel fetchNode:newNodeId];
	self.node = newNode;
	[self refreshView];
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	return @"Options";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	// free our movie player
    [mMoviePlayer release];
	
    [super dealloc];
}


@end
