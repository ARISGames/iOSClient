//
//  QuestDetailsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import "QuestDetailsViewController.h"

@implementation QuestDetailsViewController

@synthesize quest, questImageView, questDescriptionBox, exitToButton, navigationBar;

- (id)initWithQuest: (Quest *) inputQuest
{
    self = [super init];
    if (self) {
        self.quest = inputQuest;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.navigationBar.topItem.title = quest.name;
    
  //  ((UINavigationItem *)[self.navigationBar.items objectAtIndex:0]).title = quest.name;
    [exitToButton setTitle:@"GO" forState:UIControlStateNormal];
    [exitToButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    self.questDescriptionBox.text = self.quest.description;
    [self.questImageView setImage: [UIImage imageNamed:@"item.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) exit:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NO];
}

@end
