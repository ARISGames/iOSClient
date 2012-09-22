//
//  IconQuestsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 9/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IconQuestsViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Quest.h"
#import "Media.h"
#import "AsyncMediaImageView.h"
#import "WebPage.h"
#import "webpageViewController.h"

static NSString * const OPTION_CELL = @"quest";
static int const ACTIVE_SECTION = 0;
static int const COMPLETED_SECTION = 1;

NSString *const kIconQuestsHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #E9E9E9;"
@"		color: #000000;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0;"
@"	}"
@"	h1 {"
@"		color: #000000;"
@"		font-size: 18px;"
@"		font-style: bold;"
@"		font-family: Helvetia, Sans-Serif;"
@"		margin: 0 0 10 0;"
@"	}"
@"	--></style>"
@"</head>"
@"<body></div><div style=\"position:relative; top:0px; background-color:#DDDDDD; border-style:ridge; border-width:3px; border-radius:11px; border-color:#888888;padding:15px;\"><h1>%@</h1>%@</div></body>"
@"</html>";

@implementation IconQuestsViewController

@synthesize quests, isLink, activeSort;

//Override init for passing title and icon to tab bar
- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        self.title = NSLocalizedString(@"QuestViewTitleKey",@"");
        self.tabBarItem.image = [UIImage imageNamed:@"117-todo"];
        activeSort = 1;
		self.isLink = NO;
		//register for notifications
		NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
        [dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ConnectionLost" object:nil];
		[dispatcher addObserver:self selector:@selector(removeLoadingIndicator) name:@"ReceivedQuestList" object:nil];
		[dispatcher addObserver:self selector:@selector(refreshViewFromModel) name:@"NewQuestListReady" object:nil];
		[dispatcher addObserver:self selector:@selector(silenceNextUpdate) name:@"SilentNextUpdate" object:nil];
    }
	
    return self;
}

- (void)silenceNextUpdate {
	silenceNextServerUpdateCount++;
	NSLog(@"IconQuestsViewController: silenceNextUpdate. Count is %d",silenceNextServerUpdateCount );
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"IconQuestsViewController: Quests View Loaded");
	
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"IconQuestsViewController: viewDidAppear");
    
    if (![AppModel sharedAppModel].loggedIn || [AppModel sharedAppModel].currentGame.gameId==0) {
        NSLog(@"QuestsVC: Player is not logged in, don't refresh");
        return;
    }
    
	[[AppServices sharedAppServices] updateServerQuestsViewed];
	
	[self refresh];
	
	self.tabBarItem.badgeValue = nil;
	newItemsSinceLastView = 0;
	silenceNextServerUpdateCount = 0;
    
}

-(void)dismissTutorial{
	[[RootViewController sharedRootViewController].tutorialViewController dismissTutorialPopupWithType:tutorialPopupKindQuestsTab];
}

- (void)refresh {
	NSLog(@"IconQuestsViewController: refresh requested");
	if ([AppModel sharedAppModel].loggedIn) [[AppServices sharedAppServices] fetchQuestList];
	[self showLoadingIndicator];
}


-(void)showLoadingIndicator{
	UIActivityIndicatorView *activityIndicator = 
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[[self navigationItem] setRightBarButtonItem:barButton];
	[activityIndicator startAnimating];
}

-(void)removeLoadingIndicator{
	[[self navigationItem] setRightBarButtonItem:nil];
	NSLog(@"IconQuestsViewController: removeLoadingIndicator");
}

