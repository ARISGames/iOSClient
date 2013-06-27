//
//  aris_conversationViewController.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//

#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AppServices.h"
#import "AsyncMediaImageView.h"
#import "NpcViewController.h"
#import "Media.h"
#import "Node.h"
#import "Scene.h"
#import "DialogScript.h"
#import "ARISMoviePlayerViewController.h"
#import "Panoramic.h"
#import "PanoramicViewController.h"
#import "WebPage.h"
#import "WebPageViewController.h"
#import "Item.h"
#import "NodeViewController.h"
#import "ItemViewController.h"
#import "NodeOption.h"

#import "SceneParser.h"
#import "AsyncMediaImageView.h"
#import "Node.h"
#import "Npc.h"

#import "StateControllerProtocol.h"
#import "UIColor+ARISColors.h"

const NSInteger kOptionsFontSize = 17;

NSString *const kDialogHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: transparent;"
@"		color: #FFFFFF;"
@"		font-size: 19px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      text-align: center;"
@"      margin:0;"
@"      padding:0;"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

/*
 SAMPLE DIALOG FORMAT
 NSString *xmlData =
 @"<dialog>"
 @"<pc bgSound='1'>Tell me more.</pc>"
 @"<pc zoomX='130' zoomY='35' zoomWidth='50' zoomHeight='71.875'><![CDATA[I'm really interested.]]></pc>"
 @"<npc fgSound='2' id='1'><![CDATA[<p>So a man walks into a bar.</p>]]></npc>"
 @"<npc id='2'><![CDATA[<p>This is the good part.</p>]]></npc>"
 @"<npc bgSound='-2' id='1'><![CDATA[<p><strong>Quiet!</strong></p><p>Anyway, he says ouch.</p>]]></npc>"
 @"<npc id='2' zoomX='150' zoomY='50' zoomWidth='100' zoomHeight='100'><![CDATA[<p><strong>OUCH!</strong></p><p>Ha ha ha!</p>]]></npc>"
 @"</dialog>";
 */

@interface NpcViewController() <SceneParserDelegate, AsyncMediaImageViewDelegate, GameObjectViewControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate, AVAudioPlayerDelegate>
{
    SceneParser *parser;
    DialogScript *currentScript;
    Scene *currentScene;

    UIBarButtonItem	*textSizeButton;
	
	AsyncMediaImageView *currentImageView;
	
    int currentPcMediaId;
    BOOL currentlyHidingLeaveConversationButton;
    NSString *currentLeaveConversationTitle;
	NSString *defaultPcTitle;
    
	NSArray *optionList;
    
	int textboxSizeState;
    BOOL closingScriptPlaying;
    
    AVAudioPlayer *audioPlayer;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    
    UITableViewController *pcOptionsTableViewController;
    UIActivityIndicatorView *pcLoadingIndicator;
    UIActivityIndicatorView *waiting;
    
    IBOutlet UIView	*pcView;
    IBOutlet UIScrollView *pcImageSection;
    IBOutlet AsyncMediaImageView *pcImageView;
	IBOutlet UIScrollView *pcTextSection;
    IBOutlet UIWebView *pcTextWebView;
    IBOutlet UITableView *pcOptionsTable;
    IBOutlet UIButton *pcTapToContinueButton;
    
	IBOutlet UIView	*npcView;
    IBOutlet UIScrollView *npcImageSection;
	IBOutlet AsyncMediaImageView *npcImageView;
    IBOutlet UIScrollView *npcVideoView;
	IBOutlet UIScrollView *npcTextSection;
    IBOutlet UIWebView *npcTextWebView;
	IBOutlet UIButton *npcTapToContinueButton;
    
