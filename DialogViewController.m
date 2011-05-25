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
#import "AsyncImageView.h"
#import "AudioStreamer.h"
#import "DialogViewController.h"
#import "Media.h"
#import "Node.h"
#import "Scene.h"

const NSInteger kStartingIndex = 0;
const NSInteger kPcIndex = 0;
const NSInteger kMaxOptions = 20;
const NSInteger kOptionsFontSize = 15;
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
					 inView:(AsyncImageView *)aView;
- (void) movePcIn;
- (void) moveNpcIn;
- (void) moveAllOutWithPostSelector:(SEL)postSelector;
- (void) movePcTo:(CGRect)pcRect withAlpha:(CGFloat)pcAlpha 
		 andNpcTo:(CGRect)npcRect withAlpha:(CGFloat)npcAlpha 
 withPostSelector:(SEL)aSelector;
- (void) applyScene:(Scene *)aScene;
- (void) playSound:(int)soundId asBackground:(BOOL)yesOrNo;

@end


@implementation DialogViewController
@synthesize npcImage, pcImage, npcWebView, pcWebView, pcTableView;
@synthesize npcScrollView, pcScrollView, npcImageScrollView, pcImageScrollView, pcActivityIndicator;
@synthesize npcContinueButton, pcContinueButton, textSizeButton;
@synthesize pcAnswerView, mainView, npcView, pcView, nothingElseLabel;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(optionsRecievedFromNotification:)
													 name:@"ConversationNodeOptionsReady"
												   object:nil];
    }
	
    return self;
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	assert(npcImage && @"npcImage not connected.");
	assert(pcImage && @"pcImage not connected.");
	assert(npcWebView && @"npcWebView not connected.");
	assert(pcWebView && @"pcWebView not connected.");
	assert(npcScrollView && @"npcScrollView not connected.");
	assert(pcScrollView && @"pcScrollView not connected.");
	assert(npcImageScrollView && @"npcImageScrollView not connected.");
	assert(pcImageScrollView && @"pcImageScrollView not connected.");

	assert(pcTableView && @"pcTableView not connected.");
	assert(pcAnswerView && @"pcAnswerView not connected.");
	assert(mainView && @"mainView not connected.");
	assert(npcView && @"npcView not connected.");
	assert(pcView && @"pcView not connected.");
	
	//General Setup
	lastPcId = 0;
	currentNode = nil;
	closingScriptPlaying = NO;
	inFullScreenTextMode = NO;
	
	//View Setup
	/*
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DialogEnd",@"");
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
	 */
	
	npcImageScrollView.contentSize = [npcView frame].size;
	pcImageScrollView.contentSize = [pcView frame].size;
	
	[npcWebView setBackgroundColor:[UIColor clearColor]];	
	[pcWebView setBackgroundColor:[UIColor clearColor]];
	
	pcTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewCellStyleDefault];
	pcTableViewController.view = pcTableView;

	[npcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateNormal];
	[npcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateHighlighted];	
	[pcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateNormal];
	[pcContinueButton setTitle: NSLocalizedString(@"DialogContinue",@"") forState: UIControlStateHighlighted];	
	
	self.textSizeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"textToggle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleFullScreenTextMode)];      
	self.navigationItem.rightBarButtonItem = self.textSizeButton;
	
	npcWebView.hidden = NO;
	pcAnswerView.hidden = YES;
	pcTableView.hidden = NO;
	pcWebView.hidden = YES;
	pcActivityIndicator.hidden = YES;

	
	//Check if the game specifies a PC image
	if ([AppModel sharedAppModel].currentGame.pcMediaId != 0) {
		//Load the image from the media Table
		Media *pcMedia = [[AppModel sharedAppModel] mediaForMediaId:[AppModel sharedAppModel].currentGame.pcMediaId];
		[pcImage loadImageFromMedia: pcMedia];
	}
	else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"defaultCharacter.png"]];

	[self applyNPCWithGreeting];
	
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

