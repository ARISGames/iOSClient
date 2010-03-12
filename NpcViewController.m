//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "DialogViewController.h"
#import "Media.h"
#import "NpcViewController.h"
#import "NodeOption.h"
#import "Node.h"

static NSString * const OPTION_CELL = @"option";

@implementation NpcViewController
@synthesize appModel, npc, tableView, scrollView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
    }

    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"NpcViewController: Displaying Npc '%@'",self.npc.name);
	[self refreshView];
    [super viewDidLoad];
}

- (void) refreshView {
	
	self.title = self.npc.name;
	
	//Throw out an existing scroller subviews
	for(UIView *subview in [self.scrollView subviews]) {
		[subview removeFromSuperview];
	}
	
	//Setup the image view
	if (npc.mediaId > 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		Media *media = [appModel.mediaList objectForKey:[NSNumber numberWithInt:npc.mediaId]];
		NSLog(@"NodeViewController: Image URL: %@", media.url);
		NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:media.url]];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		UIImage* image = [[UIImage alloc] initWithData:imageData];
		UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 220)];
		imageView.image = image;
		
		//Add the image to the scroller
		[scrollView addSubview:imageView];
	}
	
	//Set Up Text Area
	int margin = 10;
	UILabel *npcTextView = [[UILabel alloc] initWithFrame:CGRectMake(margin, 220 + margin, 320 - (2 * margin),
																			 [self calculateTextHeight:self.npc.greeting])];
	npcTextView.text = self.npc.greeting;
	npcTextView.backgroundColor = [UIColor blackColor];
	npcTextView.textColor = [UIColor whiteColor];
	npcTextView.lineBreakMode = UILineBreakModeWordWrap;
	npcTextView.numberOfLines = 0;
	[scrollView setContentSize:CGSizeMake(320, npcTextView.frame.origin.y
										  + npcTextView.frame.size.height)];
	//Add the text to the scroller
	[scrollView addSubview:npcTextView];
	
	//Refresh the tableView
	[tableView reloadData];
	 
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
	return self.npc.numberOfOptions;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [nibTableView dequeueReusableCellWithIdentifier:OPTION_CELL];	
	if(cell == nil) cell = [self getCellContentView:OPTION_CELL];
	
	UILabel *optionText = (UILabel *)[cell viewWithTag:1];
	optionText.text = [[self.npc.options objectAtIndex:[indexPath row]] text];
		
	return cell;
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return;
	/*
	NodeOption *selectedOption = [self.npc.options objectAtIndex:[indexPath row]];
	NSLog(@"Displaying option ``%@''", selectedOption.text);
	
	//Just put the node view right on top of this view
	
	int newNodeId = selectedOption.nodeId;
	Node *newNode = [appModel fetchNode:newNodeId];
	

	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	DialogViewController *dialogViewController = [[DialogViewController alloc] initWithNibName:@"Dialog"
																						bundle:[NSBundle mainBundle]];
	[dialogViewController beginWithNPC:npc.npcId andNode:newNode];
	[appDelegate displayNearbyObjectView:dialogViewController]; // Might need to swap these for the display to work correctly
	 */
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	return @"Conversations";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
