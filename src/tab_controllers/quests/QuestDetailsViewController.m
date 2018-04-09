//
//  QuestDetailsViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/11/12.
//
//

#import "QuestDetailsViewController.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "Quest.h"
#import "QuestCell.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import <Google/Analytics.h>


@interface QuestDetailsViewController() <UIScrollViewDelegate, ARISWebViewDelegate, ARISMediaViewDelegate, QuestDetailsViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, QuestCellDelegate>
{
    UITableView *scrollView;
    ARISMediaView  *mediaView;
    ARISWebView *webView;
    UIView *goButton;
    UILabel *goLbl;
    UIImageView *arrow;
    UIView *line;

    Quest *quest;
    NSString *mode;
    NSArray *activeQuests;
    NSArray *completeQuests;
    NSMutableArray *subquests;
    CGFloat mediaHeight;
    CGFloat descriptionHeight;
    NSMutableDictionary *subquestHeights;
    id<QuestDetailsViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation QuestDetailsViewController

- (id) initWithQuest:(Quest *)q mode:(NSString *)m activeQuests:(NSArray *)a completeQuests:(NSArray *)c delegate:(id<QuestDetailsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        quest = q;
        mode = m;
        activeQuests = a;
        completeQuests = c;
        delegate = d;
        self.title = quest.name;
    }
    return self;
}

- (void) loadView
{
    [super loadView];

    self.view.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    self.navigationItem.title = quest.name;

    scrollView = [[UITableView alloc] init];
    scrollView.backgroundColor = [ARISTemplate ARISColorContentBackdrop];
    scrollView.clipsToBounds = NO;
    scrollView.dataSource = self;
    scrollView.delegate = self;

    webView = [[ARISWebView alloc] initWithDelegate:self];
    webView.backgroundColor = [UIColor clearColor];
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = NO;
    webView.alpha = 0.0; //The webView will resore alpha once it's loaded to avoid the ugly white blob

    mediaView = [[ARISMediaView alloc] initWithDelegate:self];
    [mediaView setDisplayMode:ARISMediaDisplayModeTopAlignAspectFitWidthAutoResizeHeight];
    
    subquestHeights = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    goButton = [[UIView alloc] init];
    goButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    goButton.userInteractionEnabled = YES;
    goButton.accessibilityLabel = @"BeginQuest";
    goLbl = [[UILabel alloc] init];
    goLbl.textColor = [ARISTemplate ARISColorText];
    goLbl.textAlignment = NSTextAlignmentRight;
    goLbl.text = NSLocalizedString(@"QuestViewBeginQuestKey", @"");
    goLbl.font = [ARISTemplate ARISButtonFont];
    [goButton addSubview:goLbl];
    [goButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goButtonTouched)]];

    arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrowForward"]];
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor ARISColorLightGray];

    [self.view addSubview:scrollView];

    [self loadQuest];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    scrollView.frame = self.view.bounds;

    goButton.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    goLbl.frame = CGRectMake(0,0,self.view.bounds.size.width-30,44);
    arrow.frame = CGRectMake(self.view.bounds.size.width-25, self.view.bounds.size.height-30, 19, 19);
    line.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1);
}

