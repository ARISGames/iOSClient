//
//  ItemDetailsViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ItemDetailsViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Media.h"
#import "Item.h"
#import "ItemActionViewController.h"
#import "WebPage.h"
#import "webpageViewController.h"
#import "NoteEditorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Scale.h"


NSString *const kItemDetailsDescriptionHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		background-color: #000000;"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      a:link {COLOR: #0000FF;}"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";



@implementation ItemDetailsViewController
@synthesize item, inInventory,mode,itemImageView, itemWebView,activityIndicator,isLink,itemDescriptionView,textBox,saveButton,scrollView;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(movieLoadStateChanged:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:nil];
		mode = kItemDetailsViewing;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget: [RootViewController sharedRootViewController] withObject: @"Loading..."];	
	//[[RootViewController sharedRootViewController]showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
    
	self.itemWebView.delegate = self;
    self.itemDescriptionView.delegate = self;
    
    [RootViewController sharedRootViewController].modalPresent = YES;
    [RootViewController sharedRootViewController].isItemDetailsMovie = NO;
	//Setup the Toolbar Buttons
	dropButton.title = NSLocalizedString(@"ItemDropKey", @"");
	pickupButton.title = NSLocalizedString(@"ItemPickupKey", @"");
	deleteButton.title = NSLocalizedString(@"ItemDeleteKey",@"");
	detailButton.title = NSLocalizedString(@"ItemDetailKey", @"");
	
	if (inInventory == YES) {		
		dropButton.width = 75.0;
		deleteButton.width = 75.0;
		detailButton.width = 140.0;
		
		[toolBar setItems:[NSMutableArray arrayWithObjects: dropButton, deleteButton, detailButton,  nil] animated:NO];
        
		if (!item.dropable) dropButton.enabled = NO;
		if (!item.destroyable) deleteButton.enabled = NO;
	}
	else {
		pickupButton.width = 150.0;
		detailButton.width = 150.0;
        
		[toolBar setItems:[NSMutableArray arrayWithObjects: pickupButton,detailButton, nil] animated:NO];
	}
	
	//Create a close button
	self.navigationItem.leftBarButtonItem = 
	[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"")
									 style: UIBarButtonItemStyleBordered
									target:self 
									action:@selector(backButtonTouchAction:)];	
	
	
    
	NSLog(@"ItemDetailsViewController: View Loaded. Current item: %@", item.name);
    
    
	//Set Up General Stuff
	NSString *htmlDescription = [NSString stringWithFormat:kItemDetailsDescriptionHtmlTemplate, item.description];
	[itemDescriptionView loadHTMLString:htmlDescription baseURL:nil];
    
	Media *media = [[AppModel sharedAppModel] mediaForMediaId: item.mediaId];
    
	if ([media.type isEqualToString: kMediaTypeImage] && media.url) {
		NSLog(@"ItemDetailsViewController: Image Layout Selected");
		[itemImageView loadImageFromMedia:media];
        itemImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	else if (([media.type isEqualToString:kMediaTypeVideo] || [media.type isEqualToString: kMediaTypeAudio]) && media.url) {
		NSLog(@"ItemDetailsViewController:  AV Layout Selected");
        
		//Setup the Button
        mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        [mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        [mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        //Create movie player object
        mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        [mMoviePlayer shouldAutorotateToInterfaceOrientation:YES];
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];
        
        //Setup the overlay
        UIImageView *playButonOverlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_button.png"]];
        playButonOverlay.center = mediaPlaybackButton.center;
        [mediaPlaybackButton addSubview:playButonOverlay];
        [self.scrollView addSubview:mediaPlaybackButton];
	}
	
	else {
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", item.mediaId);
	}
    self.itemWebView.hidden = YES;
	//Stop Waiting Indicator
	//[[RootViewController sharedRootViewController] removeWaitingIndicator];
	[self updateQuantityDisplay];
    if (self.item.url && (![self.item.url isEqualToString: @"0"]) &&(![self.item.url isEqualToString:@""])) {
        
        //Config the webView
        self.itemWebView.allowsInlineMediaPlayback = YES;
        self.itemWebView.mediaPlaybackRequiresUserAction = NO;
        
        
        NSString *urlAddress = [self.item.url stringByAppendingString: [NSString stringWithFormat: @"?playerId=%d&gameId=%d",[AppModel sharedAppModel].playerId,[AppModel sharedAppModel].currentGame.gameId]];
        
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [itemWebView loadRequest:requestObj];
    }
    else itemWebView.hidden = YES;
    if([self.item.type isEqualToString: @"NOTE"])
    {
        UIBarButtonItem *hideKeyboardButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HideKeyboardKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(hideKeyboard)];      
        self.navigationItem.rightBarButtonItem = hideKeyboardButton;
        saveButton.frame = CGRectMake(0, 335, 320, 37);
        textBox.text = item.description;
        [self.scrollView addSubview:textBox];
        [self.scrollView addSubview:saveButton];
        if(([AppModel sharedAppModel].playerId != self.item.creatorId)) {
            self.textBox.userInteractionEnabled = NO;
            [saveButton removeFromSuperview];
            self.navigationItem.rightBarButtonItem = nil;        
        }
    }
    else if (self.item.creatorId == [AppModel sharedAppModel].playerId) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EditKey", @"") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
        self.navigationItem.rightBarButtonItem = editButton;
    }
    
	item.hasViewed = YES;
    
}

