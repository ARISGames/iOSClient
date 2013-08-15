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
#import "ARISMediaView.h"
#import "ARISCollapseView.h"

#import "InventoryViewController.h"

NSString *const kItemDetailsDescriptionHtmlTemplate = 
@"<html>"
@"<head>"
@"	<title>Aris</title>"
@"	<style type='text/css'><!--"
@"	body {"
@"		color: #FFFFFF;"
@"		font-size: 17px;"
@"		font-family: Helvetia, Sans-Serif;"
@"      a:link {COLOR: #0000FF;}"
@"	}"
@"	--></style>"
@"</head>"
@"<body>%@</body>"
@"</html>";

@interface ItemViewController()  <ARISMediaViewDelegate, ARISWebViewDelegate, ARISCollapseViewDelegate, StateControllerProtocol, UIWebViewDelegate, UITextViewDelegate>
{
	//ARISMoviePlayerViewController *mMoviePlayer; //only used if item is a video
	MPMoviePlayerViewController *mMoviePlayer; //only used if item is a video
    
    UIButton *backBtn;
    UIButton *dropBtn;
    UIButton *destroyBtn;
    UIButton *pickupBtn;
    
	ARISMediaView *itemImageView;
    ARISWebView *itemWebView;
	UIScrollView *scrollView;
    UIActivityIndicatorView *activityIndicator;
    ARISCollapseView *descriptionCollapseView;
	ARISWebView *descriptionWebView;
	UIButton *mediaPlaybackButton;
	ItemDetailsModeType mode;
    
    CGRect viewFrame;
    id<GameObjectViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
    id source;
}

@property (nonatomic, assign) ItemDetailsModeType mode;
@property (nonatomic, strong) ARISMediaView *itemImageView;
@property (nonatomic, strong) ARISWebView *itemWebView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ARISWebView *descriptionWebView;
@property (nonatomic, strong) ARISCollapseView *descriptionCollapseView;

@end

@implementation ItemViewController

@synthesize item;
@synthesize mode;
@synthesize itemImageView;
@synthesize itemWebView;
@synthesize activityIndicator;
@synthesize descriptionWebView;
@synthesize descriptionCollapseView;
@synthesize scrollView;

