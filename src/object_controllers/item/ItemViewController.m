//
//  ItemViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ItemViewController.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "AsyncMediaPlayerButton.h"
#import "Media.h"
#import "Item.h"
#import "ItemActionViewController.h"
#import "WebPage.h"
#import "WebPageViewController.h"
#import "NpcViewController.h"
#import "NoteEditorViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+Scale.h"

#import "InventoryViewController.h"

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

@implementation ItemViewController
@synthesize item, inInventory,mode,itemImageView, itemWebView,activityIndicator,itemDescriptionView,textBox,saveButton,scrollView;

- (id) initWithItem:(Item *)i delegate:(id<GameObjectViewControllerDelegate>)d source:(id)s
{
    if ((self = [super initWithNibName:@"ItemViewController" bundle:nil]))
    {
        delegate = d;

		self.item = i;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(movieFinishedCallback:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self
		//										 selector:@selector(movieLoadStateChanged:)
		//											 name:MPMoviePlayerLoadStateDidChangeNotification
		//										   object:nil];
        if([(NSObject *)s isKindOfClass:[InventoryViewController class]])
            inInventory = YES;
        
        mode = kItemDetailsViewing;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Show waiting Indicator in own thread so it appears on time
	//[NSThread detachNewThreadSelector: @selector(showWaitingIndicator:) toTarget:[RootViewController sharedRootViewController] withObject: @"Loading..."];	
	//[[RootViewController sharedRootViewController]showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"") displayProgressBar:NO];
    
	self.itemWebView.delegate = self;
    self.itemDescriptionView.delegate = self;
    
	//Setup the Toolbar Buttons
	dropButton.title   = NSLocalizedString(@"ItemDropKey", @"");
	pickupButton.title = NSLocalizedString(@"ItemPickupKey", @"");
	deleteButton.title = NSLocalizedString(@"ItemDeleteKey",@"");
	detailButton.title = NSLocalizedString(@"ItemDetailKey", @"");
	
	if (inInventory == YES)
    {
		dropButton.width = 75.0;
		deleteButton.width = 75.0;
		detailButton.width = 140.0;
		
		[toolBar setItems:[NSMutableArray arrayWithObjects: dropButton, deleteButton, detailButton,  nil] animated:NO];
        
		if(!item.dropable)    dropButton.enabled   = NO;
		if(!item.destroyable) deleteButton.enabled = NO;
	}
	else
    {
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
	//Set Up General Stuff
	NSString *htmlDescription = [NSString stringWithFormat:kItemDetailsDescriptionHtmlTemplate, item.text];
	[itemDescriptionView loadHTMLString:htmlDescription baseURL:nil];
    
	Media *media = [[AppModel sharedAppModel] mediaForMediaId:item.mediaId];
        
	if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
		[itemImageView loadMedia:media];
        itemImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {        
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presentingController:[RootViewController sharedRootViewController] preloadNow:NO];
        //mediaArea.frame = CGRectMake(0, 0, 300, 240);
        [self.scrollView addSubview:mediaButton];
        //mediaArea.frame = CGRectMake(0, 0, 300, 240);
        
        /*
		//Setup the Button
        mediaPlaybackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
        [mediaPlaybackButton addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
        [mediaPlaybackButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[mediaPlaybackButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        
        //Create movie player object
        mMoviePlayer = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:media.url]];
        mMoviePlayer.moviePlayer.shouldAutoplay = NO;
        [mMoviePlayer.moviePlayer prepareToPlay];
        
        //Setup the overlay
        UIImageView *playButonOverlay = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_button.png"]];
        playButonOverlay.center = mediaPlaybackButton.center;
        [mediaPlaybackButton addSubview:playButonOverlay];
        [self.scrollView addSubview:mediaPlaybackButton];
        */
	}
	else
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", item.mediaId);
    
    self.itemWebView.hidden = YES;
	//Stop Waiting Indicator
	//[[RootViewController sharedRootViewController] removeWaitingIndicator];
	[self updateQuantityDisplay];
    if (self.item.itemType == ItemTypeWebPage && self.item.url && (![self.item.url isEqualToString: @"0"]) &&(![self.item.url isEqualToString:@""]))
    {
        //Config the webView
        self.itemWebView.allowsInlineMediaPlayback = YES;
        self.itemWebView.mediaPlaybackRequiresUserAction = NO;
        
        NSString *urlAddress = [self.item.url stringByAppendingString: [NSString stringWithFormat: @"?playerId=%d&gameId=%d",[AppModel sharedAppModel].player.playerId,[AppModel sharedAppModel].currentGame.gameId]];
        
        //Create a URL object.
        NSURL *url = [NSURL URLWithString:urlAddress];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //Load the request in the UIWebView.
        [itemWebView loadRequest:requestObj];
    }
    else itemWebView.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
}

- (void)updateQuantityDisplay
{
	if (item.qty > 1) self.title = [NSString stringWithFormat:@"%@ x%d",item.name,item.qty];
	else self.title = item.name;
}

- (IBAction)backButtonTouchAction:(id)sender
{
	[[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:0];	
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

-(IBAction)playMovie:(id)sender
{
	[self presentMoviePlayerViewControllerAnimated:mMoviePlayer];
}

- (IBAction)dropButtonTouchAction:(id)sender
{
	NSLog(@"ItemDetailsVC: Drop Button Pressed");
	
	mode = kItemDetailsDropping;
	if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item];
        itemActionVC.mode = mode;
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
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item];
        itemActionVC.mode = mode;
        itemActionVC.delegate = self;
        
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
    }
    else 
        [self doActionWithMode:mode quantity:1];
}

- (IBAction)pickupButtonTouchAction:(id)sender
{
	NSLog(@"ItemViewController: pickupButtonTouched");
	mode = kItemDetailsPickingUp;
    if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item];
        itemActionVC.mode = mode;
        itemActionVC.delegate = self;
        
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
    }
    else 
        [self doActionWithMode:mode quantity:1];
    
    [[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:0];
}

