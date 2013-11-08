//
//  InventoryTradeViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InventoryTradeViewController.h"
#import "ARISAlertHandler.h"

@interface InventoryTradeViewController()<ARISMediaViewDelegate>
{
    id<InventoryTradeViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation InventoryTradeViewController

@synthesize tradeTableView;
@synthesize inventory;
@synthesize itemsToTrade;
@synthesize iconCache;
@synthesize mediaCache;

- (id) initWithDelegate:(id<InventoryTradeViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"InventoryTradeViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryTradeViewTitleKey",@"");
        self.iconCache  = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.mediaCache = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *tempCopy = [AppModel sharedAppModel].currentGame.inventoryModel.currentInventory;
	self.inventory = [[NSMutableArray alloc] init];
    for(int i = 0; i < [tempCopy count]; i++)
    {
        if(((Item *)[tempCopy objectAtIndex:i]).tradeable)
            [self.inventory addObject:[((Item *)[tempCopy objectAtIndex:i]) copy]];
    } 
    self.itemsToTrade = [[NSMutableArray alloc] init];
    self.tradeTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.tradeTableView reloadData];
    
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTouchAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tradeTableView reloadData];
}

- (void) goBackToInventory
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) backButtonTouchAction:(id)sender
{
	NSLog(@"ItemTradeViewController: Dismiss Item Trade View");
	[self goBackToInventory];	
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{
	return [[RoundedTableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:cellIdentifier forFile:@"InventoryTradeViewController"];
} 

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return [self.itemsToTrade count];
	return [self.inventory count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"InventoryTradeViewToTradeKey", @"");
    return NSLocalizedString(@"InventoryViewTitleKey",@""); 
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    RoundedTableViewCell *cell = (RoundedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[RoundedTableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier forFile:@"InventoryTradeViewController.m"];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.row == 0)                                                      [cell drawRoundTop];
    if(indexPath.row == [tableView  numberOfRowsInSection:indexPath.section]-1) [cell drawRoundBottom];
    
	Item *item;
	if(indexPath.section == 0) item = [self.itemsToTrade objectAtIndex: [indexPath row]];
	else item = [self.inventory objectAtIndex: [indexPath row]];
    
	cell.lbl1.text = item.name;	
    cell.lbl1.font = [UIFont boldSystemFontOfSize:18.0];
    cell.lbl2.text = item.idescription;
    if(item.qty >1 && item.weight > 1)
         cell.lbl4.text = [NSString stringWithFormat:@"%@: %d, %@: %d",NSLocalizedString(@"x", @""),item.qty,NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.weight > 1)
        cell.lbl4.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.qty > 1)
        cell.lbl4.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"x", @""),item.qty];
    else
        cell.lbl4.text = nil;
    cell.iconView.hidden = NO;
    
    Media *media;
    if(item.mediaId != 0)
    {
        if([self.mediaCache count] > indexPath.row)
            media = [self.mediaCache objectAtIndex:indexPath.row];
        else
        {
            media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId ofType:nil];
            if(media) [self.mediaCache  addObject:media];
        }
	}
    
	if(item.iconMediaId != 0)
    {
        if([self.iconCache count] <= indexPath.row)
            [self.iconCache  addObject:[[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:nil]];
        [cell.iconView refreshWithFrame:cell.iconView.frame media:[self.iconCache objectAtIndex:indexPath.row] mode:ARISMediaDisplayModeAspectFit delegate:self];
	}
	else
    {
		if([media.type isEqualToString:@"PHOTO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultImageIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
		if([media.type isEqualToString:@"AUDIO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultAudioIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
		if([media.type isEqualToString:@"VIDEO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultVideoIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    }
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        Item *selectedItem = [self.itemsToTrade objectAtIndex:[indexPath row]];
        if(((Item *)[self.itemsToTrade objectAtIndex:[indexPath row]]).qty > 1) ((Item *)[self.itemsToTrade objectAtIndex:[indexPath row]]).qty--;
        else [self.itemsToTrade removeObjectAtIndex:[indexPath row]];
        
        NSUInteger result = [self.inventory indexOfObjectPassingTest:^ (id arrayItem, NSUInteger idx, BOOL *stop)
            {
                if(((Item *)arrayItem).itemId == selectedItem.itemId)
                    return YES;
                else
                    return NO;
            }];
        
        if(result == NSNotFound)
        {
            Item *itemCopy = [selectedItem copy];
            itemCopy.qty = 1;
            [self.inventory addObject:itemCopy];
        }
        else ((Item *)[self.inventory objectAtIndex:result]).qty++;
    }
    else
    {
        Item *selectedItem = [self.inventory objectAtIndex:[indexPath row]];
        if(selectedItem.qty > 1) selectedItem.qty--;
        else [self.inventory removeObjectAtIndex:[indexPath row]];
        
        NSUInteger result = [self.itemsToTrade indexOfObjectPassingTest:
                             ^ (id arrayItem, NSUInteger idx, BOOL *stop)
                             {   
                                 return (BOOL)(((Item *)arrayItem).itemId == selectedItem.itemId);
                             }];
        
        if(result == NSNotFound)
        {
            Item *itemCopy = [selectedItem copy];
            itemCopy.qty = 1;
            [self.itemsToTrade addObject:itemCopy];
        }
        else ((Item *)[self.itemsToTrade objectAtIndex:result]).qty++;
    }
    
    [self.tradeTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange (0, 2)] withRowAnimation:UITableViewRowAnimationFade];
    
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
}

- (NSString *)generateTransactionJSON
{
    NSString *giftsJSON = [NSString stringWithFormat:@"{\"gameId\":%d,\"playerId\":%d,\"items\":[",[AppModel sharedAppModel].currentGame.gameId, [AppModel sharedAppModel].player.playerId];
    for(int i = 0; i < itemsToTrade.count; i++)
    {
        giftsJSON = [NSString stringWithFormat:@"%@{\"item_id\":%d,\"qtyDelta\":%d}",giftsJSON,((Item *)[itemsToTrade objectAtIndex:i]).itemId, ((Item *)[itemsToTrade objectAtIndex:i]).qty];
        if(i+1 < itemsToTrade.count)
            giftsJSON = [NSString stringWithFormat:@"%@,",giftsJSON];
    }
    giftsJSON = [NSString stringWithFormat:@"%@]}",giftsJSON];
    NSLog(@"%@",giftsJSON);
    return giftsJSON;
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
