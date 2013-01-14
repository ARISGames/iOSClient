//
//  QuestDetailsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import "QuestDetailsViewController.h"

@implementation QuestDetailsViewController

NSString *const kQuestDetailsHtmlTemplate =
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"  html,body {margin: 0;padding: 0;width: 100%%;height: 100%%;}"
@"  html {display: table;}"
@"	body {"
@"		background-color: transparent;"
@"		color: #000000;"
@"      display: table-cell;"
@"      vertical-align: middle;"
@"      text-align: center;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      -webkit-text-size-adjust: none;"
@"	}"
@"  ol"
@"  {"
@"      text-align:left;"
@"  }"
@"	a {color: #000000; text-decoration: underline; }"
@"	--></style>"
@"</head>"
@"<body><p>%@</p></body>"
@"</html>";

@synthesize quest, questImageView, exitToButton;

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
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Do any additional setup after loading the view from its nib.
    
    //NOTE: HEY PHIL, I ONLY HID THE BUTTON, IF YOU WANT THAT EXTRA SCREEN REAL ESTATE THEN YOU'LL HAVE TO EXPAND THE TEXT VIEW
    
    if (!(self.quest.exitToTabName == (id)[NSNull null] || self.quest.exitToTabName.length == 0 ||[self.quest.exitToTabName isEqualToString:@"NONE"])){
        NSString *buttonTitle = NSLocalizedString(@"GoToKey", nil);
        buttonTitle = [buttonTitle stringByAppendingString:@" "];
        buttonTitle = [buttonTitle stringByAppendingString:self.quest.exitToTabName];
        [exitToButton setTitle:buttonTitle forState:UIControlStateNormal];
        [exitToButton setTitle:buttonTitle forState:UIControlStateHighlighted];
        [exitToButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        exitToButton.hidden = YES;
        CGRect newWebViewFrame = CGRectMake(questDescriptionWebView.frame.origin.x, questDescriptionWebView.frame.origin.y, questDescriptionWebView.frame.size.width, questDescriptionWebView.frame.size.height+69);
        questDescriptionWebView.frame = newWebViewFrame;
    }
    NSString *text = self.quest.description;
    if ([text rangeOfString:@"<html>"].location == NSNotFound) text = [NSString stringWithFormat:kQuestDetailsHtmlTemplate, text];
    [questDescriptionWebView loadHTMLString:text baseURL:nil];
    
    if(self.quest.mediaId != 0){
        Media *questMedia = [[AppModel sharedAppModel] mediaForMediaId: self.quest.mediaId];
        CGRect mediaFrame = questImageView.frame;
        mediaFrame.origin.x = 0;
        mediaFrame.origin.y = 0;
        if([questMedia.type isEqualToString:kNoteContentTypePhoto]){
            AsyncMediaImageView* mediaView = [[AsyncMediaImageView alloc] initWithFrame:mediaFrame andMediaId:self.quest.mediaId];
            [questImageView addSubview:mediaView];
        }
        else {
            AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:questImageView.frame media:questMedia presentingController:self preloadNow:YES];
            [self.view addSubview:mediaButton];
        }
    }
    else {
        UIImage *iconImage = [UIImage imageNamed:@"item.png"];
        [self.questImageView setImage: iconImage];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [questDescriptionWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) exit:(id)sender{
    [[self navigationController] popToRootViewControllerAnimated:YES];
    if (!(self.quest.exitToTabName == (id)[NSNull null] || self.quest.exitToTabName.length == 0 ||[self.quest.exitToTabName isEqualToString:@"NONE"])){
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
    //else [RootViewController sharedRootViewController].tabBarController.selectedIndex = 1;
}

- (void)viewDidUnload {
    questDescriptionWebView = nil;
    [super viewDidUnload];
}
@end