-(void)doActionWithMode:(ItemDetailsModeType)itemMode quantity:(int)quantity
{
    ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"drop" shouldVibrate:YES];
		
	//Do the action based on the mode of the VC
	if(mode == kItemDetailsDropping)
    {
		NSLog(@"ItemDetailsVC: Dropping %d",quantity);
		[[AppServices sharedAppServices] updateServerDropItemHere:item.itemId qty:quantity];
		[[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:quantity];
    }
	else if(mode == kItemDetailsDestroying)
    {
		NSLog(@"ItemDetailsVC: Destroying %d",quantity);
		[[AppServices sharedAppServices] updateServerDestroyItem:self.item.itemId qty:quantity];
		[[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:quantity];
	}
	else if(mode == kItemDetailsPickingUp)
    {
        NSString *errorMessage;
        
		//Determine if this item can be picked up
		Item *itemInInventory  = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
		if(itemInInventory && itemInInventory.qty + quantity > item.maxQty && item.maxQty != -1)
        {
			[appDelegate playAudioAlert:@"error" shouldVibrate:YES];
			
			if (itemInInventory.qty < item.maxQty)
            {
				quantity = item.maxQty - itemInInventory.qty;
                
                if([AppModel sharedAppModel].currentGame.inventoryModel.weightCap != 0)
                {
                    while((quantity*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap){
                        quantity--;
                    }
                }
				errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionCarryThatMuchKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
			}
			else if (item.maxQty == 0)
            {
				errorMessage = NSLocalizedString(@"ItemAcionCannotPickUpKey", @"");
				quantity = 0;
			}
            else
            {
				errorMessage = NSLocalizedString(@"ItemAcionCannotCarryMoreKey", @"");
				quantity = 0;
			}
            
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message:errorMessage
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
			[alert show];
		}
        else if (((quantity*item.weight +[AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)&&([AppModel sharedAppModel].currentGame.inventoryModel.weightCap != 0))
        {
            while ((quantity*item.weight + [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight) > [AppModel sharedAppModel].currentGame.inventoryModel.weightCap)

                quantity--;

            errorMessage = [NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionTooHeavyKey", @""),quantity,NSLocalizedString(@"PickedUpKey", @"")];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
															message:errorMessage
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
			[alert show];
        }
        
		if (quantity > 0) 
        {
			//TODO [[AppServices sharedAppServices] updateServerPickupItem:self.item.itemId fromLocation:self.item.locationId qty:quantity];
			//TODO [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:-quantity forLocationId:self.item.locationId];
			item.qty -= quantity; //the above line does not give us an update, only the map
        }
	}
	
	[self updateQuantityDisplay];
	
	if (item.qty < 1) pickupButton.enabled = NO;
	else              pickupButton.enabled = YES;
}

#pragma mark MPMoviePlayerController Notification Handlers

- (void)movieLoadStateChanged:(NSNotification*) aNotification
{
	MPMovieLoadState state = [(MPMoviePlayerController *) aNotification.object loadState];
	
	if(state & MPMovieLoadStateUnknown)
		NSLog(@"ItemViewController: Unknown Load State");
    if(state & MPMovieLoadStatePlaythroughOK)
		NSLog(@"ItemViewController: Playthrough OK Load State");
    if(state & MPMovieLoadStateStalled)
		NSLog(@"ItemViewController: Stalled Load State");
	if(state & MPMovieLoadStatePlayable)
    {
		NSLog(@"ItemViewController: Playable Load State");
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
	NSLog(@"ItemViewController: movieFinishedCallback");
	[self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark Zooming delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
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

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(webView == self.itemWebView)
    {
        if ([[[request URL] absoluteString] hasPrefix:@"aris://closeMe"])
        {
            [delegate gameObjectViewControllerRequestsDismissal:self];
            return NO;
        }
        else if ([[[request URL] absoluteString] hasPrefix:@"aris://refreshStuff"])
        {
            [[AppServices sharedAppServices] fetchAllPlayerLists];
            return NO;
        }
    }
    else
    {
        if(![[[request URL]absoluteString] isEqualToString:@"about:blank"])
        {
            WebPage *tempWebPage = [[WebPage alloc] init];
            tempWebPage.url = [[request URL] absoluteString];
            //PHIL TODO: Convert to ARIS WebView. First, create ARIS WebView.
            //[delegate displayGameObject:tempWebPage];
            
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(webView == self.itemWebView)
    {
        self.itemWebView.hidden = NO;
        [self dismissWaitingIndicator];
    }
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
    itemDescriptionView.delegate = nil;
    [itemDescriptionView stopLoading];
    itemWebView.delegate = nil;
    [itemWebView stopLoading];
}

@end
