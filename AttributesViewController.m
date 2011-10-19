//
//  AttributesViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttributesViewController.h"
#import "AppServices.h"
#import "Media.h"
#import "AsyncImageView.h"
#import "AppModel.h"

@implementation AttributesViewController
@synthesize attributes,iconCache,attributesTable,pcImage,nameLabel,groupLabel,addGroupButton;
//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = @"Player";		
        self.tabBarItem.image = [UIImage imageNamed:@"playericon.png"];
        self.iconCache = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].attributes count]];
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewInventoryReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
        
    }
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	
	[self refresh];		
	self.nameLabel.text = [NSString stringWithFormat:@"Name: %@",[AppModel sharedAppModel].userName];
    self.groupLabel.text = @"Group: N/A";
	silenceNextServerUpdateCount = 0;
    pcImage.frame = CGRectMake(5, 5, 150, 150);
    if ([AppModel sharedAppModel].currentGame.pcMediaId != 0) {
		//Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
        if(!pcImage.loaded)
		[pcImage loadImageFromMedia: pcMedia];
        
	}
	else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"profile.png"]];	
    
    pcImage.contentMode = UIViewContentModeScaleAspectFill;
    NSLog(@"PCImage frame: x:%f y:%f w:%f h:%f",pcImage.frame.origin.x,pcImage.frame.origin.y,pcImage.frame.size.width,pcImage.frame.size.height);
}

-(void)refresh {
	[[AppServices sharedAppServices] fetchInventory];
}

-(void)refreshViewFromModel {
	NSLog(@"AttributesVC: Refresh View from Model");
   	
	
	self.attributes = [[AppModel sharedAppModel].attributes allValues];
	[attributesTable reloadData];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    
	
}
-(IBAction)groupButtonPressed {
  
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect CellFrame = CGRectMake(0, 0, 320, 60);
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 22, 170, 20);
	CGRect Label2Frame = CGRectMake(180, 22, 125, 20);
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
	lblTemp.tag = 1;
	//lblTemp.textColor = [UIColor whiteColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont boldSystemFontOfSize:24];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor]; 
	[cell.contentView addSubview:iconViewTemp];
	[iconViewTemp release];

    
	return cell;
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [attributes count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];	
	if(cell == nil) cell = [self getCellContentView:CellIdentifier];
	
	Item *item = [attributes objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;	
    lblTemp1.font = [UIFont boldSystemFontOfSize:24.0];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    lblTemp2.text = [NSString stringWithFormat:@"%d",item.qty];
    lblTemp2.textAlignment = UITextAlignmentRight;
	AsyncImageView *iconView = (AsyncImageView *)[cell viewWithTag:3];
    
    
	if (item.iconMediaId != 0) {
        Media *iconMedia;
        if([self.iconCache count] > indexPath.row){
            iconMedia = [self.iconCache objectAtIndex:indexPath.row];
        }
        else{
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId: item.iconMediaId];
            [self.iconCache  addObject:iconMedia];
        }
		[iconView loadImageFromMedia:iconMedia];
	}
	else {
		[iconView updateViewWithNewImage:[UIImage imageNamed:@"defaultImageIcon.png"]];
	}
    
    
    cell.textLabel.backgroundColor = [UIColor clearColor]; 
    cell.detailTextLabel.backgroundColor = [UIColor clearColor]; 
    
    if (indexPath.row % 2 == 0){  
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                           green:233.0/255.0  
                                                            blue:233.0/255.0  
                                                           alpha:1.0];  
    } else {  
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0  
                                                           green:200.0/255.0  
                                                            blue:200.0/255.0  
                                                           alpha:1.0];  
    } 
	cell.userInteractionEnabled = NO;
	return cell;
}



// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	

	
}

#pragma mark Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [iconCache release];
    [super dealloc];
}@end
