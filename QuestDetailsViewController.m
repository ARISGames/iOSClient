//
//  QuestDetailsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import "QuestDetailsViewController.h"

@implementation QuestDetailsViewController

@synthesize quest, questImageView, questDescriptionBox, exitToButton;

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
    
  //  ((UINavigationItem *)[self.navigationBar.items objectAtIndex:0]).title = quest.name;
    [exitToButton setTitle:@"GO" forState:UIControlStateNormal];
    [exitToButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    self.questDescriptionBox.text = self.quest.description;
    UIImage *iconImage;
    if(self.quest.iconMediaId != 0){
        Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: self.quest.iconMediaId];
        iconImage = [UIImage imageWithData:iconMedia.image];
    }
    else iconImage = [UIImage imageNamed:@"item.png"];
    [self.questImageView setImage: iconImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) exit:(id)sender{
    [[self navigationController] popToRootViewControllerAnimated:YES];
    if (!(self.quest.exitToTabName == (id)[NSNull null] || self.quest.exitToTabName.length == 0)){
        if ([self.quest.exitToTabName isEqualToString:@"QUESTS"])
            self.quest.exitToTabName = NSLocalizedString(@"QuestViewTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"GPS"])
            self.quest.exitToTabName = NSLocalizedString(@"MapViewTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"INVENTORY"])
            self.quest.exitToTabName = NSLocalizedString(@"InventoryViewTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"QR"])
            self.quest.exitToTabName = NSLocalizedString(@"QRScannerTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"PLAYER"])
            self.quest.exitToTabName = NSLocalizedString(@"PlayerTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"NOTE"])
            self.quest.exitToTabName = NSLocalizedString(@"NotebookTitleKey",@"");
        else if([self.quest.exitToTabName isEqualToString:@"PICKGAME"])
            self.quest.exitToTabName = NSLocalizedString(@"GamePickerTitleKey",@"");
        NSString *tab;
        for(int i = 0;i < [[RootViewController sharedRootViewController].tabBarController.viewControllers count];i++){
            tab = [[[RootViewController sharedRootViewController].tabBarController.viewControllers objectAtIndex:i] title];
            tab = [tab lowercaseString];
            self.quest.exitToTabName = [self.quest.exitToTabName lowercaseString];
            if([self.quest.exitToTabName isEqualToString:tab]) {
                [RootViewController sharedRootViewController].tabBarController.selectedIndex = i;
            }
        }
    }
    else [RootViewController sharedRootViewController].tabBarController.selectedIndex = 1;
}

@end
