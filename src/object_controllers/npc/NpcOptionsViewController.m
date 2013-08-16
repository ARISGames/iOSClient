//
//  NpcOptionsViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 8/5/13.
//
//

#import "NpcOptionsViewController.h"
#import "NpcScriptOption.h"
#import "ARISMediaView.h"
#import "ARISCollapseView.h"
#import "AppModel.h"
#import "AppServices.h"
#import "UIColor+ARISColors.h"

const NSInteger kOptionsFontSize = 17;

@interface NpcOptionsViewController() <ARISMediaViewDelegate, ARISCollapseViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    ARISMediaView *mediaView;
    
    ARISCollapseView *optionsCollapseView;
    UITableView *optionsTableView;
    UIActivityIndicatorView *loadingIndicator;
    
	NSArray *optionList;
    
    NSString *playerTitle;
    NSString *currentLeaveConversationTitle;
    BOOL currentlyHidingLeaveConversationButton;
    
    int textBoxSizeState;
    
    CGRect viewFrame;
    
    id<NpcOptionsViewControllerDelegate> __unsafe_unretained delegate;
}

@property (nonatomic, strong) ARISMediaView *mediaView;
@property (nonatomic, strong) ARISCollapseView *optionsCollapseView;
@property (nonatomic, strong) UITableView *optionsTableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSArray *optionList;
    
@property (nonatomic, strong) NSString *playerTitle;
@property (nonatomic, strong) NSString *currentLeaveConversationTitle;
@property (nonatomic, assign) BOOL currentlyHidingLeaveConversationButton;

@end

@implementation NpcOptionsViewController

@synthesize mediaView;
@synthesize optionsCollapseView;
@synthesize optionsTableView;
@synthesize loadingIndicator;
@synthesize optionList;
@synthesize playerTitle;
@synthesize currentLeaveConversationTitle;
@synthesize currentlyHidingLeaveConversationButton;

- (id) initWithFrame:(CGRect)f delegate:(id<NpcOptionsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        playerTitle = NSLocalizedString(@"DialogPlayerName",@"");
        currentLeaveConversationTitle = NSLocalizedString(@"DialogEnd",@"");
        currentlyHidingLeaveConversationButton = NO;
        
        viewFrame = f; //ugh
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionsReceivedFromNotification:) name:@"ConversationOptionsReady" object:nil];
    }
    return self;
}

- (void) loadView
{
    [super loadView];
     
    self.view.frame = viewFrame;
    self.view.bounds = CGRectMake(0,0,viewFrame.size.width,viewFrame.size.height);
    self.view.backgroundColor = [UIColor whiteColor];
    
    Media *pcMedia = 0;
    if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId ofType:nil];
    else if([AppModel sharedAppModel].player.playerMediaId  != 0) pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].player.playerMediaId ofType:nil];
    
    if(pcMedia) self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds media:pcMedia                                    mode:ARISMediaDisplayModeTopAlignAspectFitWidth delegate:self];
    else        self.mediaView = [[ARISMediaView alloc] initWithFrame:self.view.bounds image:[UIImage imageNamed:@"DefaultPCImage.png"] mode:ARISMediaDisplayModeTopAlignAspectFitWidth delegate:self];
    [self.mediaView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToOptions:)]];
    
    self.optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 128) style:UITableViewStyleGrouped];
    self.optionsTableView.opaque = NO;
    self.optionsTableView.backgroundView = nil;
    self.optionsTableView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    self.optionsTableView.scrollEnabled = YES;
    self.optionsTableView.dataSource = self;
    self.optionsTableView.delegate = self;
    
    self.optionsCollapseView = [[ARISCollapseView alloc] initWithView:self.optionsTableView frame:CGRectMake(0, self.view.bounds.size.height-128, self.view.bounds.size.width, 128) open:YES showHandle:NO draggable:NO tappable:NO delegate:self];
    
    [self.view addSubview:self.mediaView];
    [self.view addSubview:self.optionsCollapseView];
}

- (void) passTapToOptions:(UITapGestureRecognizer *)r
{
    [self.optionsCollapseView handleTapped:r];
}

