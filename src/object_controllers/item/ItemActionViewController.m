//
//  ItemActionViewController.m
//  ARIS
//
//  Created by Brian Thiel on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemActionViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Media.h"

@implementation ItemActionViewController
@synthesize item,itemInInventory;
@synthesize mode;
@synthesize numItems,max;
@synthesize infoLabel,backButton,actionButton,badValLabel;
@synthesize delegate;

- (id) initWithItem:(Item *)i
{
    if(self = [super initWithNibName:@"ItemActionViewController" bundle:nil])
    {
        self.item = i;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    actionButton.titleLabel.textAlignment = UITextAlignmentCenter;
    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.infoLabel.text = @"";
    self.infoLabel.font = [UIFont boldSystemFontOfSize:18];
    switch(self.mode)
    {
        case kItemDetailsPickingUp:
            [actionButton setTitle: NSLocalizedString(@"ItemPickupKey", @"") forState: UIControlStateNormal];
            [actionButton setTitle: NSLocalizedString(@"ItemPickupKey", @"") forState: UIControlStateHighlighted];

            self.max = self.item.maxQty - itemInInventory.qty;
            while((self.max*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)
                self.max--;
            break;
        case kItemDetailsDropping:
            [actionButton setTitle: NSLocalizedString(@"ItemDropKey", @"") forState: UIControlStateNormal];
            [actionButton setTitle: NSLocalizedString(@"ItemDropKey", @"") forState: UIControlStateHighlighted];
            self.max = self.itemInInventory.qty;
            break;
        case kItemDetailsDestroying:
            [actionButton setTitle: NSLocalizedString(@"ItemDeleteKey", @"") forState: UIControlStateNormal];
            [actionButton setTitle: NSLocalizedString(@"ItemDeleteKey", @"") forState: UIControlStateHighlighted];            
            self.max = self.itemInInventory.qty;
            break;
        default:
            break;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"") style: UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchAction:)];
    [super viewDidLoad];
}

- (IBAction) backButtonTouchAction:(id)sender
{
	[[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:0];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.badValLabel.hidden = YES;
    actionButton.titleLabel.textAlignment = UITextAlignmentCenter;
    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.infoLabel.text = @"";
    [picker selectRow:1 inComponent:0 animated:NO];
    self.itemInInventory = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
    self.navigationItem.title = self.item.name;
    switch(self.mode)
    {
        case kItemDetailsPickingUp:
            self.actionButton.titleLabel.text = NSLocalizedString(@"ItemPickupKey", @"");
            self.max = self.item.maxQty - itemInInventory.qty;
            self.numItems = 1;
            while ((self.max*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)
                self.max--;
            break;
        case kItemDetailsDropping:
            self.actionButton.titleLabel.text = NSLocalizedString(@"ItemDropKey", @"");
            self.max = self.itemInInventory.qty;
            self.numItems = 1;
            break;
        case kItemDetailsDestroying:
            self.actionButton.titleLabel.text = NSLocalizedString(@"ItemDeleteKey",@"");
            self.max = self.itemInInventory.qty;
            self.numItems = 1;
            break;
        default:
            break;
    }
}

- (IBAction)actionButtonTouchAction:(id)sender
{
    [self doActionWithMode:self.mode quantity:self.numItems];
    [self.navigationController popViewControllerAnimated:YES];
    [delegate updateQuantityDisplay];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(self.mode == kItemDetailsPickingUp)
        return (item.qty + 1);
    else 
        self.itemInInventory = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
    return (itemInInventory.qty + 1);
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0) return @"Max";
    else return [NSString stringWithFormat:@"%d",row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row == 0)
    {
        self.numItems = self.max;
        self.infoLabel.text = @"";
        self.badValLabel.hidden = YES;
        self.actionButton.userInteractionEnabled = YES;
        self.actionButton.alpha = 1;
    }
    else
    {
        self.numItems = row;
        if(self.mode == kItemDetailsPickingUp)
        {
            if((self.numItems) > self.max)
            {
                self.infoLabel.text = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemActionCanCarryKey", @""),self.max,NSLocalizedString(@"ItemActionOfItemKey", @"")];
                self.badValLabel.hidden = NO;
                self.actionButton.userInteractionEnabled = NO;
                self.actionButton.alpha = .7;
            }
            else
            {
                self.infoLabel.text = @"";
                self.badValLabel.hidden = YES;
                self.actionButton.userInteractionEnabled = YES;
                self.actionButton.alpha = 1;
            }
        }
    }
}

-(void)doActionWithMode:(ItemDetailsModeType)itemMode quantity:(int)quantity
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"drop" shouldVibrate:YES];
	
	if (mode == kItemDetailsDropping)
    {
		NSLog(@"ItemDetailsVC: Dropping %d",quantity);
		[[AppServices sharedAppServices] updateServerDropItemHere:item.itemId qty:quantity];
		[[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:quantity];
    }
	else if (mode == kItemDetailsDestroying)
    {
		NSLog(@"ItemDetailsVC: Destroying %d",quantity);
		[[AppServices sharedAppServices] updateServerDestroyItem:self.item.itemId qty:quantity];
		[[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:quantity];
	}
	else if (mode == kItemDetailsPickingUp)
    {
        NSString *errorMessage;
		self.itemInInventory = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
		if (itemInInventory.qty + quantity > item.maxQty && item.maxQty != -1) {
            
			[appDelegate playAudioAlert:@"error" shouldVibrate:YES];
			
			if (itemInInventory.qty < item.maxQty)
            {
				quantity = item.maxQty - itemInInventory.qty;
                
                if([AppModel sharedAppModel].currentGame.inventoryModel.weightCap != 0)
                {
                    while((quantity*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)
                    {
                        quantity--;
                    }
                }
				errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionCarryThatMuchKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
			}
			else if (item.maxQty == 0)
            {
				errorMessage = NSLocalizedString(@"ItemAcionCannotPickUpKey", @"");
				quantity = 0;
			}
            else
            {
				errorMessage = NSLocalizedString(@"ItemAcionCannotCarryMoreKey", @"");
				quantity = 0;
			}
            
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message: errorMessage
														   delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
			[alert show];
		}
        else if (((quantity*item.weight +[AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)&&([AppModel sharedAppModel].currentGame.inventoryModel.weightCap != 0))
        {
            while ((quantity*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)
                quantity--;
            
            errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionTooHeavyKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message:errorMessage
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
			[alert show];
        }
        
		if (quantity > 0)
        {
			//TODO [[AppServices sharedAppServices] updateServerPickupItem:self.item.itemId fromLocation:self.item.locationId qty:quantity];
			//TODO [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:-quantity forLocationId:self.item.locationId];
			item.qty -= quantity; //the above line does not give us an update, only the map
        }
	}
		
	if (item.qty < 1)
		[self.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

@end
