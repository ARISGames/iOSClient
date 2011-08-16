//
//  TitleAndDecriptionFormViewController.h
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 University of Wisconsin - Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface TitleAndDecriptionFormViewController : UIViewController <UITextFieldDelegate>{
	IBOutlet UITableView *formTableView;
	UITextField *titleField;
	UITextField *descriptionField;
	id delegate;
    Item *item;
}

@property (nonatomic, retain) IBOutlet UITableView *formTableView;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *descriptionField;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) Item *item;


-(void)notifyDelegate;

@end
