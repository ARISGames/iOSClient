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
#import "ARISMediaView.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemViewController.h"
#import "UIColor+ARISColors.h"

@interface AttributesViewController() <ARISMediaViewDelegate,UITableViewDataSource,UITableViewDataSource>
{
	UITableView *attributesTable;
	NSArray *attributes;
    NSMutableArray *iconCache;
    ARISMediaView *pcImage;
    id<AttributesViewControllerDelegate> __unsafe_unretained delegate;
}

@property(nonatomic) IBOutlet UITableView *attributesTable;
@property(nonatomic) NSArray *attributes;
@property(nonatomic) NSMutableArray *iconCache;
@property(nonatomic) IBOutlet ARISMediaView	*pcImage;
@property(nonatomic) int newAttrsSinceLastView;

@end

@implementation AttributesViewController

@synthesize attributes;
@synthesize iconCache;
@synthesize attributesTable;
@synthesize pcImage;
@synthesize newAttrsSinceLastView;

- (id)initWithDelegate:(id<AttributesViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"AttributesViewController" bundle:nil delegate:d])
    {
        self.tabID = @"PLAYER";
        delegate = d;
        
        self.title = NSLocalizedString(@"PlayerTitleKey",@"");
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"idCardTabBarSelected"] withFinishedUnselectedImage:[UIImage imageNamed:@"idCardTabBarUnselected"]];        
        
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
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textColor = [UIColor ARISColorText];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = sectionTitle;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 500)];
    [header addSubview:label];
    
    return header;
}

- (void) viewDidLoad
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 1000)];
    label.backgroundColor = [UIColor ARISColorTranslucentBlack];
    [self.view insertSubview:label atIndex:1];

    self.pcImage.layer.cornerRadius = 10.0;
}

- (void) viewWillAppear:(BOOL)animated
{
    if([AppModel sharedAppModel].currentGame.pcMediaId != 0)
        [pcImage refreshWithFrame:pcImage.frame media:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFill delegate:self];
    else if([AppModel sharedAppModel].player.playerMediaId != 0)
        [pcImage refreshWithFrame:pcImage.frame media:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFill delegate:self];
	else [pcImage refreshWithFrame:pcImage.frame image:[UIImage imageNamed:@"profile.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
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

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{
	CGRect IconFrame = CGRectMake(5, 5, 50, 50);
	CGRect Label1Frame = CGRectMake(70, 22, 240, 20);
	CGRect Label2Frame = CGRectMake(70, 39, 240, 20);
    CGRect Label3Frame = CGRectMake(70, 5, 240, 20);
	UILabel *lblTemp;
	ARISMediaView *iconViewTemp;
	
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	
	//Setup Cell
	UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
    transparentBackground.backgroundColor = [UIColor clearColor];
    cell.backgroundView = transparentBackground;
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:Label1Frame];
	lblTemp.tag = 1;
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Initialize Label with tag 2.
	lblTemp = [[UILabel alloc] initWithFrame:Label2Frame];
	lblTemp.tag = 2;
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
	
	//Init Icon with tag 3
	iconViewTemp = [[ARISMediaView alloc] initWithFrame:IconFrame];
	iconViewTemp.tag = 3;
	iconViewTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:iconViewTemp];
    
    //Init Icon with tag 4
    lblTemp = [[UILabel alloc] initWithFrame:Label3Frame];
	lblTemp.tag = 4;
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
	lblTemp.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [attributes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if(cell == nil) cell = [self getCellContentView:@"Cell"];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor ARISColorTranslucentWhite];
    cell.backgroundView.layer.cornerRadius = 10.0;
    cell.contentView.layer.cornerRadius = 10.0;
    
	Item *item = [attributes objectAtIndex: [indexPath row]];
	
	UILabel *lblTemp1 = (UILabel *)[cell viewWithTag:1];
	lblTemp1.text = item.name;
    lblTemp1.font = [UIFont boldSystemFontOfSize:18.0];
    
    UILabel *lblTemp2 = (UILabel *)[cell viewWithTag:2];
    lblTemp2.text = item.idescription;
	ARISMediaView *iconView = (ARISMediaView *)[cell viewWithTag:3];
    
    UILabel *lblTemp3 = (UILabel *)[cell viewWithTag:4];
    if(item.qty > 1 || item.maxQty > 1)
        lblTemp3.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty];
    else
        lblTemp3.text = nil;
    iconView.hidden = NO;
    
	if(item.iconMediaId != 0)
    {
        if([self.iconCache count] <= indexPath.row)
            [self.iconCache addObject:[[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:@"PHOTO"]];
        [iconView refreshWithFrame:iconView.frame media:[self.iconCache objectAtIndex:indexPath.row] mode:ARISMediaDisplayModeAspectFit delegate:self];
	}
    cell.userInteractionEnabled = NO;
	return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"AttributesAttributesTitleKey", @"");
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

@end
