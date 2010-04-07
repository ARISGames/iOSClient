//
//  TitleAndDecriptionFormViewController.h
//  ARIS
//
//  Created by David J Gagnon on 4/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleAndDecriptionFormViewController : UIViewController <UITextFieldDelegate>{
	IBOutlet UITableView *formTableView;
	UITextField *titleField;
	UITextField *descriptionField;
	id delegate;
}

@property (nonatomic, retain) IBOutlet UITableView *formTableView;
@property (nonatomic, retain) UITextField *titleField;
@property (nonatomic, retain) UITextField *descriptionField;
@property (nonatomic, retain) id delegate;


-(void)notifyDelegate;

@end
