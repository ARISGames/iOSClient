//
//  AttributesViewController.m
//  ARIS
//
//  Created by Brian Thiel on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AttributesViewController.h"
#import "User.h"
#import "Media.h"
#import "ARISMediaView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "ARISAppDelegate.h"
#import "Item.h"
#import "ItemViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AttributesViewController() <ARISMediaViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
	UITableView *attributesTable;
	NSArray *attributes;
    NSMutableArray *iconCache;
    ARISMediaView *pcImage;
    BOOL hasAppeared;
    id<AttributesViewControllerDelegate> __unsafe_unretained delegate;
    UILabel *nameLabel;
}

@property (nonatomic) UITableView *attributesTable;
@property (nonatomic) NSArray *attributes;
@property (nonatomic) NSMutableArray *iconCache;
@property (nonatomic) ARISMediaView *pcImage;
@property (nonatomic) int newAttrsSinceLastView;

@end

@implementation AttributesViewController

@synthesize attributes;
@synthesize iconCache;
@synthesize attributesTable;
@synthesize pcImage;
@synthesize newAttrsSinceLastView;

- (id) initWithDelegate:(id<AttributesViewControllerDelegate>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"PLAYER";
        self.tabIconName = @"id_card";
        hasAppeared = NO;
        delegate = d;
        
        self.title = NSLocalizedString(@"PlayerTitleKey",@"");
        self.iconCache = [[NSMutableArray alloc] initWithCapacity:10];
        
		//register for notifications
  _ARIS_NOTIF_LISTEN_(@"NewlyAcquiredAttributesAvailable",self,@selector(refreshViewFromModel),nil);
  _ARIS_NOTIF_LISTEN_(@"NewlyLostAttributesAvailable",self,@selector(refreshViewFromModel),nil);
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    int playerImageWidth = 200;
    CGRect playerImageFrame = CGRectMake((self.view.bounds.size.width / 2) - (playerImageWidth / 2), 64, playerImageWidth, 200);
    pcImage = [[ARISMediaView alloc] initWithFrame:playerImageFrame delegate:self];
    [pcImage setDisplayMode:ARISMediaDisplayModeAspectFit];
    
    
    if(_MODEL_PLAYER_.media_id != 0)
        [pcImage setMedia:[_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id]];
    else [pcImage setImage:[UIImage imageNamed:@"profile.png"]];
    
    [self.view addSubview:pcImage];
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(-1, pcImage.frame.origin.y + pcImage.frame.size.height + 20, self.view.bounds.size.width + 1, 30);
    
    
    nameLabel.text = _MODEL_PLAYER_.user_name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nameLabel.layer.borderWidth = 1.0f;
    
    
    [self.view addSubview:nameLabel];
    
    self.attributesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,nameLabel.frame.origin.y + nameLabel.frame.size.height,self.view.bounds.size.width,self.view.bounds.size.height)];
    self.attributesTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.attributesTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.attributesTable.delegate = self;
    self.attributesTable.dataSource = self;
    self.attributesTable.backgroundColor = [UIColor clearColor];
    self.attributesTable.opaque = NO;
    self.attributesTable.backgroundView = nil;
    
    [self.view addSubview:self.attributesTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

-(void)refresh
{
    [self refreshViewFromModel];
}

-(void) refreshViewFromModel
{
	[attributesTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return attributes.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
    
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.backgroundView.opaque = NO;
    
    cell.contentView.backgroundColor = [UIColor ARISColorTranslucentWhite];
    cell.contentView.opaque = NO;
    
    cell.userInteractionEnabled = NO;
    
	Item *item = [attributes objectAtIndex: [indexPath row]];
    
	UILabel *lblTemp;
	lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)];
	lblTemp.backgroundColor = [UIColor clearColor];
    lblTemp.font = [UIFont boldSystemFontOfSize:18.0];
	lblTemp.text = item.name;
	[cell.contentView addSubview:lblTemp];
	
	lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 20)];
	lblTemp.backgroundColor = [UIColor clearColor];
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
    lblTemp.text = item.desc;
	[cell.contentView addSubview:lblTemp];
	
	ARISMediaView *iconViewTemp;
	if(item.icon_media_id != 0)
    {
        if(self.iconCache.count <= indexPath.row)
            [self.iconCache addObject:[_MODEL_MEDIA_ mediaForId:item.icon_media_id]];
        iconViewTemp = [[ARISMediaView alloc] initWithFrame:CGRectMake(5, 5, 50, 50) delegate:self];
        [iconViewTemp setDisplayMode:ARISMediaDisplayModeAspectFit];
        [iconViewTemp setMedia:[self.iconCache objectAtIndex:indexPath.row]];
	}
	[cell.contentView addSubview:iconViewTemp];
    
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 20)];
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
	lblTemp.backgroundColor = [UIColor clearColor];
    lblTemp.textAlignment = NSTextAlignmentRight;
    if([_MODEL_ITEMS_ qtyOwnedForItem:item.item_id] > 1 || item.max_qty_in_inventory > 1)
        lblTemp.text = [NSString stringWithFormat:@"%d",[_MODEL_ITEMS_ qtyOwnedForItem:item.item_id]];
    else
        lblTemp.text = nil;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

@end