- (id) initWithItem:(Item *)i viewFrame:(CGRect)vf delegate:(id<GameObjectViewControllerDelegate,StateControllerProtocol>)d source:(id)s
{
    if ((self = [super init]))
    {
        viewFrame = vf;
		self.item = i;
        source = s;
        mode = kItemDetailsViewing;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.frame = viewFrame;
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:NSLocalizedString(@"ItemDropKey", @"") forState:UIControlStateNormal];
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor whiteColor]];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [backBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(passPanToDescription:)]];
    
	if([(NSObject *)source isKindOfClass:[InventoryViewController class]] == YES)
    {
        if(item.dropable)
        {
            dropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [dropBtn setTitle:NSLocalizedString(@"ItemDropKey", @"") forState:UIControlStateNormal];
            [dropBtn setBackgroundColor:[UIColor whiteColor]];
            [dropBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            if(item.destroyable)
                dropBtn.frame = CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height-44, self.view.bounds.size.width/3, 44);
            else
                dropBtn.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height-44, self.view.bounds.size.width/2, 44);
            [dropBtn addTarget:self action:@selector(dropButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [dropBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(passPanToDescription:)]];
            [self.view addSubview:dropBtn];
        }
        if(item.destroyable)
        {
            destroyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [destroyBtn setTitle:NSLocalizedString(@"ItemDeleteKey",@"") forState:UIControlStateNormal];
            [destroyBtn setBackgroundColor:[UIColor whiteColor]];
            [destroyBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            if(item.dropable)
                destroyBtn.frame = CGRectMake(2*self.view.bounds.size.width/3, self.view.bounds.size.height-44, self.view.bounds.size.width/3, 44);
            else
                destroyBtn.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height-44, self.view.bounds.size.width/2, 44);
            [dropBtn addTarget:self action:@selector(destroyButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [destroyBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(passPanToDescription:)]];
            [self.view addSubview:destroyBtn];
        }
        
        if(item.dropable && item.destroyable)
            backBtn.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width/3, 44);
        else if(item.dropable || item.destroyable)
            backBtn.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width/2, 44);
        else 
            backBtn.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
	}
	else
    {
        pickupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [pickupBtn setTitle:NSLocalizedString(@"ItemPickupKey", @"") forState:UIControlStateNormal];
        [pickupBtn setBackgroundColor:[UIColor whiteColor]];
        [pickupBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        pickupBtn.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height-44, self.view.bounds.size.width/2, 44);
        backBtn.frame   = CGRectMake(                            0, self.view.bounds.size.height-44, self.view.bounds.size.width/2, 44);
        [pickupBtn addTarget:self action:@selector(pickupButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [pickupBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(passPanToDescription:)]];
        [self.view addSubview:pickupBtn];
	}
    [self.view addSubview:backBtn];
    
    if(self.item.itemType == ItemTypeWebPage && self.item.url && (![self.item.url isEqualToString: @"0"]) &&(![self.item.url isEqualToString:@""]))
    {
        self.itemWebView = [[ARISWebView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-44) delegate:self];
        self.itemWebView.hidden = YES;
        self.itemWebView.allowsInlineMediaPlayback = YES;
        self.itemWebView.mediaPlaybackRequiresUserAction = NO;
        
        [self.itemWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.item.url]] withAppendation:[NSString stringWithFormat:@"itemId=%d",self.item.itemId]];
        [self.view addSubview:self.itemWebView];
    }
    else
    {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height-44)];
        self.scrollView.contentSize = self.scrollView.bounds.size;
        self.scrollView.maximumZoomScale = 100;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.delegate = self;
        
        Media *media;
        if(item.mediaId) media = [[AppModel sharedAppModel] mediaForMediaId:item.mediaId     ofType:@"PHOTO"];
        else             media = [[AppModel sharedAppModel] mediaForMediaId:item.iconMediaId ofType:@"PHOTO"];
        
        if([media.type isEqualToString:@"PHOTO"] && media.url)
        {
            self.itemImageView = [[ARISMediaView alloc] initWithFrame:self.scrollView.frame media:media mode:ARISMediaDisplayModeAspectFit delegate:self];
            [self.scrollView addSubview:self.itemImageView];
        }
        else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
        {        
            AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
            [self.scrollView addSubview:mediaButton];
        }
        
        [self.view addSubview:self.scrollView];
    }
    
    if(![self.item.idescription isEqualToString:@""])
    {
        self.descriptionWebView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,100-10) delegate:self];
        self.descriptionWebView.backgroundColor = [UIColor clearColor];
        self.descriptionWebView.opaque = NO;
        self.descriptionWebView.scrollView.bounces = NO;
        self.descriptionCollapseView = [[ARISCollapseView alloc] initWithView:self.descriptionWebView frame:CGRectMake(0,self.view.bounds.size.height-10-44,self.view.frame.size.width, 10) open:NO showHandle:YES draggable:YES tappable:YES delegate:self];
        [self.descriptionWebView loadHTMLString:[NSString stringWithFormat:kItemDetailsDescriptionHtmlTemplate, self.item.idescription] baseURL:nil];
        [self.view addSubview:self.descriptionCollapseView];
    }
    
	[self updateQuantityDisplay];
}

- (void) passPanToDescription:(UIPanGestureRecognizer *)g
{
    [self.descriptionCollapseView handlePanned:g];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.frame = viewFrame;
}

- (void) updateQuantityDisplay
{
	if(item.qty > 1) self.title = [NSString stringWithFormat:@"%@ x%d",item.name,item.qty];
	else self.title = item.name;
    
    if(item.qty == 0)
    {
        [dropBtn removeFromSuperview];
        [destroyBtn removeFromSuperview];
        [pickupBtn removeFromSuperview];
        backBtn.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44);
    }
}

- (void) backButtonTouched
{
	[[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:0];	
    [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) dropButtonTouched
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

- (void) destroyButtonTouched
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

- (void) pickupButtonTouched
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

- (void) doActionWithMode:(ItemDetailsModeType)itemMode quantity:(int)quantity
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

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
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

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    if(webView == self.itemWebView)
    {
        [self.itemWebView injectHTMLWithARISjs];
        self.itemWebView.hidden = NO;
        [self dismissWaitingIndicator];
    }
    if(webView == self.descriptionWebView)
    {
        float newHeight = [[self.descriptionWebView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue]+20;
        if(newHeight > self.view.bounds.size.height-44) newHeight = self.view.bounds.size.height-44;
        [self.descriptionCollapseView setOpenFrameHeight:newHeight+10];
        self.descriptionWebView.frame = CGRectMake(0, 0, self.descriptionWebView.frame.size.width, newHeight);
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    if(webView == self.itemWebView) [self showWaitingIndicator];
}

- (void) showWaitingIndicator
{
    if(!self.activityIndicator)
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.scrollView.bounds];
    [self.activityIndicator startAnimating];
    [self.scrollView addSubview:self.activityIndicator];
}

- (void) dismissWaitingIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{
    
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
