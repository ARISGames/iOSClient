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
#import "AsyncMediaImageView.h"
#import "AppModel.h"

@implementation AttributesViewController
@synthesize attributes,iconCache,attributesTable,pcImage,nameLabel,groupLabel,addGroupButton;
//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"PlayerTitleKey",@"");	
        self.tabBarItem.image = [UIImage imageNamed:@"123-id-card"];
        NSMutableArray *iconCacheAlloc = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].attributes count]];
        self.iconCache = iconCacheAlloc;
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
    self.pcImage.layer.cornerRadius = 10.0;
}

- (void)viewDidAppear:(BOOL)animated {
	
	[self refresh];		
	self.nameLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"AttributesViewNameKey", @""), [AppModel sharedAppModel].userName];
    self.groupLabel.text = NSLocalizedString(@"AttributesViewGroupKey", @"");
	silenceNextServerUpdateCount = 0;
    if ([AppModel sharedAppModel].currentGame.pcMediaId != 0) {
		//Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
		[pcImage loadImageFromMedia: pcMedia];
        
	}
	//else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"profile.png"]];	

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
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier];
	
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
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont boldSystemFontOfSize:24];
	lblTemp.textColor = [UIColor darkGrayColor];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncMediaImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor]; 
	[cell.contentView addSubview:iconViewTemp];

    
	return cell;
}


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // return 2;
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*if(section == 0){
        return 1;
    }
    if(section == 1)*/
    if([attributes count] == 0) return 1;
	return [attributes count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];	
		
    //if(indexPath.section == 1){
        if(cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];

    if([attributes count] > 0){
	Item *item = [attributes objectAtIndex: [indexPath row]];
	
	
        AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];
        
        
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

        cell.textLabel.text = item.name;
        if(item.qty > 1){
        cell.detailTextLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", item.qty];
        }
        cell.imageView.image = iconView.image;
    }
    else{
        cell.textLabel.text = NSLocalizedString(@"AttributesNoCurrentlyKey", @"");
    }
        cell.userInteractionEnabled = NO;
        
   // }
    /*else{
        if(cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

        cell.userInteractionEnabled = YES;
        cell.textLabel.text = @"No Group";
        cell.detailTextLabel.text = @"Tap to Find One";
    }*/
	return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    //if(section==0)return  @"Group";
       // else 
            return NSLocalizedString(@"AttributesAttributesTitleKey", @"");
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

@end