-(void)toggleFullScreenTextMode{
	NSLog(@"DialogViewController: toggleTextSize");
	
	CGRect newTextFrame;
	if (inFullScreenTextMode) {
		//Switch to small mode
		newTextFrame = CGRectMake(0, self.view.bounds.size.height-128, self.view.bounds.size.width, 128);
	}
	else {
		//switch to full screen mode
		newTextFrame = self.view.bounds;
	}
	
	[UIView beginAnimations:@"toggleTextSize" context:nil];
	[UIView setAnimationDuration:0.5];
	self.pcScrollView.frame = newTextFrame;
	self.pcTableView.frame = self.pcScrollView.bounds;
	self.npcScrollView.frame = newTextFrame;
	[UIView commitAnimations];
	
	inFullScreenTextMode = !inFullScreenTextMode;
	
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

- (void) viewDidDisappear:(BOOL)animated {
	NSLog(@"DialogViewController: View Did Disapear");
	[self stopAllAudio];
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"DialogViewController: Notify server of NPC view and Dismiss view");
	
	//tell the server
	[[AppServices sharedAppServices] updateServerNpcViewed:currentNpc.npcId];
	
	[self dismissModalViewControllerAnimated:YES];

}

- (IBAction)continueButtonTouchAction{
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
	[currentNpc release];
	[currentNode release];
	[parser release];
	[currentScript release];
	[resourcePath release];
	[pcTableViewController release];
    [super dealloc];
}


- (void)applyNPCWithGreeting{

    NSString *string1 = currentNpc.greeting;
    NSString *trimmedString = [string1 stringByReplacingOccurrencesOfString:@" " withString:@""]; //remove whitespace
    if([trimmedString length] == 0)[self continueScript]; //if no greeting entered then go to closing screen
    if([trimmedString length] == 1) 
    currentNpc.greeting =   [trimmedString stringByAppendingString: @"\r"];
	[parser parseText:currentNpc.greeting];
    
    
}

- (void) beginWithNPC:(Npc *)aNpc {
	if (currentNpc) [currentNpc release];
	currentNpc = aNpc;
	[currentNpc retain];
		
	parser = [[SceneParser alloc] initWithDefaultNpcId:[aNpc mediaId]];
	parser.delegate = self;

}

- (void) loadNPCImage:(NSInteger)mediaId {
	[self loadCharacterImage:mediaId withPriorId:&lastNpcId inView:npcImage];
}

- (void) loadCharacterImage:(NSInteger)mediaId withPriorId:(NSInteger *)priorId 
					 inView:(AsyncImageView *)aView 
{
	if (mediaId == *priorId) return;
	
	Media *characterMedia = [[AppModel sharedAppModel] mediaForMediaId:mediaId];
	[aView loadImageFromMedia:characterMedia];
	[aView setNeedsDisplay];
	*priorId = mediaId;
}

- (void) continueScript {
	if (scriptIndex < [currentScript count]) { //Load up this scene of the script

		Scene *currentScene = [currentScript objectAtIndex:scriptIndex];
		[self applyScene:currentScene];
		currentCharacter = currentScene.imageMediaId;
		++scriptIndex;
	}
	else { 	//End of Script. Display Player Options
		[self stopAllAudio];
		[self applyPlayerOptions];
	}
}

- (void) applyPlayerOptions{	
	[self moveAllOutWithPostSelector:nil];
	[self movePcIn];
	
	pcWebView.hidden = YES;
	pcContinueButton.hidden = YES;
	pcTableView.hidden = YES;
	
	cachedScrollView = pcImage;
	[pcImageScrollView zoomToRect:[pcImage frame] animated:NO];
	
	currentCharacter = 0;
	self.title = NSLocalizedString(@"DialogPlayerName",@"");
	++scriptIndex;
	
	// Display the appropriate question for the PC
	if ([currentNode.answerString length] > 0) {
		pcTableView.hidden = YES;
		pcAnswerView.hidden = NO;
	}
	else {
		if (currentNode.numberOfOptions > 0) {
			//There are node options
			[self finishApplyingPlayerOptions:currentNode.options];
		}
		else {
			//No node options, load the conversations
			[[AppServices sharedAppServices] fetchNpcConversations:currentNpc.npcId afterViewingNode:currentNode.nodeId];
			[self showWaitingIndicatorForPlayerOptions];
		}
	}
		
}

