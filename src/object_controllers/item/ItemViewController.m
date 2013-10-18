//
//  ItemViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 10/17/13.
//
//

#import "ItemViewController.h"

#import "ItemActionViewController.h"
#import "InventoryTagViewController.h"

#import "Item.h"
#import "ARISWebView.h"
#import "ARISMediaView.h"
#import "AsyncMediaPlayerButton.h"
#import "ARISCollapseView.h"
#import "AppModel.h"
#import "AppServices.h"

#import "UIColor+ARISColors.h"

@interface ItemViewController()  <ARISMediaViewDelegate, ARISWebViewDelegate, ARISCollapseViewDelegate, StateControllerProtocol, ItemActionViewControllerDelegate, UITextViewDelegate>
{
  //Labels as buttons (easier formatting)
  UILabel *dropBtn;
  UILabel *destroyBtn; 
  UILabel *pickupBtn;  
  UIView *line; //separator between buttons/etc...

  ARISWebView *webView;
  ARISCollapseView *collapseView;
  ARISWebView *descriptionView;
  UIScrollView *scrollView;
  ARISMediaView *imageView;
    
    UIActivityIndicatorView *activityIndicator;

  id<GameObjectViewControllerDelegate,StateControllerProtocol> __unsafe_unretained delegate;
  id<ItemViewControllerSource> __unsafe_unretained source; 
}
@end

@implementation ItemViewController

@synthesize item;

- (id) initWithItem:(Item *)i delegate:(id<GameObjectViewControllerDelegate,StateControllerProtocol>)d source:(id<ItemViewControllerSource>)s
{
  if(self = [super init])
  {
      self.item = i;
    delegate = d;
    source = s;
  }
  return self;
}

//Helper to cleanly/consistently create bottom buttons
- (UILabel *) createItemButtonWithText:(NSString *)t selector:(SEL)s
{
  UILabel *btn = [[UILabel alloc] init];
  btn.userInteractionEnabled = YES;
  btn.textAlignment = NSTextAlignmentCenter;
  btn.text = t;
  btn.backgroundColor = [UIColor ARISColorTextBackdrop];
  btn.textColor       = [UIColor ARISColorText];
  [btn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:s]];
  [btn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(passPanToDescription:)]];

  return btn;
}

- (void) loadView
{
  [super loadView];
  self.view.backgroundColor = [UIColor ARISColorContentBackdrop];

  int numButtons = 0;
    /*
     //What it SHOULD be \/
  if([source supportsDestroying] && self.item.destroyable) { destroyBtn = [self createItemButtonWithText:@"Destroy" selector:@selector(destroyButtonTouched)]; numButtons++; }
  if([source supportsDropping]   && self.item.dropable)    { dropBtn    = [self createItemButtonWithText:@"Drop" selector:@selector(DropButtonTouched)];       numButtons++; }
  if([source supportsPickingUp]  && self.item.qty > 0)     { pickupBtn  = [self createItemButtonWithText:@"Pick Up" selector:@selector(pickupButtonTouched)];  numButtons++; }
     */
    
    //What it IS
    if([(NSObject *)source isKindOfClass:[InventoryTagViewController class]] && self.item.destroyable) { destroyBtn = [self createItemButtonWithText:@"Destroy" selector:@selector(destroyButtonTouched)]; numButtons++; }
    if([(NSObject *)source isKindOfClass:[InventoryTagViewController class]] && self.item.dropable)    { dropBtn    = [self createItemButtonWithText:@"Drop" selector:@selector(DropButtonTouched)];       numButtons++; }
    if([(NSObject *)source isKindOfClass:[Location class]] && self.item.qty != 0)     { pickupBtn  = [self createItemButtonWithText:@"Pick Up" selector:@selector(pickupButtonTouched)];  numButtons++; } 
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 1)];
    line.backgroundColor = [UIColor ARISColorLightGray];

  //Web Item
  if(self.item.itemType == ItemTypeWebPage && self.item.url && (![self.item.url isEqualToString: @"0"]) &&(![self.item.url isEqualToString:@""]))
  {
    webView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) delegate:self];
    if(numButtons > 0) webView.scrollView.contentInset = UIEdgeInsetsMake(64,0,54,0);
    else               webView.scrollView.contentInset = UIEdgeInsetsMake(64,0,10,0);

    webView.hidden                          = YES;
    webView.scalesPageToFit                 = YES;
    webView.allowsInlineMediaPlayback       = YES;
    webView.mediaPlaybackRequiresUserAction = NO;

    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.item.url]] withAppendation:[NSString stringWithFormat:@"itemId=%d",self.item.itemId]];
  }
  //Normal Item
  else
  {
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    if(numButtons > 0) scrollView.contentInset = UIEdgeInsetsMake(64,0,54,0);
    else               scrollView.contentInset = UIEdgeInsetsMake(64,0,10,0);
    scrollView.clipsToBounds    = NO;
    scrollView.maximumZoomScale = 100;
    scrollView.minimumZoomScale = 1;
    scrollView.delegate = self;

    Media *media;
    if(self.item.mediaId) media = [[AppModel sharedAppModel] mediaForMediaId:self.item.mediaId     ofType:@"PHOTO"];
    else                  media = [[AppModel sharedAppModel] mediaForMediaId:self.item.iconMediaId ofType:@"PHOTO"];

    if([media.type isEqualToString:@"PHOTO"] && media.url)
    {
      imageView = [[ARISMediaView alloc] initWithFrame:CGRectMake(0,0,scrollView.frame.size.width,scrollView.frame.size.height-64) media:media mode:ARISMediaDisplayModeAspectFit delegate:self];
      [scrollView addSubview:imageView];
      [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passTapToDescription:)]];
    }
    else if(([media.type isEqualToString:@"VIDEO"] || [media.type isEqualToString:@"AUDIO"]) && media.url)
    {        
      AsyncMediaPlayerButton *mediaButton = [[AsyncMediaPlayerButton alloc] initWithFrame:CGRectMake(8, 0, 304, 244) media:media presenter:self preloadNow:NO];
      [scrollView addSubview:mediaButton];
    }
  }

  if(![self.item.idescription isEqualToString:@""])
  {
    descriptionView = [[ARISWebView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,10) delegate:self];
    descriptionView.userInteractionEnabled   = NO;
    descriptionView.scrollView.scrollEnabled = NO;
    descriptionView.scrollView.bounces       = NO;
    descriptionView.opaque                   = NO;
    descriptionView.backgroundColor = [UIColor clearColor];
    [descriptionView loadHTMLString:[NSString stringWithFormat:[UIColor ARISHtmlTemplate], self.item.idescription] baseURL:nil];
    collapseView = [[ARISCollapseView alloc] initWithContentView:descriptionView frame:CGRectMake(0,self.view.bounds.size.height-(10+((numButtons > 0)*44)),self.view.frame.size.width,10) open:YES showHandle:YES draggable:YES tappable:YES delegate:self];
  }

  //nil subviews should be ignored
  [self.view addSubview:webView];
  [self.view addSubview:scrollView];
  [self.view addSubview:collapseView];
