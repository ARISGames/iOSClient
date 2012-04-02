//
//  TagViewController.h
//  ARIS
//
//  Created by Brian Thiel on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
@interface TagViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    IBOutlet UITableView *tagTable;
    NSMutableArray *gameTagList;
    NSMutableArray *playerTagList;
    Note *note;
    IBOutlet UIToolbar *addTagToolBar;
    IBOutlet UITextField *tagTextField;
}

@property(nonatomic)IBOutlet UITableView *tagTable;
@property(nonatomic)NSMutableArray *gameTagList;
@property(nonatomic)NSMutableArray *playerTagList;
@property(nonatomic)Note *note;
@property(nonatomic)IBOutlet UIToolbar *addTagToolBar;
@property(nonatomic)IBOutlet UITextField *tagTextField;

-(void)backButtonTouchAction;
-(void)refresh;
-(IBAction)cancelButtonTouchAction;
-(IBAction)createButtonTouchAction;
@end