-(void)refreshViewFromModel {
	NSLog(@"IconQuestsViewController: Refreshing view from model");
	
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
//	progressLabel.text = [NSString stringWithFormat:@"%d %@ %d %@", [AppModel sharedAppModel].currentGame.completedQuests, NSLocalizedString(@"OfKey", @"Number of Number"), [AppModel sharedAppModel].currentGame.totalQuests, NSLocalizedString(@"QuestsCompleteKey", @"")];
//	progressView.progress = (float)[AppModel sharedAppModel].currentGame.completedQuests / (float)[AppModel sharedAppModel].currentGame.totalQuests;
    
	NSLog(@"IconQuestsViewController: refreshViewFromModel: silenceNextServerUpdateCount = %d", silenceNextServerUpdateCount);
	
	//Update the badge
	if (silenceNextServerUpdateCount < 1) {
		//Check if anything is new since last time
		int newItems = 0;
		NSArray *newActiveQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
		for (Quest *quest in newActiveQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:ACTIVE_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
				newItems ++;;
                quest.sortNum = activeSort;
                activeSort++;
                
                [[RootViewController sharedRootViewController] enqueueNotificationWithTitle:NSLocalizedString(@"QuestsViewNewQuestsKey", @"")
                                                                                  andPrompt:quest.name];
			}
		}
        
        NSArray *newCompletedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
        
        for (Quest *quest in newCompletedQuestsArray) {		
			BOOL match = NO;
			for (Quest *existingQuest in [self.quests objectAtIndex:COMPLETED_SECTION]) {
				if (existingQuest.questId == quest.questId) match = YES;	
			}
			if (match == NO) {
                [appDelegate playAudioAlert:@"inventoryChange" shouldVibrate:YES];
                
                [[RootViewController sharedRootViewController] enqueueNotificationWithTitle:NSLocalizedString(@"QuestsViewQuestCompletedKey", @"")
                                                                                  andPrompt:quest.name];
			}
		}
        
		if (newItems > 0) {
			newItemsSinceLastView += newItems;
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",newItemsSinceLastView];
			
			if (![AppModel sharedAppModel].hasSeenQuestsTabTutorial){
                //Put up the tutorial tab
				[[RootViewController sharedRootViewController].tutorialViewController showTutorialPopupPointingToTabForViewController:self.navigationController 
                                                                                                                                 type:tutorialPopupKindQuestsTab 
                                                                                                                                title:NSLocalizedString(@"QuestViewNewQuestKey", @"")
                                                                                                                              message:NSLocalizedString(@"QuestViewNewQuestMessageKey", @"")];
				[AppModel sharedAppModel].hasSeenQuestsTabTutorial = YES;
                [self performSelector:@selector(dismissTutorial) withObject:nil afterDelay:5.0];
			}
		}
		else if (newItemsSinceLastView < 1) self.tabBarItem.badgeValue = nil;
	}
	else {
		newItemsSinceLastView = 0;
		self.tabBarItem.badgeValue = nil;
	}
	
	//rebuild the list
	NSArray *activeQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"active"];
	NSArray *completedQuestsArray = [[AppModel sharedAppModel].questList objectForKey:@"completed"];
	
	self.quests = [NSArray arrayWithObjects:activeQuestsArray, completedQuestsArray, nil];
    
	[self createIcons];
	
	if (silenceNextServerUpdateCount>0) silenceNextServerUpdateCount--;
    
}

-(void)createIcons{
	NSLog(@"QuestsVC: Constructing Icons");
	
	NSArray *activeQuests = [self.quests objectAtIndex:ACTIVE_SECTION];
	NSArray *completedQuests = [self.quests objectAtIndex:COMPLETED_SECTION];
    
    for(int i = 0; i < [self.quests count]; i++){
        int xOrigin = 19;
        int yOrigin = 20;
        int tempI = i;
            if(tempI > 7){
                yOrigin += 154; 
                tempI -= 8;
            }
            else if(i > 3){
                yOrigin = 77;
                tempI -= 4;
            }
            xOrigin += tempI * 75;
        
        UIImage *iconImage;
  //      if([[self.quests objectAtIndex:i] iconMediaId] != 0){
    //    Media *iconMedia = [[AppModel sharedAppModel] mediaForMediaId: [[self.quests objectAtIndex:i] iconMediaId]];
      //      iconImage = [UIImage imageWithData:iconMedia.image];
       // }
       // else 
            iconImage = [UIImage imageNamed:@"page.png"];
        UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        iconButton.frame = CGRectMake(xOrigin, yOrigin, 57.0, 57.0);
        iconButton.tag = i;
        [iconButton setBackgroundImage: iconImage forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(questSelected:) forControlEvents:UIControlEventTouchUpInside];
        [iconButton setNeedsDisplay];
    }
    
  /*  
	NSEnumerator *e;
	Quest *quest;
	NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortNum"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    activeQuests = [activeQuests sortedArrayUsingDescriptors:sortDescriptors];
    
    NSLog(@"QuestsVC: Active Quests Selected");
    e = [activeQuests objectEnumerator];
    while ( (quest = (Quest*)[e nextObject]) ) {
        [activeQuestCells addObject: [self getCellContentViewForQuest:quest inSection:ACTIVE_SECTION]];
    }
    */
    /*
     This adds a "No new quests" quest to the quest list. Commented out for sizing issues to be dealt with later.
     if([activeQuestCells count] == 0){
     activeQuestsEmpty = YES;
     Quest *nullQuest = [[Quest alloc] init];
     nullQuest.isNullQuest = true;
     nullQuest.questId = -1;
     nullQuest.name = @"Empty";
     nullQuest.description = @"(there are no quests available at this time)";
     NSMutableArray *activeQuestsMutable = [[NSMutableArray alloc] initWithArray: activeQuests];
     [activeQuestsMutable addObject: nullQuest];
     activeQuests = (NSArray *)activeQuestsMutable;
     [activeQuestCells addObject: [self getCellContentViewForQuest:nullQuest inSection:ACTIVE_SECTION]];
     //[self updateCellSize: [activeQuestCells objectAtIndex:0]];
     
     }
     */ 
    
 //   e = [completedQuests objectEnumerator];
 //   NSLog(@"QuestsVC: Completed Quests Selected");
 //   while ( (quest = (Quest*)[e nextObject]) ) {
 //       [completedQuestCells addObject:[self getCellContentViewForQuest:quest inSection:COMPLETED_SECTION]];
 //  }
    /*
     This adds a "No new quests" quest to the quest list. Commented out for sizing issues to be dealt with later.
     if([completedQuestCells count] == 0){
     completedQuestsEmpty = YES;
     
     Quest *nullQuest = [[Quest alloc] init];
     nullQuest.isNullQuest = true;
     nullQuest.questId = -1;
     nullQuest.name = @"Empty";
     nullQuest.description = @"(you have not completed any quests)";
     NSMutableArray *activeQuestsMutable = [[NSMutableArray alloc] initWithArray: activeQuests];
     [activeQuestsMutable addObject: nullQuest];
     activeQuests = (NSArray *)activeQuestsMutable;
     [completedQuestCells addObject: [self getCellContentViewForQuest:nullQuest inSection:COMPLETED_SECTION]];
     // [self updateCellSize: [completedQuestCells objectAtIndex:0]];
     }
     */
	
	NSLog(@"QuestsVC: Icons created");
}

