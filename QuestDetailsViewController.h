//
//  QuestDetailsViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import <UIKit/UIKit.h>
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "Quest.h"

@interface QuestDetailsViewController : UIViewController{
    Quest *quest;
    
    IBOutlet UIImageView *questImageView;
    IBOutlet UITextView *questDescriptionBox;
    IBOutlet UIButton    *exitToButton;
}

@property(nonatomic) Quest *quest;
@property(nonatomic) IBOutlet UIImageView *questImageView;
@property(nonatomic) IBOutlet UITextView *questDescriptionBox;
@property(nonatomic) IBOutlet UIButton    *exitToButton;

- (id)initWithQuest: (Quest *) inputQuest;

@end