[self updateViewButtons]; 
  [self.view addSubview:line];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if(item.qty > 1) self.title = [NSString stringWithFormat:@"%@ x%d",item.name,item.qty];
  else self.title = item.name;

    [self updateViewButtons];

  UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
  backButton.frame = CGRectMake(0, 0, 19, 19);
  [backButton setImage:[UIImage imageNamed:@"arrowBack"] forState:UIControlStateNormal];
  [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void) updateViewButtons
{
    if(destroyBtn) [destroyBtn removeFromSuperview];
    if(dropBtn)    [dropBtn    removeFromSuperview]; 
    if(pickupBtn)  [pickupBtn  removeFromSuperview]; 
    if(line)       [line       removeFromSuperview]; 
    
    if(item.qty == 0)
    {
        destroyBtn = nil;
        dropBtn    = nil; 
        pickupBtn  = nil; 
    }
    
    int numButtons = (destroyBtn != nil) + (dropBtn != nil) + (pickupBtn != nil);
    if(destroyBtn) destroyBtn.frame = CGRectMake(self.view.bounds.size.width-(self.view.bounds.size.width/numButtons),self.view.bounds.size.height-44,self.view.bounds.size.width/numButtons,44);
    if(dropBtn)    dropBtn.frame    = CGRectMake(self.view.bounds.size.width-(self.view.bounds.size.width/numButtons),self.view.bounds.size.height-44,self.view.bounds.size.width/numButtons,44);
    if(pickupBtn)  pickupBtn.frame  = CGRectMake(self.view.bounds.size.width-(self.view.bounds.size.width/numButtons),self.view.bounds.size.height-44,self.view.bounds.size.width/numButtons,44); 
    
    [self.view addSubview:destroyBtn];
    [self.view addSubview:dropBtn];
    [self.view addSubview:pickupBtn];
    if(numButtons > 0)[self.view addSubview:line];
    
    if(collapseView) [collapseView setFrame:CGRectMake(0,self.view.bounds.size.height-(descriptionView.frame.size.height+10),self.view.frame.size.width,descriptionView.frame.size.height+10)]; 
}

- (void) passTapToDescription:(UITapGestureRecognizer *)r
{
  [collapseView handleTapped:r];
}

- (void) passPanToDescription:(UIPanGestureRecognizer *)g
{
  [collapseView handlePanned:g];
}

- (void) dropButtonTouched
{	
  if(self.item.qty > 1)
  {
    ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithPrompt:@"Drop" qty:self.item.qty delegate:self];
    [[self navigationController] pushViewController:itemActionVC animated:YES];
  }
  else 
    [self dropItemQty:1];
}

- (void) dropItemQty:(int)q
{
  [[AppServices sharedAppServices] updateServerDropItemHere:item.itemId qty:q];
  [[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:q];
}

- (void) destroyButtonTouched
{
  if(self.item.qty > 1)
  {
    ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithPrompt:@"Destroy" qty:self.item.qty delegate:self];
    [[self navigationController] pushViewController:itemActionVC animated:YES];
  }
  else 
    [self destroyItemQty:1];
}