- (void) questSelected: (id)sender {
    
}

- (BOOL)webView:(UIWebView *)webView  
shouldStartLoadWithRequest:(NSURLRequest *)request  
 navigationType:(UIWebViewNavigationType)navigationType; {  
	
    /* NSURL *requestURL = [ [ request URL ] retain ];
     if ( ( [ [ requestURL scheme ] isEqualToString: @"http" ]  
     || [ [ requestURL scheme ] isEqualToString: @"https" ] )  
     && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {  
     return ![ [ UIApplication sharedApplication ] openURL: [ requestURL autorelease ] ];  
     }  */
    if(self.isLink && ![[[request URL]absoluteString] isEqualToString:@"about:blank"]) {
        webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
        WebPage *temp = [[WebPage alloc]init];
        temp.url = [[request URL]absoluteString];
        webPageViewController.webPage = temp;
        webPageViewController.delegate = self;
        [self.navigationController pushViewController:webPageViewController animated:NO];
        
        return NO;
    }
    else{
        self.isLink = YES;
        return YES;}
    
	// Check to see what protocol/scheme the requested URL is.  
	
	// Auto release  
	//[ requestURL release ];  
	// If request url is something other than http or https it will open  
	// in UIWebView. You could also check for the other following  
	// protocols: tel, mailto and sms  
	//return YES;  
} 



- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	NSLog(@"IconQuestsViewController: VebView loaded");
    
    //[self performSelector:@selector(updateCellSizes) withObject:nil afterDelay:0.1];
}

/*-(void)updateCellSize:(UITableViewCell*)cell {
	NSLog(@"QuestViewController: Updating Cell Sizes");
    
	UIWebView *descriptionView = (UIWebView *)[cell viewWithTag:1];
	float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
	
	NSLog(@"QuestViewController: Description View Calculated Height is: %f",newHeight);
    
	
	CGRect descriptionFrame = [descriptionView frame];	
	descriptionFrame.size = CGSizeMake(descriptionFrame.size.width,newHeight);
	[descriptionView setFrame:descriptionFrame];
	[[[descriptionView subviews] lastObject] setScrollEnabled:NO];
	NSLog(@"QuestViewController: description UIWebView frame set to {%f, %f, %f, %f}", 
		  descriptionFrame.origin.x, 
		  descriptionFrame.origin.y, 
		  descriptionFrame.size.width,
		  descriptionFrame.size.height);
	
	CGRect cellFrame = [cell frame];
	cellFrame.size = CGSizeMake(cell.frame.size.width,newHeight + 25);
	[cell setFrame:cellFrame];
    
	NSLog(@"QuestViewController: cell frame set to {%f, %f, %f, %f}", 
		  cell.frame.origin.x, 
		  cell.frame.origin.y, 
		  cell.frame.size.width,
		  cell.frame.size.height);
} */


//	NSString *htmlDescription = [NSString stringWithFormat:kQuestsHtmlTemplate, quest.name, quest.description];


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
