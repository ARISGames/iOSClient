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
@synthesize isConnectedToBump;

- (id) initWithDelegate:(id<InventoryTradeViewControllerDelegate>)d
{
    if(self = [super initWithNibName:@"InventoryTradeViewController" bundle:nil])
    {
        delegate = d;
        
        self.title = NSLocalizedString(@"InventoryTradeViewTitleKey",@"");
        self.iconCache  = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.mediaCache = [[NSMutableArray alloc] initWithCapacity:[[AppModel sharedAppModel].currentGame.inventoryModel.currentInventory count]];
        self.isConnectedToBump = NO;
    }
    return self;
}

- (void) configureBump
{
    [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:@"Connecting to bump..."];
    NSLog(@"ConfiguringBump");
    [BumpClient configureWithAPIKey:@"4ff1c7a0c2a84bb9938dafc3a1ac770c" andUserID:[[UIDevice currentDevice] name]];
    [[BumpClient sharedClient] connect];
    
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel) {
        NSLog(@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]); 
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel) {
        NSLog(@"Channel with %@ confirmed.", [[BumpClient sharedClient] userIDForChannel:channel]);
        [[BumpClient sharedClient] sendData:[[self generateTransactionJSON] dataUsingEncoding:NSUTF8StringEncoding]
                                  toChannel:channel];
    }];
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data)
    {
        int theirGameId;
        int gameIdStartPos;
        int gameIdEndPos;
        int theirPlayerId;
        int playerIdStartPos;
        int playerIdEndPos;
        NSRange charFinder;

        NSString *receipt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//[NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
        NSLog(@"Data received:\n%@",receipt);
        charFinder = [receipt rangeOfString:@"\"gameId\":"];
        if(charFinder.location != NSNotFound)
        {
            gameIdStartPos = charFinder.location+9;
            charFinder = [[receipt substringFromIndex:gameIdStartPos] rangeOfString:@","];
            gameIdEndPos = gameIdStartPos+charFinder.location+1;
            
            charFinder = [receipt rangeOfString:@"\"playerId\":"];
            playerIdStartPos = charFinder.location+11;
            charFinder = [[receipt substringFromIndex:gameIdStartPos] rangeOfString:@","];
            playerIdEndPos = playerIdStartPos+charFinder.location+1;
            
            theirGameId = [[receipt substringWithRange:NSMakeRange(gameIdStartPos,gameIdEndPos-gameIdStartPos)] intValue];
            theirPlayerId = [[receipt substringWithRange:NSMakeRange(playerIdStartPos,playerIdEndPos-playerIdStartPos)] intValue];
            
            if(theirGameId == [AppModel sharedAppModel].currentGame.gameId)
            {
                if(theirPlayerId > [AppModel sharedAppModel].player.playerId)
                {
                    //You have the lower player Id. Commit the trade.
                    [[AppServices sharedAppServices] commitInventoryTrade:[AppModel sharedAppModel].currentGame.gameId fromMe:[AppModel sharedAppModel].player.playerId toYou:theirPlayerId giving:[self generateTransactionJSON] receiving:receipt];
                }
                else
                {
                    //Do nothing- let lowest playerId Commit trade.
                    ; 
                }
                for(int i = 0; i < [self.itemsToTrade count]; i++)
                {
                    //Decrement qty of traded items
                    Item *itemDelta = (Item *)[self.itemsToTrade objectAtIndex:i];
                    [[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:itemDelta qtyToRemove:itemDelta.qty];
                }
                [delegate tradeDidComplete];
                [self goBackToInventory];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bump Error" message:[NSString stringWithFormat:@"You must both be in the same game to trade- %d",theirGameId] delegate:nil cancelButtonTitle:@"K" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bump Error" message:@"An error occurred." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected)
    {
        if (connected)
        {
            [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
            NSLog(@"Bump connected...");
            self.isConnectedToBump = YES;
        }
        else
        {
            NSLog(@"Bump disconnected...");
            self.isConnectedToBump = NO;
        }
    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event) {
        switch(event) {
            case BUMP_EVENT_BUMP:
                NSLog(@"Bump detected.");
                break;
            case BUMP_EVENT_NO_MATCH:
                NSLog(@"No match.");
                break;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *tempCopy = [AppModel sharedAppModel].currentGame.inventoryModel.currentInventory;
	self.inventory = [[NSMutableArray alloc] init];
    for(int i = 0; i < [tempCopy count]; i++)
    {
        if(((Item *)[tempCopy objectAtIndex:i]).tradeable)
            [self.inventory addObject:[((Item *)[tempCopy objectAtIndex:i]) copy]];
    } 
    NSMutableArray *itemsToTradeAlloc = [[NSMutableArray alloc] init];
    self.itemsToTrade = itemsToTradeAlloc;
    [self.tradeTableView reloadData];
    
    //Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tradeTableView reloadData];
    [self configureBump];
}

- (void)goBackToInventory
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[BumpClient sharedClient] disconnect];
}

- (IBAction)backButtonTouchAction:(id)sender
{
	NSLog(@"ItemTradeViewController: Dismiss Item Trade View");
	[self goBackToInventory];	
}

- (UITableViewCell *)getCellContentView:(NSString *)cellIdentifier
{
	return [[RoundedTableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:cellIdentifier forFile:@"InventoryTradeViewController"];
} 


#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return [self.itemsToTrade count];
	return [self.inventory count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return NSLocalizedString(@"InventoryTradeViewToTradeKey", @"");
    return NSLocalizedString(@"InventoryViewTitleKey",@""); 
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	NSString *CellIdentifier = [NSString stringWithFormat: @"Cell%d%d",indexPath.section,indexPath.row];
    RoundedTableViewCell *cell = (RoundedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[RoundedTableViewCell alloc] initWithStyle:UITableViewCellSelectionStyleNone reuseIdentifier:CellIdentifier forFile:@"InventoryTradeViewController.m"];
    }

    // Configure the cell.
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // draw round top corners in first row
    if(indexPath.row == 0){
        [cell drawRoundTop];
    }
    // draw round corners in last row
    if (indexPath.row == [tableView  numberOfRowsInSection:indexPath.section]-1) {
        [cell drawRoundBottom];
    }
    
  //  cell.textLabel.backgroundColor = [UIColor clearColor]; 
   // cell.detailTextLabel.backgroundColor = [UIColor clearColor]; 
    
   // cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0  
     //                                                  green:233.0/255.0  
       //                                                 blue:233.0/255.0  
         //                                              alpha:1.0];  
	Item *item;
	if(indexPath.section == 0) item = [self.itemsToTrade objectAtIndex: [indexPath row]];
	else item = [self.inventory objectAtIndex: [indexPath row]];
    
	cell.lbl1.text = item.name;	
    cell.lbl1.font = [UIFont boldSystemFontOfSize:18.0];
    [cell.lbl1 setNeedsDisplay];
    cell.lbl2.text = item.text;
    [cell.lbl2 setNeedsDisplay];
    if(item.qty >1 && item.weight > 1)
         cell.lbl4.text = [NSString stringWithFormat:@"%@: %d, %@: %d",NSLocalizedString(@"x", @""),item.qty,NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.weight > 1)
        cell.lbl4.text = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"WeightKey", @""),item.weight];
    else if(item.qty > 1)
        cell.lbl4.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"x", @""),item.qty];
    else
        cell.lbl4.text = nil;
    cell.iconView.hidden = NO;
    [cell.lbl4 setNeedsDisplay];
    Media *media;
    if (item.mediaId != 0) {
        if([self.mediaCache count] > indexPath.row)
            media = [self.mediaCache objectAtIndex:indexPath.row];
        else
        {
            media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId ofType:nil];
            if(media)
                [self.mediaCache  addObject:media];
        }
	}
    
	if (item.iconMediaId != 0)
    {
        if([self.iconCache count] < indexPath.row)
            [self.iconCache  addObject:[[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:nil]];
        [cell.iconView refreshWithFrame:cell.iconView.frame media:[self.iconCache objectAtIndex:indexPath.row] mode:ARISMediaDisplayModeAspectFit delegate:self];
	}
	else
    {
		//Load the Default
		if ([media.type isEqualToString:@"PHOTO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultImageIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
		if ([media.type isEqualToString:@"AUDIO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultAudioIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
		if ([media.type isEqualToString:@"VIDEO"]) [cell.iconView refreshWithFrame:cell.iconView.frame image:[UIImage imageNamed:@"defaultVideoIcon.png"] mode:ARISMediaDisplayModeAspectFit delegate:self];
    }
    
	return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
        if(((Item *)[self.inventory objectAtIndex:[indexPath row]]).qty > 1) ((Item *)[self.inventory objectAtIndex:[indexPath row]]).qty--;
        else [self.inventory removeObjectAtIndex:[indexPath row]];
        
        NSUInteger result = [self.itemsToTrade indexOfObjectPassingTest:
                             ^ (id arrayItem, NSUInteger idx, BOOL *stop)
                             {   
                                 if (((Item *)arrayItem).itemId == selectedItem.itemId) {
                                     return YES;
                                 }
                                 else
                                     return NO;
                             }];
        
        if (result == NSNotFound){
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