- (void) destroyItemQty:(int)q
{
    [[AppServices sharedAppServices] updateServerDestroyItem:self.item.itemId qty:q];
    [[AppModel sharedAppModel].currentGame.inventoryModel removeItemFromInventory:item qtyToRemove:q];
}

- (void) pickupButtonTouched
{
  if(self.item.qty > 1)
  {
      int q = self.item.qty;
      
  Item *invItem = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
  if(!invItem) { invItem = [[AppModel sharedAppModel] itemForItemId:item.itemId]; invItem.qty = 0; }

      int maxPUAmt = invItem.maxQty == -1 ? 99999 : invItem.maxQty-invItem.qty;
      if(q < maxPUAmt) maxPUAmt = q;

        int wc = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
      int cw = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
      while(wc != 0 && (maxPUAmt*item.weight + cw) > wc) maxPUAmt--;

      if(maxPUAmt < q)
        q = maxPUAmt;
          
    ItemActionViewController *itemActionVC = [[ItemActionViewController alloc] initWithPrompt:@"Pick Up" qty:q delegate:self];
    [[self navigationController] pushViewController:itemActionVC animated:YES];
  }
  else 
    [self pickupItemQty:1];
}

- (void) pickupItemQty:(int)q
{
  Item *invItem = [[AppModel sharedAppModel].currentGame.inventoryModel inventoryItemForId:item.itemId];
  if(!invItem) { invItem = [[AppModel sharedAppModel] itemForItemId:item.itemId]; invItem.qty = 0; }

  int maxPUAmt = invItem.maxQty == -1 ? 99999 : invItem.maxQty-invItem.qty;
  if(q < maxPUAmt) maxPUAmt = q;

    int wc = [AppModel sharedAppModel].currentGame.inventoryModel.weightCap;
  int cw = [AppModel sharedAppModel].currentGame.inventoryModel.currentWeight;
  while(wc != 0 && (maxPUAmt*item.weight + cw) > wc) maxPUAmt--;

  if(maxPUAmt < q)
  {
    q = maxPUAmt;
    /*
    [ARISAlertHandler sharedAlertHandler]
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ItemAcionInventoryOverLimitKey", @"")
    message:[NSString stringWithFormat:@"%@ %d %@",NSLocalizedString(@"ItemAcionCarryThatMuchKey", @""),q,NSLocalizedString(@"PickedUpKey", @"")]
    delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
  [alert show];
  */
  }
  else if(q > 0) 
  {
    if([(NSObject *)source isKindOfClass:[Location class]])
    {
      [[AppServices sharedAppServices] updateServerPickupItem:self.item.itemId fromLocation:((Location *)source).locationId qty:q];
      [[AppModel sharedAppModel].currentGame.locationsModel modifyQuantity:-q forLocationId:((Location *)source).locationId];
    }
    else
      [[AppServices sharedAppServices] updateServerAddInventoryItem:self.item.itemId addQty:q];
    item.qty -= q;
  }
}

- (void) amtChosen:(int)amt
{
    [[self navigationController] popToViewController:self animated:YES]; 
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
  //[self dismissMoviePlayerViewControllerAnimated];
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView 
{
  return imageView;
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

- (void) displayTrade
{
  [delegate displayTrade];
}

- (BOOL) webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  if(wv == webView) return (![webView handleARISRequestIfApplicable:request]);
  else if(![[[request URL] absoluteString] isEqualToString:@"about:blank"])
  {
    WebPage *tempWebPage = [[WebPage alloc] init];
    tempWebPage.url = [[request URL] absoluteString];
    [delegate displayGameObject:tempWebPage fromSource:self];
    return NO;
  }
  return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)wv
{
  if(wv == webView)
  {
    [webView injectHTMLWithARISjs];
    webView.hidden = NO;
    [self dismissWaitingIndicator];
  }
  if(wv == descriptionView)
  {
    [descriptionView injectHTMLWithARISjs];
    float newHeight = [[descriptionView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [collapseView setContentFrameHeight:newHeight];

    if(newHeight+10 < self.view.bounds.size.height-44-64)
      [collapseView setFrameHeight:newHeight+10];
    else
      [collapseView setFrameHeight:self.view.bounds.size.height-44-64];
  }
}

- (void) webViewDidStartLoad:(UIWebView *)wv
{
  if(wv == webView) [self showWaitingIndicator];
}

- (void) showWaitingIndicator
{
  if(!activityIndicator)
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:scrollView.bounds];
  [activityIndicator startAnimating];
  [scrollView addSubview:activityIndicator];
}

- (void) dismissWaitingIndicator
{
  [activityIndicator stopAnimating];
  [activityIndicator removeFromSuperview];
}

- (void) ARISMediaViewUpdated:(ARISMediaView *)amv
{

}

- (void) dismissSelf
{
  int locationId = ([(NSObject *)source isKindOfClass:[Location class]]) ? ((Location *)source).locationId : 0;
  [[AppServices sharedAppServices] updateServerItemViewed:item.itemId fromLocation:locationId];	
  [delegate gameObjectViewControllerRequestsDismissal:self];
}

- (void) backButtonTouched
{
  [self dismissSelf];
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

