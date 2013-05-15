//
//  ItemActionViewController.h
//  ARIS
//
//  Created by Brian Thiel on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "Item.h"
#import "ItemViewController.h"

@interface ItemActionViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
{
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *actionButton;
    IBOutlet UILabel *infoLabel;
    IBOutlet UILabel *badValLabel;
    IBOutlet UIPickerView *picker;
    ItemDetailsModeType mode;
    Item *item;
    Item *itemInInventory;
    int numItems;
    int max;
    id delegate;
}

@property(readwrite,assign) int numItems;
@property(readwrite,assign) int max;

@property(readwrite) ItemDetailsModeType mode;
@property(nonatomic) IBOutlet UILabel *infoLabel;
@property(nonatomic) IBOutlet UILabel *badValLabel;

@property(nonatomic) IBOutlet UIButton *backButton;
@property(nonatomic) IBOutlet UIButton *actionButton;
@property(nonatomic) Item *item;
@property(nonatomic) Item *itemInInventory;

@property(nonatomic) id delegate;

- (id) initWithItem:(Item *)i;

- (void) doActionWithMode:(ItemDetailsModeType)itemMode quantity:(int)quantity;
- (IBAction) backButtonTouchAction:(id)sender;
- (IBAction) actionButtonTouchAction:(id)sender;

@end
