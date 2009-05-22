//
//  NodeViewController.m
//  ARIS
//
//  Created by Kevin Harris on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NodeViewController.h"
#import "Option.h"

static NSString * const OPTION_CELL = @"option";

@implementation NodeViewController
@synthesize appModel, node, tableView, webView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }

    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self refreshView];
    [super viewDidLoad];
}

- (void) refreshView {
	CGRect frame = tableView.frame;
	CGRect textFrame = webView.frame;
	NSInteger deltaHeight = frame.size.height;
	
	if (node.numberOfOptions > 0 && node.numberOfOptions < 3) deltaHeight = 44 * node.numberOfOptions + 22;
	else if (node.numberOfOptions > 2) deltaHeight = 0;
	
	// TODO: Change these from magic cookies!
	frame.origin.y = 262 + deltaHeight;
	textFrame.size.height = 262 + deltaHeight;
	self.title = node.name;
	tableView.frame = frame;
	webView.frame = textFrame;
	
	// It does respond, but setContentToHTMLString: is apparently undocumented.
	[webView loadHTMLString:node.description baseURL:[NSURL URLWithString:appModel.baseAppURL]];
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
	return node.numberOfOptions;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [nibTableView dequeueReusableCellWithIdentifier:OPTION_CELL];	
	if(cell == nil) cell = [self getCellContentView:OPTION_CELL];
	
	UILabel *optionText = (UILabel *)[cell viewWithTag:1];
	optionText.text = [[node.options objectAtIndex:[indexPath row]] text];
		
	return cell;
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Option *selectedOption = [node.options objectAtIndex:[indexPath row]];
	NSLog(@"Displaying option ``%@''", selectedOption.text);
	
	// Here, we need to do one of two things:
	// 1) Put a new view controller on the stack
	// 2) Replace the currently running information with the new info

	NSString *nodeURL = [NSString stringWithFormat:@"NodeViewer&event=faceTalk&npc_id=-1&node_id=%d", selectedOption.nodeId];
	[appModel fetchNode:nodeURL];
/*	
	//Put the view on the screen
	[[self navigationController] pushViewController:itemDetailsViewController animated:YES];
*/	
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	return @"Options";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}


@end