- (void) loadOptionsForNpc:(Npc *)n afterViewingOption:(NpcScriptOption *)o
{
    [delegate optionsRequestsTitle:self.playerTitle];
    [[AppServices sharedAppServices] fetchNpcConversations:n.npcId afterViewingNode:o.nodeId];
    [self showWaitingIndicatorForPlayerOptions];
}

- (void) optionsReceivedFromNotification:(NSNotification*)notification
{
    [self dismissWaitingIndicatorForPlayerOptions];
	[self showPlayerOptions:(NSArray*)[notification object]];
}

- (void) showPlayerOptions:(NSArray *)options
{
    self.optionList = [options sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"hasViewed" ascending:YES]]];
    [self.optionsTableView reloadData];
}

- (void) showWaitingIndicatorForPlayerOptions
{
    if(!self.loadingIndicator)
    {
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.loadingIndicator.center = self.optionsTableView.center;
    }
    self.optionsTableView.hidden = YES;
    [self.optionsTableView addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
}

- (void) dismissWaitingIndicatorForPlayerOptions
{
    [self.loadingIndicator removeFromSuperview];
	[self.loadingIndicator stopAnimating];
    self.optionsTableView.hidden = NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    int sections = 0;
    if([self.optionList count] > 0)             sections++;
    if(!currentlyHidingLeaveConversationButton) sections++;
    return sections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0 && [optionList count] > 0)
        return [optionList count];
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self.optionsTableView dequeueReusableCellWithIdentifier:@"Dialog"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Dialog"];
    
    cell.backgroundColor         = [UIColor clearColor];
    cell.textLabel.textColor     = [UIColor blackColor];
    cell.textLabel.font          = [UIFont boldSystemFontOfSize:kOptionsFontSize];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.numberOfLines = 0;

    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
	if(indexPath.section == 0 && [optionList count] > 0)
    {
		NpcScriptOption *option = [optionList objectAtIndex:indexPath.row];
        if(option.hasViewed)
            cell.textLabel.textColor = [UIColor ARISColorLightGrey];
        cell.textLabel.text = option.optionText;
	}
	else
		cell.textLabel.text = self.currentLeaveConversationTitle;
    
	[cell.textLabel sizeToFit]; 

	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1 || [optionList count] == 0) return 45; //Leave conversation button

	NpcScriptOption *option = [optionList objectAtIndex:indexPath.row];

    CGSize maximumLabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50,9999);
    CGSize expectedLabelSize = [option.optionText sizeWithFont:[UIFont boldSystemFontOfSize:kOptionsFontSize] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
	
	return expectedLabelSize.height+25;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if(indexPath.section == 1 || [optionList count] == 0)
        [delegate leaveConversationRequested];
    else
    {
        NpcScriptOption *selectedOption = [optionList objectAtIndex:[indexPath row]];
        selectedOption.scriptText = [[AppModel sharedAppModel] nodeForNodeId:selectedOption.nodeId].text;
        [delegate optionChosen:selectedOption];
    }
}

- (void) toggleNextTextBoxSize
{
    [delegate optionsRequestsTextBoxSize:(textBoxSizeState+1)%3];
}

- (void) toggleTextBoxSize:(int)s
{
    textBoxSizeState = s;
    
    CGRect newFrame;
    switch(textBoxSizeState)
    {
        case 0: newFrame = CGRectMake(0, self.view.bounds.size.height    , 320,                            1); break;
        case 1: newFrame = CGRectMake(0, self.view.bounds.size.height-128, 320,                          128); break;
        case 2: newFrame = CGRectMake(0,                                0, 320, self.view.bounds.size.height); break;
    }
    
	[UIView beginAnimations:@"toggleTextSize" context:nil];
	[UIView setAnimationDuration:0.5];
	self.optionsTableView.frame  = newFrame;
	[UIView commitAnimations];
}

- (void) setDefaultTitle:(NSString *)t
{
    self.playerTitle = t;
}

- (void) setShowLeaveConversationButton:(BOOL)s
{
    self.currentlyHidingLeaveConversationButton = !s;
}

- (void) setLeaveConversationTitle:(NSString *)t
{
    self.currentLeaveConversationTitle = t;
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    //No need to do anything
}

@end
