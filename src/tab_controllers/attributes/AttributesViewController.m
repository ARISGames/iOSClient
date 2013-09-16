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

@interface AttributesViewController() <ARISMediaViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
	UITableView *attributesTable;
	NSArray *attributes;
    NSMutableArray *iconCache;
    ARISMediaView *pcImage;
    BOOL hasAppeared;
    id<AttributesViewControllerDelegate> __unsafe_unretained delegate;
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
        self.iconCache = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.attributesModel.currentAttributes count]];
        
		//register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyAcquiredAttributesAvailable" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromModel)   name:@"NewlyLostAttributesAvailable"     object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementBadge)         name:@"NewlyChangedAttributesGameNotificationSent"    object:nil];
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(hasAppeared) return;
    hasAppeared = YES;
    
    if([AppModel sharedAppModel].currentGame.pcMediaId != 0)
        pcImage = [[ARISMediaView alloc] initWithFrame:self.view.bounds media:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFill delegate:self];
    else if([AppModel sharedAppModel].player.playerMediaId != 0)
        pcImage = [[ARISMediaView alloc] initWithFrame:self.view.bounds media:[[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:@"PHOTO"] mode:ARISMediaDisplayModeAspectFill delegate:self];
	else pcImage = [[ARISMediaView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"profile.png"] mode:ARISMediaDisplayModeAspectFill delegate:self];
    [self.view addSubview:pcImage];
    
    UIView *bg = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    bg.backgroundColor = [UIColor ARISColorTranslucentBlack];
    [self.view addSubview:bg];
    
    self.attributesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height)];
    self.attributesTable.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.attributesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
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
	[[AppServices sharedAppServices] fetchPlayerInventory];
    [self refreshViewFromModel];
}

-(void)refreshViewFromModel
{
	self.attributes = [AppModel sharedAppModel].currentGame.attributesModel.currentAttributes;
	[attributesTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [attributes count];
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
	lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 22, 240, 20)];
	lblTemp.backgroundColor = [UIColor clearColor];
    lblTemp.font = [UIFont boldSystemFontOfSize:18.0];
	lblTemp.text = item.name;
	[cell.contentView addSubview:lblTemp];
	
	lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 39, 240, 20)];
	lblTemp.backgroundColor = [UIColor clearColor];
	lblTemp.font = [UIFont systemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
    lblTemp.text = item.idescription;
	[cell.contentView addSubview:lblTemp];
	
	ARISMediaView *iconViewTemp;
	if(item.iconMediaId != 0)
    {
        if([self.iconCache count] <= indexPath.row)
            [self.iconCache addObject:[[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:@"PHOTO"]];
        iconViewTemp = [[ARISMediaView alloc] initWithFrame:CGRectMake(5, 5, 50, 50) media:[self.iconCache objectAtIndex:indexPath.row] mode:ARISMediaDisplayModeAspectFit delegate:self];
	}
	[cell.contentView addSubview:iconViewTemp];
    
    lblTemp = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 240, 20)];
	lblTemp.font = [UIFont boldSystemFontOfSize:11];
	lblTemp.textColor = [UIColor ARISColorDarkGray];
	lblTemp.backgroundColor = [UIColor clearColor];
    if(item.qty > 1 || item.maxQty > 1)
        lblTemp.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"QuantityKey", @""),item.qty];
    else
        lblTemp.text = nil;
	[cell.contentView addSubview:lblTemp];
    
	return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

@end