-(void)viewDidAppear:(BOOL)animated{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)updateQuantityDisplay {
	if (item.qty > 1) self.title = [NSString stringWithFormat:@"%@ x%d",item.name,item.qty];
	else self.title = item.name;
}

-(void)editButtonPressed{
    [self displayTitleandDescriptionForm];
}

- (IBAction)backButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: Notify server of Item view and Dismiss Item Details View");
	
	//Notify the server this item was displayed
	[[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:item.locationId];
	
	
	[self.navigationController popToRootViewControllerAnimated:YES];
    [RootViewController sharedRootViewController].modalPresent=NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];		
}

-(IBAction)playMovie:(id)sender {
    [RootViewController sharedRootViewController].isItemDetailsMovie = YES;
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}


- (IBAction)dropButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Drop Button Pressed");
	
	mode = kItemDetailsDropping;
	if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc]initWithNibName:@"ItemActionViewController" bundle:nil];
        itemActionVC.mode = mode;
        itemActionVC.item = item;
        itemActionVC.delegate = self;
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
        
    }
    else 
    {
        [self doActionWithMode:mode quantity:1];
    }    
	
}

- (IBAction)deleteButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsVC: Destroy Button Pressed");
    
	
	mode = kItemDetailsDestroying;
	if(self.item.qty > 1)
    {
        
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc]initWithNibName:@"ItemActionViewController" bundle:nil];
        itemActionVC.mode = mode;
        itemActionVC.item = item;
        itemActionVC.delegate = self;
        
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
        
        
    }
    else 
    {
        
        [self doActionWithMode:mode quantity:1];
    }
}


- (IBAction)pickupButtonTouchAction: (id) sender{
	NSLog(@"ItemDetailsViewController: pickupButtonTouched");
    
	
	mode = kItemDetailsPickingUp;
	
    if(self.item.qty > 1)
    {
        
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc]initWithNibName:@"ItemActionViewController" bundle:nil];
        itemActionVC.mode = mode;
        itemActionVC.item = item;
        itemActionVC.delegate = self;
        
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
        
        
    }
    else 
    {
        [self doActionWithMode:mode quantity:1];
    }
    
    //Notify the server this item was displayed:
    [[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:item.locationId];
    
}


