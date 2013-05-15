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
#import "AsyncMediaPlayerButton.h"

@interface QuestDetailsViewController : UIViewController
{
    Quest *quest;
    
    IBOutlet UIImageView *questImageView;
    IBOutlet UIWebView *questDescriptionWebView;
    IBOutlet UIButton *exitToButton;
}

@property(nonatomic) Quest *quest;
@property(nonatomic) IBOutlet UIImageView *questImageView;
@property(nonatomic) IBOutlet UIButton    *exitToButton;

- (id)initWithQuest: (Quest *) inputQuest;

@end