- (void) optionsRecievedFromNotification:(NSNotification*) notification{
	[self dismissWaitingIndicatorForPlayerOptions];
	[self finishApplyingPlayerOptions: (NSArray*)[notification object]];
}

- (void) finishApplyingPlayerOptions:(NSArray*)options{
    currentNode = nil;
	pcWebView.hidden = YES;
	pcTableView.hidden = YES;
    NSString *string1 = currentNpc.closing;
    NSString *trimmedString = [string1 stringByReplacingOccurrencesOfString:@" " withString:@""]; //remove whitespace
    if([trimmedString length] == 1) 
        currentNpc.closing =   [trimmedString stringByAppendingString: @"\r"];
    	//Now our options are populated with node or conversation choices, display
	if ([options count] == 0 && [currentNpc.closing length] > 1 && !closingScriptPlaying) {
			NSLog(@"DialogViewController: Play Closing Script: %@",currentNpc.closing);
			pcWebView.hidden = YES;
			closingScriptPlaying = YES; 		
			[parser parseText:currentNpc.closing];
	}
	else {
		NSLog(@"DialogViewController: Player options exist or no closing script exists, put them on the screen");
		pcTableView.hidden = NO;
		pcAnswerView.hidden = YES;
		optionList = options;
		[optionList retain];
		[pcTableView reloadData];
	}
}

- (void) showWaitingIndicatorForPlayerOptions{
	pcTableViewController.view.hidden = YES;
	pcActivityIndicator.hidden = NO;
	[pcActivityIndicator startAnimating];
}
- (void) dismissWaitingIndicatorForPlayerOptions{
	pcTableViewController.view.hidden = NO;	
	pcActivityIndicator.hidden = YES;
	[pcActivityIndicator stopAnimating];
}