-(void)doActionWithMode: (ItemDetailsModeType) itemMode quantity: (int) quantity {
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"drop" shouldVibrate:YES];
	
	//Determine the Quantity Effected based on the button touched
    
	
	
	//Do the action based on the mode of the VC
	if (mode == kItemDetailsDropping) {
		NSLog(@"ItemDetailsVC: Dropping %d",quantity);
		[[AppServices sharedAppServices] updateServerDropItemHere:item.itemId qty:quantity];
		[[AppModel sharedAppModel] removeItemFromInventory:item qtyToRemove:quantity];
        
    }
	else if (mode == kItemDetailsDestroying) {
		NSLog(@"ItemDetailsVC: Destroying %d",quantity);
		[[AppServices sharedAppServices] updateServerDestroyItem:self.item.itemId qty:quantity];
		[[AppModel sharedAppModel] removeItemFromInventory:item qtyToRemove:quantity];
		
	}
	else if (mode == kItemDetailsPickingUp) {
        NSString *errorMessage;
        
		//Determine if this item can be picked up
		Item *itemInInventory  = [[AppModel sharedAppModel].inventory objectForKey:[NSString stringWithFormat:@"%d",item.itemId]];
		if (itemInInventory.qty + quantity > item.maxQty && item.maxQty != -1) {
            
			[appDelegate playAudioAlert:@"error" shouldVibrate:YES];
			
			if (itemInInventory.qty < item.maxQty) {
				quantity = item.maxQty - itemInInventory.qty;
                
                if([AppModel sharedAppModel].currentGame.inventoryWeightCap != 0){
                    while((quantity*item.weight + [AppModel sharedAppModel].currentGame.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryWeightCap){
                        quantity--;
                    }
                }
				errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionCarryThatMuchKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
                
			}
			else if (item.maxQty == 0) {
				errorMessage = NSLocalizedString(@"ItemAcionCannotPickUpKey", @"");
				quantity = 0;
			}
            else {
				errorMessage = NSLocalizedString(@"ItemAcionCannotCarryMoreKey", @"");
				quantity = 0;
			}
            
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:  NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message: errorMessage
														   delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
			[alert show];
            
            
		}
        else if (((quantity*item.weight +[AppModel sharedAppModel].currentGame.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryWeightCap)&&([AppModel sharedAppModel].currentGame.inventoryWeightCap != 0)){
            while ((quantity*item.weight + [AppModel sharedAppModel].currentGame.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryWeightCap) {
                quantity--;
            }
            errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionTooHeavyKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:  NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message: errorMessage
														   delegate: self cancelButtonTitle: NSLocalizedString(@"OkKey", @"") otherButtonTitles: nil];
			[alert show];
        }
        
		if (quantity > 0) 
        {
			[[AppServices sharedAppServices] updateServerPickupItem:self.item.itemId fromLocation:self.item.locationId qty:quantity];
			[[AppModel sharedAppModel] modifyQuantity:-quantity forLocationId:self.item.locationId];
			item.qty -= quantity; //the above line does not give us an update, only the map
        }
	}
	
	[self updateQuantityDisplay];
	
	//Possibly Dismiss Item Details View
	/*if (item.qty < 1) {
		[self.navigationController popToRootViewControllerAnimated:YES];
        [RootViewController sharedRootViewController].modalPresent = NO;
        [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
	}*/
}

#pragma mark MPMoviePlayerController Notification Handlers

- (void)movieLoadStateChanged:(NSNotification*) aNotification{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
	
	if( state & MPMovieLoadStateUnknown ) 
		NSLog(@"ItemDetailsViewController: Unknown Load State");
    if( state & MPMovieLoadStatePlaythroughOK ) 
		NSLog(@"ItemDetailsViewController: Playthrough OK Load State");
    if( state & MPMovieLoadStateStalled ) 
		NSLog(@"ItemDetailsViewController: Stalled Load State");
	if( state & MPMovieLoadStatePlayable ) 
    {
		NSLog(@"ItemDetailsViewController: Playable Load State");
        
        //Create a thumbnail for the button
        if (![mediaPlaybackButton backgroundImageForState:UIControlStateNormal]) 
        {
            UIImage *videoThumb = [mMoviePlayer.moviePlayer thumbnailImageAtTime:(NSTimeInterval)1.0 timeOption:MPMovieTimeOptionExact];            
            UIImage *videoThumbSized = [videoThumb scaleToSize:CGSizeMake(320, 240)];        
            [mediaPlaybackButton setBackgroundImage:videoThumbSized forState:UIControlStateNormal];
        }
	} 
}


- (void)movieFinishedCallback:(NSNotification*) aNotification
{
	NSLog(@"ItemDetailsViewController: movieFinishedCallback");
	[self dismissMoviePlayerViewControllerAnimated];
}


#pragma mark Zooming delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	NSLog(@"got a viewForZooming.");
	return itemImageView;
}

