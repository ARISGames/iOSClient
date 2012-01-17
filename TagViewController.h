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

@property(nonatomic,retain)IBOutlet UITableView *tagTable;
@property(nonatomic,retain)NSMutableArray *gameTagList;
@property(nonatomic,retain)NSMutableArray *playerTagList;
@property(nonatomic,retain)Note *note;
@property(nonatomic,retain)IBOutlet UIToolbar *addTagToolBar;
@property(nonatomic,retain)IBOutlet UITextField *tagTextField;

-(void)backButtonTouchAction;
-(void)refresh;
-(IBAction)cancelButtonTouchAction;
-(IBAction)createButtonTouchAction;
@end