- (void) applyScene:(Scene *)aScene {	
	UIWebView *characterWebView;
	UIScrollView *characterScrollView;
	UIScrollView *characterImageScrollView;
	
	BOOL isCurrentlyDisplayed;
	cachedScene = [aScene retain];
	
	// Sounds
	if (aScene.backSoundMediaId == kStopSound) {
		[bgPlayer stop];
		[bgPlayer release];
		bgPlayer = nil;
	}
	else if (aScene.backSoundMediaId != kEmptySound) {
		[self playSound:[aScene backSoundMediaId] asBackground:YES];
	}
	
	if (aScene.foreSoundMediaId != kEmptySound) {
		[self playSound:[aScene foreSoundMediaId] asBackground:NO];
	}
	else {
		[fgPlayer stop];
		[fgPlayer release];
		fgPlayer = nil;		
	}
	
	characterWebView = aScene.isPc ? pcWebView : npcWebView;
	characterScrollView = aScene.isPc ? pcScrollView : npcScrollView;
	characterImageScrollView = aScene.isPc ? pcImageScrollView : npcImageScrollView;

	isCurrentlyDisplayed = currentCharacter == aScene.imageMediaId;
	
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

- (void) stopAllAudio {
	NSLog(@"Dialog ViewController: Stoping all Audio");
	
	if (fgPlayer) [fgPlayer stop];
	if (bgPlayer) [bgPlayer stop];
}

- (void) finishScene {
	UIWebView *characterWebView;
	UIScrollView *lastCharacterScrollView;
	UIScrollView *lastCharacterImageScrollView;

	UIScrollView *currentCharacterScrollView;
	UIScrollView *currentCharacterImageScrollView;

	UIButton *continueButton;
	BOOL isCurrentlyDisplayed;
		 
	if (cachedScene.isPc) {
		self.title = NSLocalizedString(@"DialogPlayerName",@"");
		characterWebView = pcWebView;
		lastCharacterScrollView = npcScrollView;
		lastCharacterImageScrollView = npcImageScrollView;

		currentCharacterScrollView = pcScrollView;		
		currentCharacterImageScrollView = pcImageScrollView;		

		cachedScrollView = pcImage;
		continueButton = pcContinueButton;
		
		if (scriptIndex == [currentScript count] && closingScriptPlaying ) {
			//We are at the end of the script and no conversations exist, the next tap on the button is going to end the dialog
			[pcContinueButton setTitle: NSLocalizedString(@"DialogEnd",@"") forState: UIControlStateNormal];
			[pcContinueButton setTitle: NSLocalizedString(@"DialogEnd",@"") forState: UIControlStateHighlighted];	
		}
		
	}
	else {
		self.title = currentNpc.name;
		characterWebView = npcWebView;
		lastCharacterScrollView = pcScrollView;
		lastCharacterImageScrollView = pcImageScrollView;

		currentCharacterScrollView = npcScrollView;		
		currentCharacterImageScrollView = npcImageScrollView;		

		continueButton = npcContinueButton;
		[self loadNPCImage:cachedScene.imageMediaId];
		cachedScrollView = npcImage;

	}
	
	//Try resetting the height to 0 each time for proper content height calculation
	CGRect webViewFrame = [characterWebView frame];	
	webViewFrame.size = CGSizeMake(webViewFrame.size.width,10);
	[characterWebView setFrame:webViewFrame];
	
	//Reset it's scroll view
	[currentCharacterScrollView setContentOffset:CGPointMake(0, 0) animated:NO];

	
	isCurrentlyDisplayed = [characterWebView alpha] < 1;
	NSLog(@"Character %d IsCurrentlyDisplayed: %d", currentCharacter, isCurrentlyDisplayed);
	
	NSString *dialogString = [NSString stringWithFormat:kDialogHtmlTemplate, cachedScene.text];
	[characterWebView loadHTMLString:dialogString baseURL:nil];
	characterWebView.hidden = YES;
	
	continueButton.hidden = NO;
	
	if (isCurrentlyDisplayed) {
		[currentCharacterScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
		[UIView beginAnimations:@"dialog" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.25];
		characterWebView.alpha = 1;
		[UIView commitAnimations];
	}
	
	if (!isCurrentlyDisplayed) {
		if (cachedScene.isPc) [self movePcIn];
		else [self moveNpcIn];
	}
	
	NSLog(@"Moving Camera From Ofset: (%g, %g) Zoom: %g To Rect: %g, %g, %g, %g",
		  currentCharacterImageScrollView.contentOffset.x,currentCharacterImageScrollView.contentOffset.y,
		  currentCharacterScrollView.zoomScale,
		  cachedScene.imageRect.origin.x,cachedScene.imageRect.origin.y, 
		  cachedScene.imageRect.size.width,cachedScene.imageRect.size.height);
	
	
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

	
	[cachedScene release];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {	
	UIButton *continueButton;
	UIScrollView *scrollView;
	
	if (webView == npcWebView) {
		NSLog(@"DialogViewController: NPC WebView loaded: Update Sizes");
		npcWebView.hidden = NO;
		continueButton = npcContinueButton;
		scrollView = npcScrollView;
	}
	else {
		NSLog(@"DialogViewController: PC WebView loaded: Update Sizes");
		pcWebView.hidden = NO;
		continueButton = pcContinueButton;
		scrollView = pcScrollView;

	}

	
	//Size the webView
	CGRect webViewFrame = [webView frame];	
	float newHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
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
	/*
	NSLog(@"DialogViewController: Continue Button frame set to {%f, %f, %f, %f}", 
		  continueButtonFrame.origin.x, 
		  continueButtonFrame.origin.y, 
		  continueButtonFrame.size.width,
		  continueButtonFrame.size.height);	
	*/
	//Size the scroll view's content
	scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, continueButtonFrame.origin.y + continueButtonFrame.size.height + 30);
	//NSLog(@"DialogViewController: ScrollView size set to {%f, %f}",scrollView.contentSize.width, scrollView.contentSize.height);
	
}


#pragma mark Movement 
- (void) moveAllOutWithPostSelector:(SEL)postSelector {	
	[self movePcTo:CGRectMake(160, 0, 320, 416) withAlpha:0 
		  andNpcTo:CGRectMake(-160, 0, 320, 416) withAlpha:0
  withPostSelector:postSelector];
}

- (void) movePcIn {
	NSLog(@"DialogViewController: Move PC view to Main View X:%f Y:%f Width:%f Height:%f",mainView.frame.origin.x,mainView.frame.origin.y,mainView.frame.size.width,mainView.frame.size.height );
	[self movePcTo:[mainView frame] withAlpha:1.0
		  andNpcTo:[npcView frame] withAlpha:[npcView alpha] withPostSelector:nil];
}

- (void) moveNpcIn {
	NSLog(@"DialogViewController: Move NPC view to Main View X:%f Y:%f Width:%f Height:%f",mainView.frame.origin.x,mainView.frame.origin.y,mainView.frame.size.width,mainView.frame.size.height );

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

#pragma mark Audio
- (void) playSound:(int)soundId asBackground:(BOOL)yesOrNo {
	
	Media *audioMedia = [[AppModel sharedAppModel] mediaForMediaId:soundId];
	
	if (!audioMedia) return;
	NSURL *url = [[NSURL alloc] initWithString:audioMedia.url];
	AudioStreamer *player = [[AudioStreamer alloc] initWithURL:url];
	NSLog(@"Opening audio URL %@", [url path]);
	[url release];
	
	if (yesOrNo) {
		if (bgPlayer) {
			[bgPlayer stop];
			[bgPlayer release];
			bgPlayer = nil;
		}
		bgPlayer = player;
	}
	else {
		if (fgPlayer) {
			[fgPlayer stop];
			[fgPlayer release];
			fgPlayer = nil;
		}
		fgPlayer = player;
	}
	[player start];
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
    
	if (currentNode) [currentNode release];
	currentNode = newNode;
	[currentNode retain];
	[newNode release];
	
	[parser parseText:newNode.text];
	
	return YES;
}

#pragma mark PC options table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0) return [optionList count];
	else return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [pcTableView dequeueReusableCellWithIdentifier:@"Dialog"];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
									   reuseIdentifier:@"Dialog"] autorelease];
	}
	
	if (indexPath.section == 0) {
		NodeOption *option = [optionList objectAtIndex:indexPath.row];
		cell.textLabel.text = option.text;
	}
	else if (indexPath.row == 0) {
		cell.textLabel.text = NSLocalizedString(@"DialogReview",@"");
	}
	else cell.textLabel.text = NSLocalizedString(@"DialogEnd",@""); 
	
	
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.textLabel.minimumFontSize = kOptionsFontSize;
	cell.textLabel.textColor = [UIColor colorWithRed:(50.0/255.0) green:(79.0/255.0) blue:(133.0/255.0) alpha:1];
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
	
    CGSize expectedLabelSize = [option.text sizeWithFont:[UIFont systemFontOfSize:kOptionsFontSize] 
									   constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap]; 
	
	return expectedLabelSize.height + 15;	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//Check if it is the "review option"
	if (indexPath.section == 1 && indexPath.row == 0) {
		pcWebView.hidden = YES;
		pcTableView.hidden = YES;
		[self reviewScript];
		return;
	}

	//Check if it is the "leave conversation" option
	if (indexPath.section == 1 && indexPath.row == 1) {
		[self backButtonTouchAction:nil];
		return;
	}
	
	NodeOption *selectedOption = [optionList objectAtIndex:[indexPath row]];
	NSLog(@"Going to node #%d for prompt '%@'", selectedOption.nodeId, selectedOption.text);
		
	Node *newNode = [[AppModel sharedAppModel] nodeForNodeId:selectedOption.nodeId];

	if (currentNode) [currentNode release];
	currentNode = newNode;
	[currentNode retain];
if(newNode.text.length == 0)[self continueScript];
	[parser parseText:newNode.text];
}

#pragma mark XML Parsing
- (void) didFinishParsing {
	// Load the next scene
	pcTableView.hidden = YES;
	pcWebView.hidden = YES;
	pcContinueButton.hidden = YES;
	pcAnswerView.hidden = YES;
	currentCharacter = kPcIndex;
	
	currentScript = parser.script;
	scriptIndex = kStartingIndex;

	[self continueScript];
}

#pragma mark Scroll View
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return cachedScrollView;
}
@end
