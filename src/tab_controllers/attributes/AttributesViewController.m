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

@interface AttributesViewController()
{
    id<AttributesViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation AttributesViewController

@synthesize attributes;
@synthesize iconCache;
@synthesize attributesTable;
@synthesize pcImage;
@synthesize nameLabel;
@synthesize groupLabel;
@synthesize addGroupButton;
@synthesize newAttrsSinceLastView;

- (id)initWithDelegate:(id<AttributesViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"AttributesViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"PlayerTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"123-id-card"];
        self.iconCache = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.attributesModel.currentAttributes count]];
        
		//register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyAcquiredAttributesAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyLostAttributesAvailable"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedAttributesGameNotificationSent"    object:nil];

    }
    return self;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitleSpace = @"   ";
    NSString *sectionTitle = [sectionTitleSpace stringByAppendingString:NSLocalizedString(@"AttributesAttributesTitleKey", @"")];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -14, tableView.frame.size.width, 50)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = sectionTitle;
    label.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 500)];
    [header addSubview:label];
    
    return header;
}

- (void)viewDidLoad
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
    label.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.7];
    [self.view insertSubview:label atIndex:1];

    self.pcImage.layer.cornerRadius = 10.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.nameLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"AttributesViewNameKey", @""), [AppModel sharedAppModel].player.username];
    self.groupLabel.text = NSLocalizedString(@"AttributesViewGroupKey", @"");
    if ([AppModel sharedAppModel].currentGame.pcMediaId != 0)
    {
		//Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
		[pcImage loadMedia:pcMedia];
	}
    else if([AppModel sharedAppModel].player.playerMediaId != 0)
    {
        //Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId];
		[pcImage loadMedia:pcMedia];
    }
    self.pcImage.contentMode = UIViewContentModeScaleAspectFill;
	//else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"profile.png"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

-(void)refresh
{
	[[AppServices sharedAppServices] fetchPlayerInventory];
    [self refreshViewFromModel];
}

-(void)refreshViewFromModel
{
	self.attributes = [AppModel sharedAppModel].currentGame.attributesModel.currentAttributes;
	[attributesTable reloadData];
}

-(IBAction)groupButtonPressed
{
    
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 22, 240, 20);
	CGRect Label2Frame = CGRectMake(70, 39, 240, 20);
    CGRect Label3Frame = CGRectMake(70, 5, 240, 20);
	UILabel *lblTemp;
	UIImageView *iconViewTemp;
	
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	
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
	lblTemp.font = [UIFont systemFontOfSize:11];
	//lblTemp.textColor = [UIColor darkGrayColor];
    lblTemp.textColor = [UIColor colorWithRed:30/255.0
                    green:30/255.0
                     blue:30/255.0
                    alpha:1];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[AsyncMediaImageView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:iconViewTemp];
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:Label3Frame];
	lblTemp.tag = 4;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	//lblTemp.textColor = [UIColor darkGrayColor];
    lblTemp.textColor = [UIColor colorWithRed:30/255.0
                                        green:30/255.0
                                         blue:30/255.0
                                        alpha:1];
	lblTemp.backgroundColor = [UIColor clearColor];
    //lblTemp.textAlignment = UITextAlignmentRight;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}

#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return 2;
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [attributes count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(cell == nil) cell = [self getCellContentView:@"Cell"];
    
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0
                                                       green:233.0/255.0
                                                        blue:233.0/255.0
                                                       alpha:.95];
    cell.backgroundView.layer.cornerRadius = 10.0;
    cell.contentView.layer.cornerRadius = 10.0;
    
	Item *item = [attributes objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;
    lblTemp1.font = [UIFont boldSystemFontOfSize:18.0];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    lblTemp2.text = item.text;
	AsyncMediaImageView *iconView = (AsyncMediaImageView *)[cell viewWithTag:3];
    
    UILabel *lblTemp3 = (UILabel *)[cell viewWithTag:4];
    if(item.qty > 1 || item.maxQty > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty];
    else
        lblTemp3.text = nil;
    iconView.hidden = NO;
    
	if (item.iconMediaId != 0) {
        Media *iconMedia;
        if([self.iconCache count] < indexPath.row){
            iconMedia = [self.iconCache objectAtIndex:indexPath.row];
            [iconView updateViewWithNewImage:[UIImage imageWithData:iconMedia.image]];
        }
        else{
            iconMedia = [[AppModel sharedAppModel] mediaForMediaId: item.iconMediaId];
            [self.iconCache  addObject:iconMedia];
            [iconView loadMedia:iconMedia];
        }
	}
    cell.userInteractionEnabled = NO;
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