    id<GameObjectViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@property (nonatomic, strong) IBOutlet UIView *pcView;
@property (nonatomic, strong) IBOutlet UIScrollView *pcImageSection;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *pcImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *pcTextSection;
@property (nonatomic, strong) IBOutlet UIWebView *pcTextWebView;
@property (nonatomic, strong) IBOutlet UITableView *pcOptionsTable;
@property (nonatomic, strong) IBOutlet UIButton *pcTapToContinueButton;

@property (nonatomic, strong) IBOutlet UIView *npcView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcImageSection;
@property (nonatomic, strong) IBOutlet AsyncMediaImageView *npcImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcVideoView;
@property (nonatomic, strong) IBOutlet UIScrollView *npcTextSection;
@property (nonatomic, strong) IBOutlet UIWebView *npcTextWebView;
@property (nonatomic, strong) IBOutlet UIButton *npcTapToContinueButton;
@property (nonatomic, strong) AsyncMediaImageView *currentImageView;

- (IBAction)continueButtonTouchAction;

@end

@implementation NpcViewController

@synthesize pcView;
@synthesize pcImageSection;
@synthesize pcImageView;
@synthesize pcTextSection;
@synthesize pcTextWebView;
@synthesize pcOptionsTable;
@synthesize pcTapToContinueButton;

@synthesize npcView;
@synthesize npcImageSection;
@synthesize npcImageView;
@synthesize npcVideoView;
@synthesize npcTextSection;
@synthesize npcTextWebView;
@synthesize npcTapToContinueButton;


@synthesize currentNpc;
@synthesize currentNode;

@synthesize currentImageView;

- (id) initWithNpc:(Npc *)n delegate:(id<GameObjectViewControllerDelegate, StateControllerProtocol>)d
{
    if((self = [super initWithNibName:@"NpcViewController" bundle:nil]))
    {
        delegate = d;
        currentNpc = n;
        
        parser = [[SceneParser alloc] initWithDelegate:self];
        
        currentNode  = nil;
        textboxSizeState = 1;
        closingScriptPlaying  = NO;
        
        currentPcMediaId = 0;
        if     ([AppModel sharedAppModel].currentGame.pcMediaId != 0) currentPcMediaId = [AppModel sharedAppModel].currentGame.pcMediaId;
        else if([AppModel sharedAppModel].player.playerMediaId  != 0) currentPcMediaId = [AppModel sharedAppModel].player.playerMediaId;

        defaultPcTitle                = NSLocalizedString(@"DialogPlayerName",@"");
        currentLeaveConversationTitle = NSLocalizedString(@"DialogEnd",@"");
        currentlyHidingLeaveConversationButton = NO;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(optionsReceivedFromNotification:) name:@"ConversationNodeOptionsReady"  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetTextBoxSize)                 name:@"MovieForcedRotationToPortrait" object:nil];
    }
	
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.pcImageView.delegate = self;
    self.npcImageView.delegate = self;
    
    pcImageSection.contentSize  = pcImageSection.frame.size;
    npcImageSection.contentSize = npcImageSection.frame.size;
    
	pcOptionsTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	pcOptionsTableViewController.view = pcOptionsTable;
    
    pcLoadingIndicator.frame = CGRectMake(130, 300, 50, 50);
    
	[npcTapToContinueButton setTitle:NSLocalizedString(@"DialogContinue",@"") forState:UIControlStateNormal];
	[pcTapToContinueButton  setTitle:NSLocalizedString(@"DialogContinue",@"") forState:UIControlStateNormal];
    npcTapToContinueButton.backgroundColor = [UIColor ARISColorOffWhite];
    pcTapToContinueButton.backgroundColor = [UIColor ARISColorOffWhite];
    [npcTapToContinueButton setFrame:CGRectMake(0, 20, 320, 45)];
    npcTapToContinueButton.layer.cornerRadius = 10.0f;
    [pcTapToContinueButton setFrame:CGRectMake(0, 20, 320, 45)];
    pcTapToContinueButton.layer.cornerRadius = 10.0f;
    
	textSizeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textToggle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleNextTextBoxSize)];
	self.navigationItem.rightBarButtonItem = textSizeButton;

	if(currentPcMediaId != 0)   [self.pcImageView loadMedia:[[AppModel sharedAppModel] mediaForMediaId:currentPcMediaId ofType:@"PHOTO"]];
	else                        [self.pcImageView updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
    if(currentNpc.mediaId != 0) [self.npcImageView loadMedia:[[AppModel sharedAppModel] mediaForMediaId:currentNpc.mediaId ofType:nil]];
    else                        [self.npcImageView updateViewWithNewImage:[UIImage imageNamed:@"npc.png"]];
    
    if([[self.currentNpc.greeting stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])
        [self loadPlayerOptions];
    else
        [parser parseText:self.currentNpc.greeting];
    
    [self toggleTextBoxSize:textboxSizeState];
}

- (void) didFinishParsing:(DialogScript *)s
{
    currentScript = s;
    if(currentScript.hideLeaveConversationButtonSpecified) currentlyHidingLeaveConversationButton = currentScript.hideLeaveConversationButton;
    if(currentScript.leaveConversationButtonTitle)         currentLeaveConversationTitle          = currentScript.leaveConversationButtonTitle;
    if(currentScript.defaultPcTitle)                       defaultPcTitle                         = currentScript.defaultPcTitle;
    if(currentScript.adjustTextArea)                       [self adjustTextArea:currentScript.adjustTextArea];
    [self readySceneForDisplay:[currentScript nextScene]];
}

- (void) readySceneForDisplay:(Scene *)s
{
    currentScene = s;
    if(!currentScene){ [self scriptEnded]; return; }
    
    pcOptionsTable.hidden = YES;
    pcTextWebView.hidden  = NO;

    if(([currentScene.sceneType isEqualToString:@"pc"]  && pcView.frame.origin.x  == 0) ||
       ([currentScene.sceneType isEqualToString:@"npc"] && npcView.frame.origin.x == 0))
    {
        [UIView beginAnimations:@"dialog" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(displaySceneAfterReady)];
        pcTextWebView.alpha  = 0;
        npcTextWebView.alpha = 0;
        [UIView commitAnimations];
    }
    else
        [self moveAllOutWithPostSelector:@selector(displaySceneAfterReady)];
}

- (void) displaySceneAfterReady
{
    if(currentScene.vibrate) [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) vibrate];
    
    if([currentScene.sceneType isEqualToString:@"pc"] || [currentScene.sceneType isEqualToString:@"npc"])
    {
        if(currentScene.adjustTextArea) [self adjustTextArea:currentScene.adjustTextArea];
        
        UIView       *currentCharacterView;
        UIScrollView *currentCharacterImageSection;
        UIScrollView *currentCharacterTextSection;
        UIWebView    *currentCharacterTextWebView;
        UIButton *continueButton;
        
        if([currentScene.sceneType isEqualToString:@"pc"])
        {
            if(currentScene.title) self.title = currentScene.title;
            else                   self.title = defaultPcTitle;
            
            currentCharacterView         = pcView;
            currentCharacterImageSection = pcImageSection;
            currentCharacterTextSection  = pcTextSection;
            currentCharacterTextWebView  = pcTextWebView;
            
            self.currentImageView = self.pcImageView;
            continueButton = pcTapToContinueButton;
        }
        else if([currentScene.sceneType isEqualToString:@"npc"])
        {
            if (currentScene.title) self.title = currentScene.title;
            else                    self.title = currentNpc.name;
                        
            currentCharacterView         = npcView;
            currentCharacterImageSection = npcImageSection;
            currentCharacterTextSection  = npcTextSection;
            currentCharacterTextWebView  = npcTextWebView;
            
            self.currentImageView = self.npcImageView;
            continueButton = npcTapToContinueButton;
        }
        
        if(currentScene.mediaId != 0)
        {
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:currentScene.mediaId ofType:@"PHOTO"];//if it can't find a media, assume it is a photo
            //TEMPORARY BANDAID 
            if(self.currentImageView.isLoading)
            {
                [self.currentImageView removeFromSuperview];
                self.currentImageView = [[AsyncMediaImageView alloc] initWithFrame:self.currentImageView.frame andMedia:media];
                if(self.currentImageView == self.npcImageView)
                    [npcImageSection addSubview:self.currentImageView];
                else if(self.currentImageView == self.pcImageView)
                    [pcImageSection addSubview:self.currentImageView];
            }
            //END TEMPORARY BANDAID
            if(!media.type) [self.currentImageView loadMedia:media]; // This should never happen (all game media should be cached by now)
            else if([media.type isEqualToString:@"PHOTO"]) [self.currentImageView loadMedia:media];
            else if([media.type isEqualToString:@"VIDEO"]) [self playAudioOrVideoFromMedia:media andHidden:NO];
            else if([media.type isEqualToString:@"AUDIO"]) [self playAudioOrVideoFromMedia:media andHidden:YES];
        }
        else
        {
            if([currentScene.sceneType isEqualToString:@"pc"])
            {
                if(currentPcMediaId != 0)   [self.pcImageView loadMedia:[[AppModel sharedAppModel] mediaForMediaId:currentPcMediaId ofType:nil]];
                else                        [self.pcImageView updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
            }
            else
            {
                if(currentNpc.mediaId != 0) [self.npcImageView loadMedia:[[AppModel sharedAppModel] mediaForMediaId:currentNpc.mediaId ofType:nil]];
                else                        [self.npcImageView updateViewWithNewImage:[UIImage imageNamed:@"npc.png"]];
            }
        }
        
        if(closingScriptPlaying)
        {
            [pcTapToContinueButton setTitle:currentLeaveConversationTitle forState: UIControlStateNormal];
            [pcTapToContinueButton setTitle:currentLeaveConversationTitle forState: UIControlStateHighlighted];
        }
        
        //Try resetting the text view height to 0 each time for proper content height calculation
        CGRect webViewFrame = [currentCharacterTextWebView frame];
        webViewFrame.size = CGSizeMake(webViewFrame.size.width,10);
        [currentCharacterTextWebView setFrame:webViewFrame];
        
        //Reset it's scroll view
        [currentCharacterTextSection setContentOffset:CGPointMake(0, 0) animated:NO];
        
        //Load content
        [currentCharacterTextWebView loadHTMLString:[NSString stringWithFormat:kDialogHtmlTemplate, currentScene.text] baseURL:nil];
        
        continueButton.hidden = NO;
        
        if(!currentCharacterView.frame.origin.x == 0)
        {
            if     ([currentScene.sceneType isEqualToString:@"pc"])  [self movePcIn];
            else if([currentScene.sceneType isEqualToString:@"npc"]) [self moveNpcIn];
        }
        
        CGRect imageFrame = self.currentImageView.frame;
        [UIView animateWithDuration:currentScene.zoomTime animations:^
        {
            currentCharacterImageSection.frame = CGRectMake(currentScene.imageRect.origin.x*-1, currentScene.imageRect.origin.y*-1,
                                                            currentScene.imageRect.size.width*currentScene.imageRect.size.width/imageFrame.size.width,
                                                            currentScene.imageRect.size.height*currentScene.imageRect.size.height/imageFrame.size.height);
        }];
        currentImageView.frame = imageFrame; //To prevent animation from changing it...
    }
    else
    {
        if([currentScene.sceneType isEqualToString:@"video"])
        {
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:currentScene.typeId ofType:@"VIDEO"];
            ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            mMoviePlayer.moviePlayer.shouldAutoplay = YES;
            [mMoviePlayer.moviePlayer prepareToPlay];
            [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
            [self continueButtonTouchAction];
        }
        else if([currentScene.sceneType isEqualToString:@"panoramic"])
            [self.navigationController pushViewController:[[[AppModel sharedAppModel] panoramicForPanoramicId:currentScene.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
        else if([currentScene.sceneType isEqualToString:@"webpage"])
            [self.navigationController pushViewController:[[[AppModel sharedAppModel] webPageForWebPageID:currentScene.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
        else if([currentScene.sceneType isEqualToString:@"node"])
            [self.navigationController pushViewController:[[[AppModel sharedAppModel] nodeForNodeId:currentScene.typeId] viewControllerForDelegate:self fromSource:self] animated:YES];
        else if([currentScene.sceneType isEqualToString:@"item"])
        {
            ItemViewController *itemVC = (ItemViewController *)[[[AppModel sharedAppModel] itemForItemId:currentScene.typeId] viewControllerForDelegate:self fromSource:self];
            itemVC.item.qty = 1;
            [self.navigationController pushViewController:itemVC animated:YES];
        }
        [self continueButtonTouchAction];
    }
}

- (void) gameObjectViewControllerRequestsDismissal:(GameObjectViewController *)govc
{
    [self.navigationController popToViewController:govc animated:NO];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    UIScrollView *textSection;
	UIButton *continueButton;
	
	if(webView == pcTextWebView)
    {
        textSection    = pcTextSection;
		continueButton = pcTapToContinueButton;
	}
	else if(webView == npcTextWebView)
    {
        textSection    = npcTextSection;
        continueButton = npcTapToContinueButton;
	}
    
	//Size the webView
	CGRect newWebViewFrame = [webView frame];
	float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
	newWebViewFrame.size = CGSizeMake(newWebViewFrame.size.width, newHeight);
	[webView setFrame:newWebViewFrame];
	[[[webView subviews] lastObject] setScrollEnabled:NO]; //Disable scrolling in webview
    
	//position the continue button
	CGRect continueButtonFrame = [continueButton frame];
	continueButtonFrame.origin = CGPointMake(continueButtonFrame.origin.x, newWebViewFrame.origin.y+newWebViewFrame.size.height+5);
	[continueButton setFrame:continueButtonFrame];
	
	//Size the scroll view's content
	textSection.contentSize = CGSizeMake(textSection.contentSize.width, continueButtonFrame.origin.y + continueButtonFrame.size.height + 30);
    
    //Fade in the WebView
    [textSection setContentOffset:CGPointMake(0, 0) animated:NO];
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    webView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void) imageFinishedLoading:(AsyncMediaImageView *)image 
{
    //ASPECT FIT + ALIGN TO TOP:
    //Let 'aspect fit' do the actual aspect fit- but still required to simulate the fitting to get correct dimensions
    image.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].applicationFrame.size.height-44);

    float sw = image.frame.size.width;  //screen width (320)
    float sh = image.frame.size.height; //screen height(416)
    float iw = image.image.size.width;  //image width  (like, the raw image size. example:1024)
    float ih = image.image.size.height; //image height (like, the raw image size. example:768)

    float dw = iw;                      //display width  (calculated size of image AFTER aspect fit)
    float dh = ih;                      //display height (calculated size of image AFTER aspect fit)
    if(ih < sh && iw < sw)              //simulate scale up to aspect fit if necessary
    {
        if(ih > iw)
        {
            dh = sh;
            dw = sh/ih*iw;
        }
        else
        {
            dh = sw/iw*ih;
            dw = sw;
        }
    }
    
    if(dw > sw)
    {
        dw = sw;
        dh = ih*sw/iw;
    }
    if(dh > sh)
    {
        dh = sh;
        dw = iw*sh/ih;
    }

    if(dh < sh)
        image.frame = CGRectMake(0, (-0.5*(sh-dh)), image.frame.size.width, image.frame.size.height);
    else
        image.frame = CGRectMake(0,0,sw,sh);
}

- (void) scriptEnded
{
    if(closingScriptPlaying == YES || currentScript.exitToType)
    {
        [[AppServices sharedAppServices] updateServerNodeViewed:currentNode.nodeId fromLocation:0];
        [self dismissSelf];
        
        if([currentScript.exitToType isEqualToString:@"tab"])
            [delegate displayTab:currentScript.exitToTabTitle];
        else if([currentScript.exitToType isEqualToString:@"plaque"])
            [delegate displayGameObject:[[AppModel sharedAppModel] nodeForNodeId:currentScript.exitToTypeId] fromSource:self];
        else if([currentScript.exitToType isEqualToString:@"webpage"])
            [delegate displayGameObject:[[AppModel sharedAppModel] webPageForWebPageID:currentScript.exitToTypeId] fromSource:self];
        else if([currentScript.exitToType isEqualToString:@"item"])
            [delegate displayGameObject:[[AppModel sharedAppModel] itemForItemId:currentScript.exitToTypeId] fromSource:self];
        else if([currentScript.exitToType isEqualToString:@"character"])
            [delegate displayGameObject:[[AppModel sharedAppModel] npcForNpcId:currentScript.exitToTypeId] fromSource:self];
        else if([currentScript.exitToType isEqualToString:@"panoramic"])
            [delegate displayGameObject:[[AppModel sharedAppModel] panoramicForPanoramicId:currentScript.exitToTypeId] fromSource:self];
    }
    else
        [self loadPlayerOptions];
}

- (void) loadPlayerOptions
{
    [[AppServices sharedAppServices] fetchNpcConversations:self.currentNpc.npcId afterViewingNode:currentNode.nodeId];
    [self showWaitingIndicatorForPlayerOptions];
}

- (void) optionsReceivedFromNotification:(NSNotification*)notification
{
    [self dismissWaitingIndicatorForPlayerOptions];
	[self showPlayerOptions:(NSArray*)[notification object]];
}

- (void) showPlayerOptions:(NSArray *)options
{
    currentNode = nil;
    
    if([options count] == 0 && [currentNpc.closing length] > 1)
    {
        closingScriptPlaying = YES;
        [parser parseText:currentNpc.closing];
    }
    else
    {
        pcTapToContinueButton.hidden = YES;
        pcTextWebView.hidden  = YES;
        [pcTextWebView loadHTMLString:@"" baseURL:nil];
        pcOptionsTable.hidden = NO;

        if(!pcView.frame.origin.x  == 0)
            [self moveAllOutWithPostSelector:@selector(movePcIn)];

        self.currentImageView = self.pcImageView;
        
        self.title = defaultPcTitle;
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hasViewed" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        optionList = [options sortedArrayUsingDescriptors:sortDescriptors];
		[pcOptionsTable reloadData];
	}
}

- (void) showWaitingIndicatorForPlayerOptions
{
    pcTextWebView.hidden  = YES;
    [pcTextWebView loadHTMLString:@"" baseURL:nil];
    pcOptionsTable.hidden = NO;
    [self.view addSubview:pcLoadingIndicator];
    [pcLoadingIndicator startAnimating];
}

- (void) dismissWaitingIndicatorForPlayerOptions
{
    [pcLoadingIndicator removeFromSuperview];
	[pcLoadingIndicator stopAnimating];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}

- (void) dismissSelf
{
    [[AppServices sharedAppServices] updateServerNpcViewed:currentNpc.npcId fromLocation:0];
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (IBAction) continueButtonTouchAction
{
    [ARISMoviePlayer.moviePlayer.view removeFromSuperview];
    [self.npcVideoView removeFromSuperview];
    [ARISMoviePlayer.moviePlayer stop];
    [waiting stopAnimating];
    [waiting removeFromSuperview];
    
    if(audioPlayer.isPlaying) [audioPlayer stop];
    
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    audioPlayer = nil;
    
    [self readySceneForDisplay:[currentScript nextScene]];
}

- (void) movePcTo:(CGRect)pcRect  withAlpha:(CGFloat)pcAlpha
		 andNpcTo:(CGRect)npcRect withAlpha:(CGFloat)npcAlpha
 withPostSelector:(SEL)aSelector
{
	[UIView beginAnimations:@"movement" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:aSelector];
	npcView.frame = npcRect;
	npcView.alpha = npcAlpha;
	pcView.frame = pcRect;
	pcView.alpha = pcAlpha;
	[UIView commitAnimations];
}

- (void) moveAllOutWithPostSelector:(SEL)postSelector
{
	[self movePcTo:CGRectMake( 160, 0, 320, [UIScreen mainScreen].applicationFrame.size.height-44) withAlpha:0.0
		  andNpcTo:CGRectMake(-160, 0, 320, [UIScreen mainScreen].applicationFrame.size.height-44) withAlpha:0.0
  withPostSelector:postSelector];
}

- (void) movePcIn
{
	[self movePcTo:[self.view frame] withAlpha:1.0
		  andNpcTo:[npcView frame]   withAlpha:[npcView alpha]
  withPostSelector:nil];
}

- (void) moveNpcIn
{
	[self movePcTo:[pcView frame]    withAlpha:[pcView alpha]
		  andNpcTo:[self.view frame] withAlpha:1.0
  withPostSelector:nil];
}

- (void) toggleNextTextBoxSize
{
    [self toggleTextBoxSize:(textboxSizeState+1)%3];
}

- (void)resetTextBoxSize
{
    [self toggleTextBoxSize:0];
}

-(void) toggleTextBoxSize:(int)mode
{
    textboxSizeState = mode;
    
    CGRect newTextFrame;
    int screenHeight = [UIScreen mainScreen].applicationFrame.size.height-44;
    switch(textboxSizeState)
    {
        case 0: newTextFrame = CGRectMake(0, screenHeight    , 320,            1); break;
        case 1: newTextFrame = CGRectMake(0, screenHeight-128, 320,          128); break;
        case 2: newTextFrame = CGRectMake(0,                0, 320, screenHeight); break;
    }
    
	[UIView beginAnimations:@"toggleTextSize" context:nil];
	[UIView setAnimationDuration:0.5];
	self.pcTextSection.frame  = newTextFrame;
    self.npcTextSection.frame = newTextFrame;
	self.pcOptionsTable.frame = self.pcTextSection.bounds;
    self.pcTextSection.contentSize = self.pcOptionsTable.frame.size;
	[UIView commitAnimations];
}

- (void) hideAdjustTextAreaButton:(BOOL)hide
{
    if(hide) self.navigationItem.rightBarButtonItem = nil;
    else     self.navigationItem.rightBarButtonItem = textSizeButton;
}

-(void) adjustTextArea:(NSString *)area
{
    if([area isEqualToString:@"hidden"]){   [self toggleTextBoxSize:0]; [self hideAdjustTextAreaButton:NO]; }
    else if([area isEqualToString:@"half"]) [self toggleTextBoxSize:1];
    else if([area isEqualToString:@"full"]) [self toggleTextBoxSize:2];
}

- (void) playAudioOrVideoFromMedia:(Media*)media andHidden:(BOOL)hidden
{
    if(media.image != nil && [media.type isEqualToString:@"AUDIO"]) //worked before added type check, not sure how
    {
        NSLog(@"NpcViewController: Playing through AVAudioPlayer");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        NSError* err;
        audioPlayer = [[AVAudioPlayer alloc] initWithData: media.image error:&err];
        [audioPlayer setDelegate: self];
        
        if(err) NSLog(@"NpcViewController: Playing Audio: Failed with reason: %@", [err localizedDescription]);
        else [audioPlayer play];
    }
    else
    {
        NSLog(@"NpcViewController: Playing through MPMoviePlayerController");
        ARISMoviePlayer.moviePlayer.view.hidden = hidden; 
        if(!ARISMoviePlayer) ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
        ARISMoviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [ARISMoviePlayer.moviePlayer setContentURL: [NSURL URLWithString:media.url]];
        [ARISMoviePlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [ARISMoviePlayer.moviePlayer setFullscreen:NO];
        [ARISMoviePlayer.moviePlayer prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChangeNotification: ) name:MPMoviePlayerLoadStateDidChangeNotification object:ARISMoviePlayer.moviePlayer];
        waiting = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waiting.center = self.view.center;
        waiting.hidesWhenStopped = YES;
        [self.view addSubview:waiting];
        [waiting startAnimating];
        if(!hidden)
        {
            ARISMoviePlayer.view.frame = npcVideoView.frame;
            self.npcVideoView = (UIScrollView *)ARISMoviePlayer.view;
            self.npcVideoView.hidden = NO;
            [self.npcView insertSubview:npcVideoView atIndex: 1];
            self.npcImageView.hidden = YES;
        }
    }
}

- (void) MPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif
{
    if (ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStateStalled)
    {
        [waiting startAnimating];
        [ARISMoviePlayer.moviePlayer pause];
    }
    else if (ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStatePlayable)
    {
        [waiting stopAnimating];
        [ARISMoviePlayer.moviePlayer play];
        [waiting removeFromSuperview];
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(currentlyHidingLeaveConversationButton)
        return 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0)
        return [optionList count];
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [pcOptionsTable dequeueReusableCellWithIdentifier:@"Dialog"];
	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Dialog"];
    
	if (indexPath.section == 0)
    {
		NodeOption *option = [optionList objectAtIndex:indexPath.row];
        cell.textLabel.text = option.text;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kOptionsFontSize];
        [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
        if(option.hasViewed)
        {
            cell.backgroundColor     = [UIColor ARISColorOffWhite];
            cell.textLabel.textColor = [UIColor ARISColorDarkBlue];
        }
        else
            cell.textLabel.textColor = [UIColor ARISColorDarkBlue];
	}
	else if (indexPath.row == 0)
    {
		cell.textLabel.text = currentLeaveConversationTitle;
        cell.textLabel.textColor = [UIColor ARISColorDarkBlue];
	}
	
    cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.textLabel.minimumFontSize = kOptionsFontSize;
	
	cell.textLabel.numberOfLines = 0;
	[cell.textLabel sizeToFit]; 

	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 1) return 45;

	NodeOption *option = [optionList objectAtIndex:indexPath.row];

	CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 50;
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
	
    CGSize expectedLabelSize = [option.text sizeWithFont:[UIFont boldSystemFontOfSize:kOptionsFontSize] 
									   constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
	
	return expectedLabelSize.height + 25;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor ARISColorOffWhite];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if (indexPath.section == 1 && indexPath.row == 0)
    {
		[self dismissSelf];
        return;
    }
	
	NodeOption *selectedOption = [optionList objectAtIndex:[indexPath row]];
	Node *newNode = [[AppModel sharedAppModel] nodeForNodeId:selectedOption.nodeId];

	currentNode = newNode;
    if(newNode.text.length == 0)
    {
        [self loadPlayerOptions];
        return;
    }
    
    pcOptionsTable.hidden = YES;
    pcTextWebView.hidden  = YES;
    [parser parseText:newNode.text];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.currentImageView;
}

- (void)dealloc
{
    pcTextWebView.delegate = nil;
    [pcTextWebView stopLoading];
    npcTextWebView.delegate = nil;
    [npcTextWebView stopLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