- (void) loadQuest
{
    subquests = [[NSMutableArray alloc] init];
    for (Quest *q in [activeQuests arrayByAddingObjectsFromArray:completeQuests]) {
        if (q.parent_quest_id == quest.quest_id) {
            [subquests addObject:q];
        }
    }

    webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);//Needs correct width to calc height
    [webView loadHTMLString:[NSString stringWithFormat:[ARISTemplate ARISHtmlTemplate], ([mode isEqualToString:@"ACTIVE"] ? quest.active_desc : quest.complete_desc)] baseURL:nil];

    Media *media = [_MODEL_MEDIA_ mediaForId:([mode isEqualToString:@"ACTIVE"] ? quest.active_media_id : quest.complete_media_id)];
    if(media)
    {
        [mediaView setFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
        [mediaView setMedia:media];
    }

    if(![([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"NONE"])
    {
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        [self.view addSubview:goButton];
        [self.view addSubview:arrow];
        [self.view addSubview:line];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 19, 19);
    [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
    backButton.accessibilityLabel = @"Back Button";
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Quest Details"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void) ARISMediaViewFrameUpdated:(ARISMediaView *)amv
{
    mediaHeight = mediaView.frame.size.height;
    [scrollView reloadData];
}

- (BOOL) webView:(ARISWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    WebPage *w = [_MODEL_WEB_PAGES_ webPageForId:0];
    w.url = [r.URL absoluteString];
    //[delegate displayGameObject:w fromSource:self];

    return NO;
}

- (void) ARISWebViewDidFinishLoad:(ARISWebView *)wv
{
    webView.alpha = 1.00;

    descriptionHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    if(_MODEL_GAME_.ipad_two_x && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) //2x
      descriptionHeight *= 2;
    [webView setFrame:CGRectMake(webView.frame.origin.x,
                                 webView.frame.origin.y,
                                 webView.frame.size.width,
                                 descriptionHeight)];
    [scrollView reloadData];
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [delegate questDetailsRequestsDismissal];
}

- (void) backButtonTouched
{
    [delegate questDetailsRequestsDismissal];
}

- (void) dismissQuestDetails
{
  [delegate questDetailsRequestsDismissal];
}

- (void) goButtonTouched
{
    if([([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"JAVASCRIPT"]) [webView hookWithParams:@""];
    else if([([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"NONE"]) return;
    else if([([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function) isEqualToString:@"PICKGAME"]) [_MODEL_ leaveGame];
    else [_MODEL_DISPLAY_QUEUE_ enqueueTab:[_MODEL_TABS_ tabForType:([mode isEqualToString:@"ACTIVE"] ? quest.active_function : quest.complete_function)]];
}

// this is when a subquest of this (compound) quest requests dismissal
- (void) questDetailsRequestsDismissal
{
    [self.navigationController popToViewController:self animated:YES];
}

- (void) dealloc
{
    webView.delegate = nil;
    [webView stopLoading];
    _ARIS_NOTIF_IGNORE_ALL_(self);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3; // media view, web view (description), subquests
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) return 1; // media view or web view
    return subquests.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1) {
        BOOL isMediaView = indexPath.section == 0;
        NSString *cellIdentifier = isMediaView ? @"ARISMediaView" : @"ARISWebView";
        UIView *thisView = isMediaView ? mediaView : webView;
        UITableViewCell *cell = [scrollView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        } else {
            [[cell.contentView viewWithTag:500] removeFromSuperview];
        }
        thisView.tag = 500;
        [cell.contentView addSubview:thisView];
        return cell;
    } else {
        QuestCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"QuestCell"];
        if(!cell) cell = [[QuestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuestCell"];
        
        [cell setQuest:[subquests objectAtIndex:indexPath.row]];
        
        [cell setDelegate:self];
        
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return mediaHeight;
    } else if (indexPath.section == 1) {
        return descriptionHeight;
    } else {
        Quest *q = [subquests objectAtIndex:indexPath.row];
        if([subquestHeights objectForKey:[q description]])
            return [((NSNumber *)[subquestHeights objectForKey:[q description]]) intValue];
        
        NSMutableParagraphStyle *paragraphStyle;
        CGRect textRect;
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textRect = [q.desc boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, 2000000)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0],NSParagraphStyleAttributeName:paragraphStyle}
                                        context:nil];
        CGSize calcSize = textRect.size;
        return calcSize.height+30;
    }
}

- (void) heightCalculated:(long)h forQuest:(Quest *)q inCell:(QuestCell *)qc
{
    if(![subquestHeights objectForKey:[q description]])
    {
        [subquestHeights setValue:[NSNumber numberWithLong:h] forKey:[q description]];
        [scrollView reloadData];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        Quest *q = [subquests objectAtIndex:indexPath.row];
        if (q) {
            [[self navigationController] pushViewController:[[QuestDetailsViewController alloc] initWithQuest:q mode:mode activeQuests:nil completeQuests:nil delegate:self] animated:YES];
        }
    }
}

@end
