//
//  ItemViewController.m
//  ARIS
//
//  Created by David Gagnon on 4/2/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ItemViewController.h"
#import "ARISWebView.h"
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
#import "Item.h"
#import "ARISMoviePlayerViewController.h"
#import "AsyncMediaImageView.h"

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

@interface ItemViewController()  <ARISWebViewDelegate, StateControllerProtocol, UIWebViewDelegate, UITextViewDelegate>
{
	//ARISMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
    
	bool descriptionShowing;
	IBOutlet UIToolbar *toolBar;
	IBOutlet UIBarButtonItem *dropButton;
	IBOutlet UIBarButtonItem *deleteButton;
	IBOutlet UIBarButtonItem *pickupButton;
	IBOutlet UIBarButtonItem *detailButton;
    IBOutlet UITextView *textBox;
	IBOutlet AsyncMediaImageView *itemImageView;
	IBOutlet ARISWebView *itemDescriptionView;
    IBOutlet ARISWebView *itemWebView;
	IBOutlet UIScrollView *scrollView;
	UIButton *mediaPlaybackButton;
	ItemDetailsModeType mode;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    id<GameObjectViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
    id source;
}

@property(readwrite) ItemDetailsModeType mode;
@property(nonatomic) IBOutlet AsyncMediaImageView *itemImageView;
@property(nonatomic) IBOutlet ARISWebView *itemWebView;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic) IBOutlet ARISWebView *itemDescriptionView;;
@property(nonatomic) IBOutlet UITextView *textBox;
@property(nonatomic) UIScrollView *scrollView;

- (IBAction) dropButtonTouchAction:(id)sender;
- (IBAction) deleteButtonTouchAction:(id)sender;
- (IBAction) pickupButtonTouchAction:(id)sender;
- (IBAction) toggleDescription:(id)sender;

@end

@implementation ItemViewController

@synthesize item;
@synthesize mode;
@synthesize itemImageView;
@synthesize itemWebView;
@synthesize activityIndicator;
@synthesize itemDescriptionView;
@synthesize textBox;
@synthesize scrollView;

- (id) initWithItem:(Item *)i delegate:(id<GameObjectViewControllerDelegate,StateControllerProtocol>)d source:(id)s
{
    if ((self = [super initWithNibName:@"ItemViewController" bundle:nil]))
    {
        delegate = d;
        source = s;
		self.item = i;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        mode = kItemDetailsViewing;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.itemWebView.delegate = self;
    self.itemDescriptionView.delegate = self;
    
	//Setup the Toolbar Buttons
	dropButton.title   = NSLocalizedString(@"ItemDropKey", @"");
	pickupButton.title = NSLocalizedString(@"ItemPickupKey", @"");
	deleteButton.title = NSLocalizedString(@"ItemDeleteKey",@"");
	detailButton.title = NSLocalizedString(@"ItemDetailKey", @"");
	
    NSMutableArray *barButtonItems = [[NSMutableArray alloc] initWithCapacity:3];
	if([(NSObject *)source isKindOfClass:[InventoryViewController class]] == YES)
    {
		dropButton.width = 75.0;
		deleteButton.width = 75.0;
		detailButton.width = 140.0;
		
        if(item.dropable)                           [barButtonItems addObject:dropButton];
        if(item.destroyable)                        [barButtonItems addObject:deleteButton];
        if(![item.description isEqualToString:@""]) [barButtonItems addObject:detailButton];
	}
	else
    {
		pickupButton.width = 150.0;
		detailButton.width = 150.0;
        
        [barButtonItems addObject:pickupButton];
        if(![item.description isEqualToString:@""]) [barButtonItems addObject:detailButton];
	}
    [toolBar setItems:barButtonItems animated:NO];

    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BackButtonKey",@"") style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonTouchAction:)];    

	[itemDescriptionView loadHTMLString:[NSString stringWithFormat:kItemDetailsDescriptionHtmlTemplate, item.text] baseURL:nil];
    
	Media *media;
    if(item.mediaId) media = [[AppModel sharedAppModel] mediaForMediaId:item.mediaId     ofType:@"PHOTO"];
    else             media = [[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:@"PHOTO"];
    
	if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
		[itemImageView loadMedia:media];
        itemImageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {        
        AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
        [self.scrollView addSubview:mediaButton];
	}
	else
		NSLog(@"ItemDetailsVC: Error Loading Media ID: %d. It etiher doesn't exist or is not of a valid type.", item.mediaId);
    
    self.itemWebView.hidden = YES;

	[self updateQuantityDisplay];
    if(self.item.itemType == ItemTypeWebPage && self.item.url && (![self.item.url isEqualToString: @"0"]) &&(![self.item.url isEqualToString:@""]))
    {
        self.itemWebView.allowsInlineMediaPlayback = YES;
        self.itemWebView.mediaPlaybackRequiresUserAction = NO;
        
        [itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.item.url]] withAppendation:[NSString stringWithFormat:@"itemId=%d",self.item.itemId]];
    }
    else itemWebView.hidden = YES;
}

