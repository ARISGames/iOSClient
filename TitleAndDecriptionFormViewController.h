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

@property (nonatomic) IBOutlet UITableView *formTableView;
@property (nonatomic) UITextField *titleField;
@property (nonatomic) UITextField *descriptionField;
@property (nonatomic) id delegate;
@property (nonatomic) Item *item;


-(void)notifyDelegate;

@end
