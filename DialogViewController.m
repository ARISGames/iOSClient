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
#import "DialogViewController.h"
#import "Media.h"
#import "Node.h"
#import "Scene.h"
#import "ARISMoviePlayerViewController.h"
#import "Panoramic.h"
#import "PanoramicViewController.h"
#import "WebPage.h"
#import "webpageViewController.h"
#import "Item.h"
#import "NodeViewController.h"
#import "ItemDetailsViewController.h"

const NSInteger kStartingIndex = 0;
const NSInteger kMaxOptions = 20;
const NSInteger kOptionsFontSize = 17;
NSString *const kOutAnimation = @"out";
NSString *const kInAnimation = @"in";

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


@interface DialogViewController()
- (void) loadCharacterImage:(NSInteger)mediaId withPriorId:(NSInteger *)priorId 
					 inView:(AsyncMediaImageView *)aView;
- (void) movePcIn;
- (void) moveNpcIn;
- (void) moveAllOutWithPostSelector:(SEL)postSelector;
- (void) movePcTo:(CGRect)pcRect withAlpha:(CGFloat)pcAlpha 
		 andNpcTo:(CGRect)npcRect withAlpha:(CGFloat)npcAlpha 
 withPostSelector:(SEL)aSelector;
- (void) applyScene:(Scene *)aScene;

@end


@implementation DialogViewController
@synthesize npcImage, pcImage, npcWebView, pcWebView, pcTableView,exitToTabVal;
@synthesize npcScrollView, pcScrollView, npcImageScrollView, pcImageScrollView, pcActivityIndicator;
@synthesize npcContinueButton, pcContinueButton, textSizeButton, specialBackButton;
@synthesize pcAnswerView, mainView, npcView, pcView, nothingElseLabel,lbl,currentNpc,currentNode, npcVideoView;
@synthesize player, ARISMoviePlayer;
@synthesize closingScriptPlaying, textboxSize;
@synthesize waiting;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(optionsRecievedFromNotification:)
													 name:@"ConversationNodeOptionsReady"
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixTextBox) name:@"MovieForcedRotationToPortrait" object:nil];
    }
	
    return self;
}

- (void)fixTextBox {
    self.textboxSize = 0;
    [self toggleFullScreenTextMode];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
		
    [RootViewController sharedRootViewController].modalPresent = YES;
	//General Setup
	lastPcId = 0;
	currentNode = nil;
	self.closingScriptPlaying = NO;
	self.textboxSize = 1;
    self.hideLeaveConversationButton = NO;
    self.exitToTabVal = nil;
	
    //View Setup
	npcImageScrollView.contentSize = [npcView frame].size;
	pcImageScrollView.contentSize = [pcView frame].size;
    
    self.pcScrollView.frame = CGRectMake(0, 332, 320, 128);
	
	[npcWebView setBackgroundColor:[UIColor clearColor]];	
	[pcWebView setBackgroundColor:[UIColor clearColor]];

	pcTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
	pcTableViewController.view = pcTableView;

	[npcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateNormal];
	[npcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateHighlighted];	
	[pcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateNormal];
	[pcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateHighlighted];	
	
    UIBarButtonItem *textSizeButtonAlloc = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textToggle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFullScreenTextMode)];  
	self.textSizeButton = textSizeButtonAlloc; 
	self.navigationItem.rightBarButtonItem = self.textSizeButton;
    
	pcAnswerView.hidden = YES;
	pcTableView.hidden = NO;
	pcWebView.hidden = NO;
    pcView.hidden = NO;
	pcActivityIndicator.hidden = YES;
    npcWebView.hidden = NO;
    npcView.hidden = NO;

    NSLog(@"pcMediaId == %d", [AppModel sharedAppModel].currentGame.pcMediaId);
	
	//Check if the game specifies a PC image
	if ([AppModel sharedAppModel].currentGame.pcMediaId != 0) {
		//Load the image from the media Table
        self.pcImage.delegate = self;

		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
		[pcImage loadImageFromMedia: pcMedia];
	}
	else {
        [pcImage updateViewWithNewImage:[UIImage imageNamed:@"DefaultPCImage.png"]];
        [self applyNPCWithGreeting];
	}
    
    NSNotificationCenter *dispatcher = [NSNotificationCenter defaultCenter];
    [dispatcher addObserver:self selector:@selector(hideNotifications:) name:@"hideNotifications" object:nil];
    
