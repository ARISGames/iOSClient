//
//  ConversationController.m
//  ARIS
//
//  Created by Kevin Harris on 5/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConversationController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "NPC.h"
#import "Option.h"

static NSString * const CONVERSATION_CELL = @"conversation";

@implementation ConversationController
@synthesize tableView, webView, imageView, options, npc;

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
	self.title = npc.name;
	ARISAppDelegate *delegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[webView loadHTMLString:[self.npc description] baseURL:[NSURL URLWithString:delegate.appModel.baseAppURL]];
	// Need to load the image
	
    [super viewDidLoad];
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
	return npc.options.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)nibTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [nibTableView dequeueReusableCellWithIdentifier:CONVERSATION_CELL];	
	if(cell == nil) cell = [self getCellContentView:CONVERSATION_CELL];
	
	UILabel *optionText = (UILabel *)[cell viewWithTag:1];
	optionText.text = [[[npc options] objectAtIndex:[indexPath row]] text];
	
	return cell;
}

// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Option *selectedOption = [npc.options objectAtIndex:[indexPath row]];
	NSLog(@"Displaying option ``%@''", selectedOption.text);

	NSString *nodeURL = [NSString stringWithFormat:@"NodeViewer&event=faceTalk&npc_id=%d&node_id=%d", npc.npcID, selectedOption.nodeId];
	AppModel *appModel = [[[UIApplication sharedApplication] delegate] appModel];
	[[[self navigationController] view] removeFromSuperview];
	[appModel fetchNode:nodeURL];
}

- (NSString *)tableView:(UITableView *)view titleForHeaderInSection:(NSInteger)section {
	return @"Say…";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}
@end