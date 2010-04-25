//
//  aris_conversationViewController.m
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/17.
//  Copyright Studio Tectorum 2009. All rights reserved.
//
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "AsyncImageView.h"
#import "AudioStreamer.h"
#import "DialogViewController.h"
#import "Media.h"
#import "Node.h"
#import "Scene.h"

const NSInteger kStartingIndex = 0;
const NSInteger kPcIndex = 0;
const NSInteger kMaxOptions = 20;
NSString *const kOutAnimation = @"out";
NSString *const kInAnimation = @"in";
NSString *const kPcContinue = @"Tap to continue.";
NSString *const kPcReview = @"Tap to review.";
NSString *const kPlayerName = @"You";


NSString *const kHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<link rel='stylesheet' type='text/css' href='aris.css' />"
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
@synthesize npcImage, pcImage, npcWebView, pcWebView, pcTableView, npcScrollView, pcScrollView;
@synthesize pcAnswerView, mainView, npcView, pcView, pcLabel, nothingElseLabel;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	assert(npcImage && @"npcImage not connected.");
	assert(pcImage && @"pcImage not connected.");
	assert(npcWebView && @"npcWebView not connected.");
	assert(pcWebView && @"pcWebView not connected.");
	assert(npcScrollView && @"npcScrollView not connected.");
	assert(pcScrollView && @"pcScrollView not connected.");
	assert(pcLabel && @"pcLabel not connected.");

	assert(pcTableView && @"pcTableView not connected.");
	assert(pcAnswerView && @"pcAnswerView not connected.");
	assert(mainView && @"mainView not connected.");
	assert(npcView && @"npcView not connected.");
	assert(pcView && @"pcView not connected.");
	
    [super viewDidLoad];
	
	self.title = currentNpc.name;
	[self loadNPCImage:currentNpc.mediaId];
	
	resourcePath = [[NSString stringWithFormat:@"file:/%@//", [[[[NSBundle mainBundle] resourcePath]
					 stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
					stringByReplacingOccurrencesOfString:@" " withString:@"%20"]] retain];
	NSLog(@"DialogVC: Resource Path: %@",resourcePath);
	
	npcScrollView.contentSize = [npcView frame].size;
	pcScrollView.contentSize = [pcView frame].size;
	
	[npcWebView setBackgroundColor:[UIColor clearColor]];	
	[pcWebView setBackgroundColor:[UIColor clearColor]];
	
	pcTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewCellStyleDefault];
	pcTableViewController.view = pcTableView;

	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	if (appModel.gamePcMediaId != 0) {
		//Load the image from the media Table
		Media *pcMedia = [appModel mediaForMediaId:appModel.gamePcMediaId];
		[pcImage loadImageFromMedia: pcMedia];
	}
	else [pcImage updateViewWithNewImage:[UIImage imageNamed:@"defaultCharacter.png"]];

	
	npcWebView.hidden = NO;
	[npcWebView loadHTMLString:[NSString stringWithFormat:kHtmlTemplate, [currentNpc greeting]] 
					   baseURL:[NSURL URLWithString:resourcePath]];

	pcAnswerView.delegate = self;
	
	pcTableView.hidden = NO;
	pcWebView.hidden = YES;
	pcAnswerView.hidden = YES;
	lastPcId = 0;
	currentNode = nil;
	
	[self moveNpcIn];	// Always start with the NPC Conversation list?
	