/*  SAMPLE DIALOG FORMAT
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
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.opaque = NO;
}

-(void)imageFinishedLoading{
    [self applyNPCWithGreeting];
}

-(void)toggleFullScreenTextMode{
	NSLog(@"DialogViewController: toggleTextSize");
    
    CGRect newTextFrame;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch(textboxSize){
        case 0:
           //text is off screen, move it on screen
            if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) newTextFrame = CGRectMake(0, 332, 320, 128);
            else{
                newTextFrame = CGRectMake(0, 216, 480, 84);
            }
            break;
        case 1:
            //textbox is normal size, make it full screen
            if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) newTextFrame = CGRectMake(0, 44, 320, 416);
            else{
                newTextFrame = CGRectMake(0, 44, 480, 300);
            }
            break;
        case 2:
            //text is full screen, move it off screen
            if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) newTextFrame = CGRectMake(0, 480, 320, 128);
            else {
              newTextFrame = CGRectMake(0, 320, 480, 128); 
            }
            break;
        default:
            //should never reach here
            break;
    }
	[UIView beginAnimations:@"toggleTextSize" context:nil];
	[UIView setAnimationDuration:0.5];
	self.pcScrollView.frame = newTextFrame;
	self.pcTableView.frame = self.pcScrollView.bounds;
    self.pcScrollView.contentSize = self.pcTableView.frame.size;
	self.npcScrollView.frame = newTextFrame;
	[UIView commitAnimations];
	
	if(self.textboxSize < 2) self.textboxSize++;
    else self.textboxSize = 0;
}

-(void)hideNotifications:(NSNotification*) notification {
    CGRect newTextFrame;
    newTextFrame = CGRectMake(0, 44, 320, 416);
    [UIView beginAnimations:@"toggleTextSize" context:nil];
    [UIView setAnimationDuration:0.0];
    if (self.textboxSize == 2) {
        self.pcScrollView.frame = newTextFrame;
        self.pcTableView.frame = self.pcScrollView.bounds;
        self.pcScrollView.contentSize = self.pcTableView.frame.size;
        self.npcScrollView.frame = newTextFrame;
    }
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
-(void)viewDidAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
 //   self.textboxSize = 0;
  //  [self toggleFullScreenTextMode];
}
- (void) viewDidDisappear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	NSLog(@"DialogViewController: View Did Disapear");
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"DialogViewController: Notify server of NPC view and Dismiss view");
	
    [RootViewController sharedRootViewController].modalPresent = NO;
	[[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
}

- (IBAction)continueButtonTouchAction{
    [self.ARISMoviePlayer.moviePlayer.view removeFromSuperview];
    [self.npcVideoView removeFromSuperview];
    [self.ARISMoviePlayer.moviePlayer stop];
    [self.waiting stopAnimating];
    [self.waiting removeFromSuperview];
    if(self.player.isPlaying){
      [self.player stop];
    }
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    self.player = nil;
    NSLog(@"Continue Button Pressed");
	[self continueScript];
}

- (void)reviewScript {
	if (currentScript != nil && scriptIndex <= [currentScript count]) {
		//We are midscript, go back one step
		scriptIndex = [currentScript count] - 1;
		[self continueScript];
	}
	else if (currentScript != nil && scriptIndex > [currentScript count]) {
		//We finished a script, replay from the begining
		scriptIndex = 0;
		[self continueScript];
	}
	else {
		//We must be right at the begining, load up the NPC again
		[self moveAllOutWithPostSelector:nil];
		[self applyNPCWithGreeting];
	}

}

- (IBAction)npcScrollerTouchAction{
	NSLog(@"DialogViewController: NPC ScrollView Touched");

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"DialogViewController: touchesBegan");
	
	[pcAnswerView resignFirstResponder];
	
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applyNPCWithGreeting{

    //tell the server
	[[AppServices sharedAppServices] updateServerNpcViewed:currentNpc.npcId fromLocation:currentNpc.locationId];
    
    NSString *string1 = currentNpc.greeting;
    NSString *trimmedString = [string1 stringByReplacingOccurrencesOfString:@" " withString:@""]; //remove whitespace
    if([trimmedString length] == 0)[self continueScript]; //if no greeting entered then go to closing screen
    if([trimmedString length] == 1) 
    currentNpc.greeting =   [trimmedString stringByAppendingString: @"\r"];
	[parser parseText:currentNpc.greeting];
    
    
}

- (void) beginWithNPC:(Npc *)aNpc {
	currentNpc = aNpc;
		
	parser = [[SceneParser alloc] initWithDefaultNpcIdWithDelegate: self];
}

- (void) loadNPCImage:(NSInteger)mediaId {
	[self loadCharacterImage:mediaId withPriorId:&lastNpcId inView:npcImage];
}

- (void) loadCharacterImage:(NSInteger)mediaId withPriorId:(NSInteger *)priorId 
					 inView:(AsyncMediaImageView *)aView 
{
	if (mediaId == *priorId) return;
	
	Media *characterMedia = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
	[aView loadImageFromMedia:characterMedia];
  //  UIImage *currentImage = [UIImage imageWithData:aView.media.image];
  //  if(currentImage.size.height == 416 && currentImage.size.width == 320){
  //      aView.frame = CGRectMake(0, 44, aView.frame.size.width, aView.frame.size.height);
  //  }
	[aView setNeedsDisplay];
	*priorId = mediaId;
}


- (void) continueScript {
    NSLog(@"DialogVC: continueScript");
    
	if (scriptIndex < [currentScript count]) { //Load up this scene of the script
        NSLog(@"DialogVC: continueScript: Scenes still exist, load the next one");

		Scene *currentScene = [currentScript objectAtIndex:scriptIndex];
        
        // display title for scene if specified
        
        if (currentScene.videoId !=0) {
            //Setup the Button
	
            Media *media = [[AppModel sharedAppModel] mediaForMediaId:currentScene.videoId];
            
            //Create movie player object
            ARISMoviePlayerViewController *mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
            mMoviePlayer.moviePlayer.shouldAutoplay = NO;
            [mMoviePlayer.moviePlayer prepareToPlay];		
            [self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
            
            ++scriptIndex;
            [self continueScript];
        }
        else if(currentScene.panoId !=0) {
          Panoramic *pano = [[AppModel sharedAppModel] panoramicForPanoramicId:currentScene.panoId];
            PanoramicViewController *panoramicViewController = [[PanoramicViewController alloc] initWithNibName:@"PanoramicViewController" bundle: [NSBundle mainBundle]];    
            panoramicViewController.panoramic = pano;
            panoramicViewController.delegate = self;
            
            [self.navigationController pushViewController:panoramicViewController animated:YES];
            
            ++scriptIndex;
            [self continueScript];
        }
        else if(currentScene.webId != 0) {
       
            webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
            webPageViewController.webPage = [[AppModel sharedAppModel] webPageForWebPageID:currentScene.webId];
            webPageViewController.delegate = self;
            [self.navigationController pushViewController:webPageViewController animated:YES];
            
            ++scriptIndex;
            [self continueScript];
        }
        else if(currentScene.plaqueId != 0){
            NodeViewController *nodeVC = [[NodeViewController alloc]initWithNibName:@"Node" bundle:[NSBundle mainBundle]];
            nodeVC.node = [[AppModel sharedAppModel] nodeForNodeId:currentScene.plaqueId];
            [self.navigationController pushViewController:nodeVC animated:YES];
            
            ++scriptIndex;
            [self continueScript];
        }
        else if(currentScene.itemId != 0){
            ItemDetailsViewController *itemVC = [[ItemDetailsViewController alloc]initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
            itemVC.item = [[AppModel sharedAppModel] itemForItemId:currentScene.itemId];
            [self.navigationController pushViewController:itemVC animated:YES];
            
            ++scriptIndex;
            [self continueScript];
        }
        
        else{
        [self applyScene:currentScene];
		++scriptIndex;
        }
	}
	else { 	//End of Script. Display Player Options
        NSLog(@"DialogVC: continueScript: No more scenes left. Checking for exitTo tags before loading options");
  
        if(cachedScene.exitToTabWithTitle) self.exitToTabVal = cachedScene.exitToTabWithTitle;
        
        //Check if this is a closing script or we are shutting down
        if(self.closingScriptPlaying==YES || (self.exitToTabVal != nil)) {
            [RootViewController sharedRootViewController].modalPresent = NO;
            [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
            [[AppServices sharedAppServices] updateServerNodeViewed:self.currentNode.nodeId fromLocation:self.currentNode.locationId];
        }
        
        //Check for exitToTab
        if (self.exitToTabVal != nil) {
            //TODO: Move this code into an app delegate method
            if([cachedScene.exitToType isEqualToString:@"tab"]){
                NSString *tab;
                for(int i = 0;i < [[RootViewController sharedRootViewController].tabBarController.viewControllers count];i++){
                    tab = [[[RootViewController sharedRootViewController].tabBarController.viewControllers objectAtIndex:i] title];
                    tab = [tab lowercaseString];
                    self.exitToTabVal = [self.exitToTabVal lowercaseString];
                    if([self.exitToTabVal isEqualToString:tab]) {
                        [RootViewController sharedRootViewController].tabBarController.selectedIndex = i;
                    }
                }
            }
            else if([cachedScene.exitToType isEqualToString:@"plaque"]){
                NodeViewController *nodeVC = [[NodeViewController alloc]initWithNibName:@"Node" bundle:[NSBundle mainBundle]];
                nodeVC.node = [[AppModel sharedAppModel] nodeForNodeId:[cachedScene.exitToTabWithTitle intValue]];
                [[RootViewController sharedRootViewController]displayNearbyObjectView:nodeVC];
     
            }
            else if([cachedScene.exitToType isEqualToString:@"webpage"]){
                webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
                webPageViewController.webPage = [[AppModel sharedAppModel] webPageForWebPageID:[cachedScene.exitToTabWithTitle intValue]];
                webPageViewController.delegate = self;
                [[RootViewController sharedRootViewController] displayNearbyObjectView:webPageViewController];
                
            }
            else if([cachedScene.exitToType isEqualToString:@"item"]){
                ItemDetailsViewController *itemVC = [[ItemDetailsViewController alloc]initWithNibName:@"ItemDetailsView" bundle:[NSBundle mainBundle]];
                itemVC.item = [[AppModel sharedAppModel] itemForItemId:[cachedScene.exitToTabWithTitle intValue]];                
                [[RootViewController sharedRootViewController] displayNearbyObjectView:itemVC];
            }
            else if([cachedScene.exitToType isEqualToString:@"character"]){
                DialogViewController *dialogVC = [[DialogViewController alloc] initWithNibName:@"Dialog" bundle:[NSBundle mainBundle]];
                [dialogVC beginWithNPC:[[AppModel sharedAppModel] npcForNpcId:[cachedScene.exitToTabWithTitle intValue]]];
                [[RootViewController sharedRootViewController] displayNearbyObjectView:dialogVC];
            }
            else if([cachedScene.exitToType isEqualToString:@"panoramic"]){
                Panoramic *pano = [[AppModel sharedAppModel] panoramicForPanoramicId:[cachedScene.exitToTabWithTitle intValue]];
                PanoramicViewController *panoramicViewController = [[PanoramicViewController alloc] initWithNibName:@"PanoramicViewController" bundle: [NSBundle mainBundle]];    
                panoramicViewController.panoramic = pano;
                [[RootViewController sharedRootViewController] displayNearbyObjectView:panoramicViewController];
            }
        }
        else{
            [self applyPlayerOptions];
        }
	}
}

- (void) applyPlayerOptions{	
	NSLog(@"DialogVC: Apply Player Options");
	++scriptIndex;
	
	// Display the appropriate question for the PC
	if ([currentNode.answerString length] > 0) {
        [self moveAllOutWithPostSelector:nil];
        [self movePcIn];
        
        pcWebView.hidden = YES;
        pcContinueButton.hidden = YES;
        pcTableView.hidden = YES;
		pcAnswerView.hidden = NO;
        
        cachedScrollView = pcImage;
        [pcImageScrollView zoomToRect:[pcImage frame] animated:NO];
        
        self.title = NSLocalizedString(@"DialogPlayerName",@"");
		
	}
	else {
		if (currentNode.numberOfOptions > 0) {
			//There are node options
            NSLog(@"DialogVC: Apply Player Options: Node Options Exist");

            [self moveAllOutWithPostSelector:nil];
            [self movePcIn];
            
            pcWebView.hidden = YES;
            pcContinueButton.hidden = YES;
            pcTableView.hidden = YES;
            
            cachedScrollView = pcImage;
            [pcImageScrollView zoomToRect:[pcImage frame] animated:NO];
            
            self.title = NSLocalizedString(@"DialogPlayerName",@"");
            [self finishApplyingPlayerOptions:currentNode.options];

		}
		else {
			//No node options, load the conversations
            NSLog(@"DialogVC: Apply Player Options: Load Conversations");

            [[AppServices sharedAppServices] fetchNpcConversations:currentNpc.npcId afterViewingNode:currentNode.nodeId];
			[self showWaitingIndicatorForPlayerOptions];
		}
	}
}

- (void) optionsRecievedFromNotification:(NSNotification*) notification{
    NSLog(@"DialogVC: optionsRecievedFromNotification");
    [self dismissWaitingIndicatorForPlayerOptions];
	[self finishApplyingPlayerOptions: (NSArray*)[notification object]];
}

- (void) finishApplyingPlayerOptions:(NSArray*)options{
    
    NSLog(@"DialogVC: finishApplyingPlayerOptions");

    currentNode = nil;
	pcWebView.hidden = YES;
	pcTableView.hidden = YES;
    
    NSString *string1 = currentNpc.closing;
    NSString *trimmedString = [string1 stringByReplacingOccurrencesOfString:@" " withString:@""]; //remove whitespace
    if([trimmedString length] == 1) 
        currentNpc.closing =   [trimmedString stringByAppendingString: @"\r"];
    
    //Now our options are populated with node or conversation choices, display
	if ([options count] == 0 && [currentNpc.closing length] > 1 && !self.closingScriptPlaying) {
			NSLog(@"DialogViewController: Play Closing Script: %@",currentNpc.closing);
			pcWebView.hidden = YES;
			self.closingScriptPlaying = YES; 		
			[parser parseText:currentNpc.closing];
	}
	else {
        [self moveAllOutWithPostSelector:nil];
        [self movePcIn];
        
        pcWebView.hidden = YES;
        pcContinueButton.hidden = YES;
        pcTableView.hidden = NO;
		pcAnswerView.hidden = YES;
        
        cachedScrollView = pcImage;
        [pcImageScrollView zoomToRect:[pcImage frame] animated:NO];
        
        self.title = NSLocalizedString(@"DialogPlayerName",@"");
		NSLog(@"DialogViewController: Player options exist or no closing script exists, put them on the screen");

        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hasViewed"
                                                      ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        optionList = [options sortedArrayUsingDescriptors:sortDescriptors];
		[pcTableView reloadData];
	}
}

- (void) showWaitingIndicatorForPlayerOptions{
	pcTableViewController.view.hidden = YES;
	pcActivityIndicator.hidden = NO;
    pcActivityIndicator.frame = CGRectMake(130, 300, 50, 50);
    pcScrollView.hidden = YES;
    npcScrollView.hidden = YES;
    lbl.frame =  pcScrollView.frame;
    lbl.backgroundColor = [UIColor blackColor];
    lbl.alpha = .7;
    
    [self.view addSubview:lbl];
    [self.view addSubview:pcActivityIndicator];
	[pcActivityIndicator startAnimating];
}
- (void) dismissWaitingIndicatorForPlayerOptions{
    [lbl removeFromSuperview];
	pcActivityIndicator.hidden = YES;
  
	[pcActivityIndicator stopAnimating];
   
}

- (void) applyScene:(Scene *)aScene {	
	UIView *characterView;
    UIWebView *characterWebView;
	UIScrollView *characterScrollView;
	UIScrollView *characterImageScrollView;
	BOOL isCurrentlyDisplayed;
    
    if(aScene.vibrate) [((ARISAppDelegate *)[[UIApplication sharedApplication] delegate]) vibrate];
    if(aScene.notification != nil)
        [[RootViewController sharedRootViewController] enqueueNotificationWithFullString:aScene.notification andBoldedString:@""]; 
    
    self.npcImage.hidden = NO; 
	cachedScene = aScene;
    if(aScene.mediaId != 0){
        NSLog(@"mediaId gets here");
        Media *media = [[AppModel sharedAppModel] mediaForMediaId:aScene.mediaId];
        NSLog(@"%@", media.type);
        if([media.type isEqualToString: kMediaTypeVideo]){
            NSLog(@"Gets to video");
            NSLog(@"Playing through ARISMoviePlayerController");
            [self playAudioOrVideoFromMedia:media andHidden:NO];
        }
        else if([media.type isEqualToString: kMediaTypeImage]){
            aScene.imageMediaId = aScene.mediaId;
            NSLog(@"imageMediaId was overwritten");
        }
        else if([media.type isEqualToString: kMediaTypeAudio]){
            [self playAudioOrVideoFromMedia:media andHidden:YES];
            NSLog(@"Gets to audio");
        }
    }
    
    // if no media id is specified for the scene, default to the current NPC's image
    if (cachedScene.imageMediaId == 0)
        cachedScene.imageMediaId = currentNpc.mediaId; 
    
    NSLog(@"isPc: %d", (int)aScene.isPc);
    
    characterView = aScene.isPc ? pcView : npcView;
	characterWebView = aScene.isPc ? pcWebView : npcWebView;
	characterScrollView = aScene.isPc ? pcScrollView : npcScrollView;
	characterImageScrollView = aScene.isPc ? pcImageScrollView : npcImageScrollView;

	isCurrentlyDisplayed = (characterView.frame.origin.x == 0);
	
	if (isCurrentlyDisplayed) {
		[UIView beginAnimations:@"dialog" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.25];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(finishScene)];
		characterWebView.alpha = 0;
		[UIView commitAnimations];
	}
	else [self moveAllOutWithPostSelector:@selector(finishScene)];
}

- (void) finishScene {
	NSLog(@"Dialog VC: finishScene");
    UIView *characterView;
	UIWebView *characterWebView;
	UIScrollView *lastCharacterScrollView;
	UIScrollView *lastCharacterImageScrollView;

	UIScrollView *currentCharacterScrollView;
	UIScrollView *currentCharacterImageScrollView;

	UIButton *continueButton;
	BOOL isCurrentlyDisplayed;
		 
	if (cachedScene.isPc) {
        NSLog(@"Dialog VC: finishScene: This is the PC");
        if (![cachedScene.title isEqualToString:@""] && (cachedScene.title != nil)) self.title = cachedScene.title;
        else self.title = NSLocalizedString(@"DialogPlayerName",@"");
		characterView = pcView;
        characterWebView = pcWebView;
		lastCharacterScrollView = npcScrollView;
		lastCharacterImageScrollView = npcImageScrollView;

		currentCharacterScrollView = pcScrollView;		
		currentCharacterImageScrollView = pcImageScrollView;		

		cachedScrollView = pcImage;
		continueButton = pcContinueButton;
		
		if (scriptIndex == [currentScript count] && self.closingScriptPlaying ) {
			//We are at the end of the script and no conversations exist, the next tap on the button is going to end the dialog
			[pcContinueButton setTitle: NSLocalizedString(@"DialogEnd",@"") forState: UIControlStateNormal];
			[pcContinueButton setTitle: NSLocalizedString(@"DialogEnd",@"") forState: UIControlStateHighlighted];

		}
	}
	else {
        NSLog(@"Dialog VC: finishScene: This is the NPC");

        if (![cachedScene.title isEqualToString:@""] && (cachedScene.title != nil)) self.title = cachedScene.title;
        else self.title = currentNpc.name; 
        
        cachedScene.title = nil;
        
        characterView = npcView;
        characterWebView = npcWebView;
		lastCharacterScrollView = pcScrollView;
		lastCharacterImageScrollView = pcImageScrollView;

		currentCharacterScrollView = npcScrollView;		
		currentCharacterImageScrollView = npcImageScrollView;		

		continueButton = npcContinueButton;
        NSLog(@"ImageMediaID:%i",cachedScene.imageMediaId);
        
        [self loadNPCImage:cachedScene.imageMediaId];
        cachedScrollView = npcImage;
	}
	
	//Try resetting the height to 0 each time for proper content height calculation
	CGRect webViewFrame = [characterWebView frame];	
	webViewFrame.size = CGSizeMake(webViewFrame.size.width,10);
	[characterWebView setFrame:webViewFrame];
	
	//Reset it's scroll view
	[currentCharacterScrollView setContentOffset:CGPointMake(0, 0) animated:NO];

    //Load content
    NSString *dialogString = [NSString stringWithFormat:kDialogHtmlTemplate, cachedScene.text];
	[characterWebView loadHTMLString:dialogString baseURL:nil];
	characterWebView.hidden = YES; //It will have this turned back on once it has loaded
	
    continueButton.hidden = NO;

    //Either fade the text out/in or move the correct character onto the screen
    isCurrentlyDisplayed = characterView.frame.origin.x == 0;
	NSLog(@"Character IsCurrentlyDisplayed: %d", isCurrentlyDisplayed);
    
	if (!isCurrentlyDisplayed) {
        NSLog(@"Dialog VC: finishScene: The current character is not on screen, move them in");

		if (cachedScene.isPc) [self movePcIn];
		else [self moveNpcIn];
	}
	
    //Start the Camera Zoom if defined
	NSLog(@"Dialog VC: finishScene: Moving Camera From Ofset: (%g, %g) Zoom: %g To Rect: %g, %g, %g, %g",
		  currentCharacterImageScrollView.contentOffset.x,currentCharacterImageScrollView.contentOffset.y,
		  currentCharacterScrollView.zoomScale,
		  cachedScene.imageRect.origin.x,cachedScene.imageRect.origin.y, 
		  cachedScene.imageRect.size.width,cachedScene.imageRect.size.height);
	
  	self.npcScrollView.frame = self.pcScrollView.frame;
    
	[UIView beginAnimations:@"cameraMove" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:cachedScene.zoomTime];
	
	float imageScrollViewWidth = currentCharacterImageScrollView.contentSize.width;
	float imageScrollViewHeight = currentCharacterImageScrollView.contentSize.height;
	
	CGFloat horizScale = imageScrollViewWidth / cachedScene.imageRect.size.width;
	CGFloat vertScale  = imageScrollViewHeight / cachedScene.imageRect.size.height;
	
	CGAffineTransform transformation = CGAffineTransformMakeScale(horizScale, vertScale);
	transformation = CGAffineTransformTranslate(transformation, 
                    (imageScrollViewWidth/2 - (cachedScene.imageRect.origin.x + cachedScene.imageRect.size.width / 2.0)),
                    (imageScrollViewHeight/2 - (cachedScene.imageRect.origin.y + cachedScene.imageRect.size.height / 2.0)));
	[currentCharacterImageScrollView setTransform:transformation];
	[UIView commitAnimations];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {	
	UIButton *continueButton;
	UIScrollView *scrollView;
	
	if (webView == npcWebView) {
		NSLog(@"DialogViewController: NPC WebView loaded: Update Sizes");
		continueButton = npcContinueButton;
		scrollView = npcScrollView;
	}
	else {
		NSLog(@"DialogViewController: PC WebView loaded: Update Sizes");
		continueButton = pcContinueButton;
		scrollView = pcScrollView;
	}

	//Size the webView
	CGRect webViewFrame = [webView frame];	
	float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue] + 3;
	webViewFrame.size = CGSizeMake(webViewFrame.size.width, newHeight);
	[webView setFrame:webViewFrame];
	[[[webView subviews] lastObject] setScrollEnabled:NO]; //Disable scrolling in webview
	NSLog(@"DialogViewController: UIWebView frame set to {%f, %f, %f, %f}", 
		  webViewFrame.origin.x, 
		  webViewFrame.origin.y, 
		  webViewFrame.size.width,
		  webViewFrame.size.height);
	

	//position the continue button
	CGRect continueButtonFrame = [continueButton frame];	
	continueButtonFrame.origin = CGPointMake(continueButtonFrame.origin.x, webViewFrame.origin.y+webViewFrame.size.height+5);
	[continueButton setFrame:continueButtonFrame];
	
	NSLog(@"DialogViewController: Continue Button frame set to {%f, %f, %f, %f}", 
		  continueButtonFrame.origin.x, 
		  continueButtonFrame.origin.y, 
		  continueButtonFrame.size.width,
		  continueButtonFrame.size.height);	
	
	//Size the scroll view's content
	scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, continueButtonFrame.origin.y + continueButtonFrame.size.height + 30);
	NSLog(@"DialogViewController: ScrollView size set to {%f, %f}",scrollView.contentSize.width, scrollView.contentSize.height);
    
    //Fade in the WebView
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [UIView beginAnimations:@"dialog" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.25];
    webView.alpha = 1;
    [UIView commitAnimations];
    
    webView.hidden = NO;
    scrollView.hidden = NO;
    
}


#pragma mark Movement 
- (void) moveAllOutWithPostSelector:(SEL)postSelector {	
	[self movePcTo:CGRectMake(160, 0, 320, 416) withAlpha:0 
		  andNpcTo:CGRectMake(-160, 0, 320, 416) withAlpha:0
  withPostSelector:postSelector];
}

- (void) movePcIn {
	NSLog(@"DialogViewController: Move PC view to Main View X:%f Y:%f Width:%f Height:%f",mainView.frame.origin.x,mainView.frame.origin.y,mainView.frame.size.width,mainView.frame.size.height );
    pcScrollView.hidden = NO;
	[self movePcTo:[mainView frame] withAlpha:1.0
		  andNpcTo:[npcView frame] withAlpha:[npcView alpha] withPostSelector:nil];
}

- (void) moveNpcIn {
	NSLog(@"DialogViewController: Move NPC view to Main View X:%f Y:%f Width:%f Height:%f",mainView.frame.origin.x,mainView.frame.origin.y,mainView.frame.size.width,mainView.frame.size.height );
    npcScrollView.hidden = NO;

	[self movePcTo:[pcView frame] withAlpha:[pcView alpha]
		  andNpcTo:[mainView frame] withAlpha:1.0 withPostSelector:nil];	
}

- (void) movePcTo:(CGRect)pcRect withAlpha:(CGFloat)pcAlpha
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

#pragma mark Audio and Video
- (void) playAudioOrVideoFromMedia:(Media*)media andHidden:(BOOL)hidden{
    if(media.image != nil){
        NSLog(@"Playing through AVAudioPlayer");
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];	
        [[AVAudioSession sharedInstance] setActive: YES error: nil];
        NSError* err;
        self.player = [[AVAudioPlayer alloc] initWithData: media.image error:&err];
        [self.player setDelegate: self];
        if( err ){
            NSLog(@"Appdelegate: Playing Audio: Failed with reason: %@", [err localizedDescription]);
        }
        else{
            [self.player play];
        }
    }
    else{
        NSLog(@"Playing through MPMoviePlayerController");
        self.ARISMoviePlayer.moviePlayer.view.hidden = hidden; 
        self.ARISMoviePlayer = [[ARISMoviePlayerViewController alloc] init];
        self.ARISMoviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        [self.ARISMoviePlayer.moviePlayer setContentURL: [NSURL URLWithString:media.url]];
        [self.ARISMoviePlayer.moviePlayer setControlStyle:MPMovieControlStyleNone];
        [self.ARISMoviePlayer.moviePlayer setFullscreen:NO];
        [self.ARISMoviePlayer.moviePlayer prepareToPlay];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChangeNotification: ) name:MPMoviePlayerLoadStateDidChangeNotification object:self.ARISMoviePlayer.moviePlayer];
        UIActivityIndicatorView *allocWaiting = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.waiting = allocWaiting;
        self.waiting.center = self.view.center;
        self.waiting.hidesWhenStopped = YES;
        [self.view addSubview:waiting];
        [self.waiting startAnimating];
        if(!hidden){
            NSLog(@"Gets to not hidden");
            self.ARISMoviePlayer.view.frame = npcVideoView.frame;
            self.npcVideoView = (UIScrollView *)self.ARISMoviePlayer.view;
            self.npcVideoView.hidden = NO;
            [self.npcView insertSubview:npcVideoView atIndex: 1];
            self.npcImage.hidden = YES;
        }
    }
}

#pragma mark MPMoviePlayerController notifications

- (void)MPMoviePlayerLoadStateDidChangeNotification:(NSNotification *)notif
{
    NSLog(@"loadState: %d", self.ARISMoviePlayer.moviePlayer.loadState);
    if (self.ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStateStalled) {
        [self.waiting startAnimating];
        [self.ARISMoviePlayer.moviePlayer pause];
    } else if (self.ARISMoviePlayer.moviePlayer.loadState & MPMovieLoadStatePlayable) {
        [self.waiting stopAnimating];
        NSLog(@"Load state changes");
        [self.ARISMoviePlayer.moviePlayer play];
        [self.waiting removeFromSuperview];
        
    }
} 

#pragma mark audioPlayerDone

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) flag {
    NSLog(@"Appdelegate: Audio is done playing");
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
}

#pragma mark Answer Checking
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[pcAnswerView resignFirstResponder];
	NSString *cookedResponse = [pcAnswerView.text lowercaseString];
	NSString *cookedAnswer = [currentNode.answerString lowercaseString];
	
	NSInteger targetNode;
	if ([cookedAnswer isEqualToString:cookedResponse]) {
		targetNode = currentNode.nodeIfCorrect;
	}
	else targetNode = currentNode.nodeIfIncorrect;
		
	Node *newNode = [[AppModel sharedAppModel] nodeForNodeId: targetNode];

	// TODO: This might need to check for answer string
    
	currentNode = newNode;
	
	[parser parseText:newNode.text];
	
	return YES;
}

#pragma mark PC options table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.hideLeaveConversationButton) return 1;
       return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0) return [optionList count];
	else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [pcTableView dequeueReusableCellWithIdentifier:@"Dialog"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
									   reuseIdentifier:@"Dialog"];
	}
	
	if (indexPath.section == 0) {
		NodeOption *option = [optionList objectAtIndex:indexPath.row];
		cell.textLabel.text = option.text;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kOptionsFontSize];
        [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
        if(option.hasViewed){ 
            cell.backgroundColor = [UIColor colorWithRed:233.0/255.0  
                                                                    green:233.0/255.0  
                                                                     blue:233.0/255.0 alpha:1.0];
         cell.textLabel.textColor = [UIColor colorWithRed:(100.0/255.0) green:(129.0/255.0) blue:(183.0/255.0) alpha:1];                                                           
        }
        else cell.textLabel.textColor = [UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1];
	}
	else if (indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"DialogEnd",@"");
        cell.textLabel.textColor = [UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1];
	}
	
	
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.textLabel.minimumFontSize = kOptionsFontSize;
	
	cell.textLabel.numberOfLines = 0;
	[cell.textLabel sizeToFit];
	
	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) return 35;

	
	NodeOption *option = [optionList objectAtIndex:indexPath.row];

	CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 50;
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
	
    CGSize expectedLabelSize = [option.text sizeWithFont:[UIFont boldSystemFontOfSize:kOptionsFontSize] 
									   constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
	
	return expectedLabelSize.height + 15;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Check if it is the "leave conversation" option
	if (indexPath.section == 1 && indexPath.row == 0) {
		[self backButtonTouchAction:nil];
		return;
	}
	
	NodeOption *selectedOption = [optionList objectAtIndex:[indexPath row]];
	NSLog(@"Going to node #%d for prompt '%@'", selectedOption.nodeId, selectedOption.text);
		
	Node *newNode = [[AppModel sharedAppModel] nodeForNodeId:selectedOption.nodeId];

	currentNode = newNode;
    if(newNode.text.length == 0){
        [self continueScript];
        return;
    }
	
    [parser parseText:newNode.text];
}

#pragma mark XML Parsing
- (void) didFinishParsing {
	// Load the next scene
	pcTableView.hidden = YES;
	pcWebView.hidden = YES;
	pcContinueButton.hidden = YES;
	pcAnswerView.hidden = YES;
	
	currentScript = parser.script;
	scriptIndex = kStartingIndex;

    if(parser.exitToTabWithTitle != nil) {
        self.exitToTabVal = (NSString*)parser.exitToTabWithTitle;
    }

    [self continueScript]; 
}

- (void) setHideLeaveConversationButton:(BOOL)hide{
    hideLeaveConversationButton = hide;
}

- (BOOL) hideLeaveConversationButton {
    return hideLeaveConversationButton;
}

#pragma mark Scroll View
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return cachedScrollView;
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations{
    NSInteger mask = 0;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeLeft])
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationLandscapeRight])
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortrait])
        mask |= UIInterfaceOrientationMaskPortrait;
    if ([self shouldAutorotateToInterfaceOrientation: UIInterfaceOrientationPortraitUpsideDown])
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}


@end