- (void)updateQuantityDisplay
{
	if(item.qty > 1) self.title = [NSString stringWithFormat:@"%@ x%d",item.name,item.qty];
	else self.title = item.name;
}

- (void) backButtonTouchAction:(id)sender
{
	[[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:0];	
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (IBAction)dropButtonTouchAction:(id)sender
{	
	mode = kItemDetailsDropping;
	if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item mode:mode delegate:self source:source];
        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
    }
    else 
    {
        [self doActionWithMode:mode quantity:1];
    }    
}

- (IBAction)deleteButtonTouchAction:(id)sender
{
	mode = kItemDetailsDestroying;
	if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item mode:mode delegate:self source:source];

        itemActionVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
        [[self navigationController] pushViewController:itemActionVC animated:YES];
        [self updateQuantityDisplay];
    }
    else 
        [self doActionWithMode:mode quantity:1];
}

- (IBAction)pickupButtonTouchAction:(id)sender
{
	mode = kItemDetailsPickingUp;
    if(self.item.qty > 1)
    {
        ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithItem:item mode:mode delegate:self source:source];
        
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
		
	if(mode == kItemDetailsDropping)
    {
		[[AppServices sharedAppServices] updateServerDropItemHere:item.itemId qty:quantity];
		[[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:quantity];
    }
	else if(mode == kItemDetailsDestroying)
    {
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
			else if(item.maxQty == 0)
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
			if([(NSObject *)source isKindOfClass:[Location class]])
            {
                [[AppServices sharedAppServices] updateServerPickupItem:self.item.itemId fromLocation:((Location *)source).locationId qty:quantity];
                [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:-quantity forLocationId:((Location *)source).locationId];
            }
            
            [[AppServices sharedAppServices] updateServerAddInventoryItem:self.item.itemId addQty:quantity];
			item.qty -= quantity;
        }
	}
	
	[self updateQuantityDisplay];
	
	if (item.qty < 1) pickupButton.enabled = NO;
	else              pickupButton.enabled = YES;
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
	[self dismissMoviePlayerViewControllerAnimated];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
	return itemImageView;
}

- (void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, scale, scale);
	itemImageView.transform = transform;
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
	
    if([touch tapCount] == 2)
    {
		CGAffineTransform transform = CGAffineTransformIdentity;
		transform = CGAffineTransformScale(transform, 1.0, 1.0);
		itemImageView.transform = transform;
    }
}

- (void) showView:(UIView *)aView 
{
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height - aView.frame.size.height - toolBar.frame.size.height;
    viewFrame.size.height = aView.frame.size.height;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void) hideView:(UIView *)aView 
{
	CGRect superFrame = [aView superview].bounds;
	CGRect viewFrame = [aView frame];
	viewFrame.origin.y = superFrame.origin.y + superFrame.size.height;
	[UIView beginAnimations:nil context:NULL]; //we animate the transition
	[aView setFrame:viewFrame];
	[UIView commitAnimations]; //run animation
}

- (void) toggleDescription:(id)sender 
{
	ARISAppDelegate* appDelegate = (ARISAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playAudioAlert:@"swish" shouldVibrate:NO];
	
	if(descriptionShowing)
    {
		[self hideView:self.itemDescriptionView];
		descriptionShowing = NO;
	}
    else
    {
		[self showView:self.itemDescriptionView];
		descriptionShowing = YES;
	}
}

- (void) ARISWebViewRequestsDismissal:(ARISWebView *)awv
{
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) ARISWebViewRequestsRefresh:(ARISWebView *)awv
{
    //ignore
}

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:self];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(webView == self.itemWebView) return (![self.itemWebView handleARISRequestIfApplicable:request]);
    else if(![[[request URL] absoluteString] isEqualToString:@"about:blank"])
    {
        WebPage *tempWebPage = [[WebPage alloc] init];
        tempWebPage.url = [[request URL] absoluteString];
        [delegate displayGameObject:tempWebPage fromSource:self];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if(webView == self.itemWebView)
    {
        [self.itemWebView injectHTMLWithARISjs];
        self.itemWebView.hidden = NO;
        [self dismissWaitingIndicator];
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    if(webView == self.itemWebView) [self showWaitingIndicator];
}

-(void)showWaitingIndicator
{
    [self.activityIndicator startAnimating];
}

-(void)dismissWaitingIndicator
{
    [self.activityIndicator stopAnimating];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