/*
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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//[pcAnswerView resignFirstResponder];
	if (scriptIndex > [currentScript count]) scriptIndex = [currentScript count] - 1;
	[self continueScript];
}

#pragma mark NPC Control
- (void) beginWithNPC:(Npc *)aNpc {
	currentNpc = [aNpc retain];
	
	//tell the server
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	[appModel updateServerNpcViewed:currentNpc.npcId];
	
	parser = [[SceneParser alloc] initWithDefaultNpcId:[aNpc mediaId]];
	parser.delegate = self;
	
	optionList = currentNpc.options;
	assert(optionList == aNpc.options);
	NSLog(@"OptionList: %@", optionList);
}

- (void) loadNPCImage:(NSInteger)mediaId {
	[self loadCharacterImage:mediaId withPriorId:&lastNpcId inView:npcImage];
}

- (void) loadCharacterImage:(NSInteger)mediaId withPriorId:(NSInteger *)priorId 
					 inView:(AsyncImageView *)aView 
{
	if (mediaId == *priorId) return;
	
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	Media *characterMedia = [appModel mediaForMediaId:mediaId];
	[aView loadImageFromMedia:characterMedia];
	[aView setNeedsDisplay];
	*priorId = mediaId;
}

#pragma mark Script Control
- (void) continueScript {
	if (scriptIndex < [currentScript count]) {
		Scene *currentScene = [currentScript objectAtIndex:scriptIndex];

		[self applyScene:currentScene];

		currentCharacter = currentScene.characterId;
		pcLabel.text = kPcContinue;

		++scriptIndex;
	}
	else {
		// Display the appropriate question for the PC
		if ([currentNode.answerString length] > 0) {
			pcTableView.hidden = YES;
			pcWebView.hidden = YES;
			pcAnswerView.hidden = NO;
		}
		else {
			if (currentNode.numberOfOptions > 0) optionList = currentNode.options;
			else {
				//refresh our option list
				AppModel *appModel = [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] appModel];
				Npc *newNpc = [appModel fetchNpc:currentNpc.npcId];
				optionList = newNpc.options;
			}
			int optionCount = [optionList count];
			if (optionCount == 0) {
				nothingElseLabel.hidden = NO;
			}
			pcTableView.hidden = NO;
			pcWebView.hidden = YES;
			pcAnswerView.hidden = YES;
			[pcTableView reloadData];
		}
		
		cachedScrollView = pcImage;
		[pcScrollView zoomToRect:[pcImage frame] animated:NO];
		[pcWebView loadHTMLString:[NSString stringWithFormat:kHtmlTemplate, @""] 
								 baseURL:[NSURL URLWithString:resourcePath]];
		
		[self moveAllOutWithPostSelector:nil];
		[self movePcIn];
		currentCharacter = 0;
		pcLabel.text = kPcReview;
		self.title = kPlayerName;
		++scriptIndex;
	}
}

- (void) applyScene:(Scene *)aScene {
	UIWebView *characterWebView;
	BOOL isCurrentlyDisplayed;
	cachedScene = [aScene retain];
	
	// Sounds
	if (aScene.bgSound == kStopSound) {
		[bgPlayer stop];
		[bgPlayer release];
		bgPlayer = nil;
	}
	else if (aScene.bgSound != kEmptySound) {
		[self playSound:[aScene bgSound] asBackground:YES];
	}
	
	if (aScene.fgSound != kEmptySound) {
		[self playSound:[aScene fgSound] asBackground:NO];
	}
	else {
		[fgPlayer stop];
		[fgPlayer release];
		fgPlayer = nil;		
	}
	
	characterWebView = aScene.isPc ? pcWebView : npcWebView;
	isCurrentlyDisplayed = currentCharacter == aScene.characterId;
	
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
	UIWebView *characterWebView;
	UIScrollView *characterScrollView;
	BOOL isCurrentlyDisplayed;
	
	if (cachedScene.isPc) {
		self.title = kPlayerName;
		characterWebView = pcWebView;
		characterScrollView = pcScrollView;		
		cachedScrollView = pcImage;
	}
	else {
		self.title = currentNpc.name;
		characterWebView = npcWebView;
		characterScrollView = npcScrollView;
		
		[self loadNPCImage:cachedScene.characterId];
		cachedScrollView = npcImage;
	}
	
	isCurrentlyDisplayed = [characterWebView alpha] < 1;
	NSLog(@"Character %d IsCurrentlyDisplayed: %d", currentCharacter, isCurrentlyDisplayed);
	
	[characterWebView loadHTMLString:[NSString stringWithFormat:kHtmlTemplate, cachedScene.text] 
							 baseURL:[NSURL URLWithString:resourcePath]];
	if (isCurrentlyDisplayed) {
		[UIView beginAnimations:@"dialog" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.25];
		characterWebView.alpha = 1;
		[UIView commitAnimations];
	}
	
	NSLog(@"Scrolling to %g, %g, %g, %g", cachedScene.zoomRect.origin.x,
		  cachedScene.zoomRect.origin.y, cachedScene.zoomRect.size.width,
		  cachedScene.zoomRect.size.height);
	
	if (!isCurrentlyDisplayed) {
		// This should share zoom code
		[characterScrollView zoomToRect:cachedScene.zoomRect animated:NO];
		if (cachedScene.isPc) [self movePcIn];
		else [self moveNpcIn];
	}
	else {
		[UIView beginAnimations:@"zooming" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.25];
		
		CGFloat horizScale = 320.0 / cachedScene.zoomRect.size.width;
		CGFloat vertScale  = 460.0 / cachedScene.zoomRect.size.height;
		
		CGAffineTransform transformation = CGAffineTransformMakeScale(horizScale, vertScale);
		transformation = CGAffineTransformTranslate(transformation, 
													(160.0 - (cachedScene.zoomRect.origin.x + cachedScene.zoomRect.size.width / 2.0)),
													(230.0 - (cachedScene.zoomRect.origin.y + cachedScene.zoomRect.size.height / 2.0)));
		[characterScrollView setTransform:transformation];
		[UIView commitAnimations];
	}
	
	[cachedScene release];
}

#pragma mark Movement 
- (void) moveAllOutWithPostSelector:(SEL)postSelector {	
	[self movePcTo:CGRectMake(160, 0, 320, 416) withAlpha:0 
		  andNpcTo:CGRectMake(-160, 0, 320, 416) withAlpha:0
  withPostSelector:postSelector];
}

- (void) movePcIn {
	[self movePcTo:[mainView frame] withAlpha:1.0
		  andNpcTo:[npcView frame] withAlpha:[npcView alpha] withPostSelector:nil];
}

- (void) moveNpcIn {
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
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	Media *audioMedia = [appModel mediaForMediaId:soundId];
	
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
		
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
		
	[currentNode release];
	Node *newNode = [appModel fetchNode:targetNode];
	// TODO: This might need to check for answer string
	optionList = newNode.numberOfOptions > 0 ? newNode.options : currentNpc.options;
	currentNode = newNode;
	[parser parseText:newNode.text];
	
	return YES;
}

#pragma mark Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [optionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [pcTableView dequeueReusableCellWithIdentifier:@"Dialog"];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
									   reuseIdentifier:@"Dialog"] autorelease];
	}
	
	NodeOption *option = [optionList objectAtIndex:indexPath.row];

	cell.textLabel.text = option.text;
	cell.textLabel.textColor = [UIColor whiteColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// TODO: Find the node option and load up the next node
	NodeOption *selectedOption = [optionList objectAtIndex:[indexPath row]];
	NSLog(@"Going to node #%d for prompt '%@'", selectedOption.nodeId, selectedOption.text);
	
	//Create a reference to the delegate using the application singleton.
	ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
	AppModel *appModel = appDelegate.appModel;
	
	[currentNode release];
	Node *newNode = [appModel fetchNode:selectedOption.nodeId];
	[appModel updateServerNodeViewed:selectedOption.nodeId];
	optionList = newNode.numberOfOptions > 0 ? newNode.options : currentNpc.options;
	currentNode = newNode;
	[parser parseText:newNode.text];
}

#pragma mark XML Parsing
- (void) didFinishParsing {
	// Load the next scene
	pcTableView.hidden = YES;
	pcWebView.hidden = NO;
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