- (void) scrollViewDidEndZooming: (UIScrollView *) scrollView withView: (UIView *) view atScale: (float) scale
{
	NSLog(@"got a scrollViewDidEndZooming. Scale: %f", scale);
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, scale, scale);
	itemImageView.transform = transform;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch       *touch = [touches anyObject];
	NSLog(@"got a touchesEnded.");
	
    if([touch tapCount] == 2) {
		//NSLog(@"TouchCount is 2.");
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformScale(transform, 1.0, 1.0);
		itemImageView.transform = transform;
    }
}

#pragma mark Animate view show/hide

- (void)showView:(UIView *)aView 
{
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height - aView.frame.size.height - toolBar.frame.size.height;
    viewFrame.size.height = aView.frame.size.height;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void)hideView:(UIView *)aView 
{
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void)toggleDescription:(id)sender 
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
	
	if (descriptionShowing) { //description is showing, so hide
		[self hideView:self.itemDescriptionView];
		//[notesButton setStyle:UIBarButtonItemStyleBordered]; //set button style
		descriptionShowing = NO;
	} else {  //description is not showing, so show
		[self showView:self.itemDescriptionView];
		//[notesButton setStyle:UIBarButtonItemStyleDone];
		descriptionShowing = YES;
	}
}
#pragma mark WebViewDelegate 

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(webView == self.itemWebView){
    if ([[[request URL] absoluteString] hasPrefix:@"aris://closeMe"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [RootViewController sharedRootViewController].modalPresent=NO;
        [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];
        return NO; 
    }  
    else if ([[[request URL] absoluteString] hasPrefix:@"aris://refreshStuff"]) {
        [[AppServices sharedAppServices] fetchAllPlayerLists];
        return NO; 
    }   
    }else{
        if(self.isLink && ![[[request URL]absoluteString] isEqualToString:@"about:blank"]) {
            webpageViewController *webPageViewController = [[webpageViewController alloc] initWithNibName:@"webpageViewController" bundle: [NSBundle mainBundle]];
            WebPage *temp = [[WebPage alloc]init];
            temp.url = [[request URL]absoluteString];
            webPageViewController.webPage = temp;
            webPageViewController.delegate = self;
            [self.navigationController pushViewController:webPageViewController animated:NO];
            
            return NO;
        }
        else
        {
            self.isLink = YES;
            return YES;
        }
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.itemWebView){
        self.itemWebView.hidden = NO;
        [self dismissWaitingIndicator];}
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    if(webView == self.itemWebView)[self showWaitingIndicator];
}

-(void)showWaitingIndicator {
    [self.activityIndicator startAnimating];
}

-(void)dismissWaitingIndicator {
    [self.activityIndicator stopAnimating];
}

#pragma mark Note functions
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if([self.textBox.text isEqualToString:@"Write note here..."])
        [self.textBox setText:@""];
    self.textBox.frame = CGRectMake(0, 0, 320, 230);
}

-(void)hideKeyboard {
    [self.textBox resignFirstResponder];
    self.textBox.frame = CGRectMake(0, 0, 320, 335);
}

-(void)saveButtonTouchAction{
    [self.saveButton setBackgroundColor:[UIColor lightGrayColor]];
    [self displayTitleandDescriptionForm];
}

- (void)displayTitleandDescriptionForm {
    TitleAndDecriptionFormViewController *titleAndDescForm = [[TitleAndDecriptionFormViewController alloc] 
                                                              initWithNibName:@"TitleAndDecriptionFormViewController" bundle:nil];
    titleAndDescForm.item = self.item;
	titleAndDescForm.delegate = self;
	[self.view addSubview:titleAndDescForm.view];
}

- (void)titleAndDescriptionFormDidFinish:(TitleAndDecriptionFormViewController*)titleAndDescForm{
	NSLog(@"NoteVC: Back from form");
	[titleAndDescForm.view removeFromSuperview];
    item.name = titleAndDescForm.titleField.text;
    if([item.type isEqualToString: @"NOTE"])
        item.description = textBox.text;
    else item.description = titleAndDescForm.descriptionField.text;
    [[AppServices sharedAppServices] updateItem:self.item];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    [RootViewController sharedRootViewController].modalPresent=NO;
    [[RootViewController sharedRootViewController] dismissNearbyObjectView:self];	
        
}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    NSLog(@"Item Details View: Dealloc");
	// free our movie player
	//remove listeners
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
