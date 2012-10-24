//
//  TitleAndDecriptionFormViewController.m
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import "TitleAndDecriptionFormViewController.h"
#import "NoteDetailsViewController.h"
#import "ItemDetailsViewController.h"

@implementation TitleAndDecriptionFormViewController

@synthesize formTableView;
@synthesize titleField;
@synthesize descriptionField;
@synthesize delegate, item;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		self.title = NSLocalizedString(@"TitleAndDescriptionTitleKey",@"");
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    UITextField *titleFieldAlloc = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 290, 30) ];
	self.titleField = titleFieldAlloc;
	self.titleField.placeholder = NSLocalizedString(@"TitleAndDescriptionTitlePrompt",@"");
	self.titleField.returnKeyType =  UIReturnKeyDone;
	self.titleField.delegate = self;
    self.titleField.text = self.item.name;
    UITextField *descriptionFieldAlloc = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 290, 30) ];
	self.descriptionField = descriptionFieldAlloc;
	self.descriptionField.placeholder = NSLocalizedString(@"TitleAndDescriptionDescriptionPrompt",@"");;
	self.descriptionField.returnKeyType =  UIReturnKeyDone;
	self.descriptionField.delegate = self;
    self.descriptionField.text = self.item.description;
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SaveKey",@"") style: 
							   UIBarButtonItemStyleDone target:self action:@selector(notifyDelegate)];

	self.navigationItem.rightBarButtonItem = button;
	
	[self.titleField becomeFirstResponder];
	NSLog(@"TitleAndDescriptionForm: Loaded");
}

-(void) notifyDelegate{
	NSLog(@"Done. Notifiying Delegate");
	[delegate performSelector:@selector(titleAndDescriptionFormDidFinish:) withObject:self];	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
 -(BOOL)shouldAutorotate{
 return YES;
 }
 
 -(NSInteger)supportedInterfaceOrientations{
 NSInteger mask = 0;
 if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
 mask |= UIInterfaceOrientationMaskLandscapeLeft;
 if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
 mask |= UIInterfaceOrientationMaskLandscapeRight;
 if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
 mask |= UIInterfaceOrientationMaskPortrait;
 if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
 mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
 return mask;
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




#pragma mark -
#pragma mark UITextField delegae

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"TitleAndDescriptionVC: textFieldShouldReturn");
	[self notifyDelegate];
	
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if([self.item.type isEqualToString:@"NOTE"]){
        return 1;
    }
    return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSLog(@"TitleAndDescriptionFormViewController:Fetching a cell");
	
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	//General Cell Settings
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	if ([indexPath row] == 0) { 
		[cell.contentView addSubview:titleField];
	}
	else {
		[cell.contentView addSubview:descriptionField];
	}
	

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == 0) return 60;
	else return 100;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}




@end
