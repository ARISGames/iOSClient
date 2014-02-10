//
//  MapHUD.m
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import "MapHUD.h"
#import "ARISMediaView.h"
#import "ARISTemplate.h"
#import "AppModel.h"
#import "GameObjectProtocol.h"

#import "Player.h"
#import "Npc.h"
#import "Item.h"
#import "Node.h"
#import "WebPage.h"
#import "Panoramic.h"
#import "Note.h"

@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol>
{
    UILabel *title;
    UILabel *walklabel;
    ARISMediaView *iconView;
    CGRect frame;
    Location *location;
    UIButton *dismissButton;
    UIButton *interactButton;
    float distanceToWalk;
    
    id<MapHUDDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end
@implementation MapHUD

- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d withFrame:(CGRect)f
{
    if(self = [super init])
    {
        delegate = d;
        frame = f;
    }
    return self;
}

- (void) setLocation:(Location *)l
{
    location = l; 
    
    CLLocation *annotationLocation = location.latlon;
    CLLocation *userLocation = [[AppModel sharedAppModel] player].location;
    CLLocationDistance distance = [userLocation distanceFromLocation:annotationLocation];
    
    [interactButton removeFromSuperview];
    [walklabel removeFromSuperview]; 
    
    if (distance <= location.errorRange || location.allowsQuickTravel) {
        distanceToWalk = 0;
        [self.view addSubview:interactButton];
    }
    else{
        distanceToWalk = distance - location.errorRange;
        [self.view addSubview:walklabel];
    }
       
    Media *locationMedia = [[AppModel sharedAppModel] mediaForMediaId:location.gameObject.iconMediaId];
    //Media *locationMedia = [self getMediaForLocation:location];
    NSString *locationTitle = location.title;
    
    [self setTitle:locationTitle icon:locationMedia]; 
}

- (void) loadView
{
    [super loadView];
    title = [[UILabel alloc] init];
    walklabel = [[UILabel alloc] init];
    iconView = [[ARISMediaView alloc] initWithDelegate:self];
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    interactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:title];
    [self.view addSubview:iconView];
    [self.view addSubview:dismissButton];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor whiteColor];
    
    int mediaSize = 80;
    int dismissSize = 20;
    
    //hard code most of the positioning for now
    title.frame = CGRectMake(10, self.view.bounds.origin.y + 10, self.view.bounds.size.width-130, 20);
    
    [iconView setFrame:CGRectMake(self.view.bounds.size.width-100,10,mediaSize,mediaSize) withMode:ARISMediaDisplayModeAspectFill];
    
    interactButton.frame = CGRectMake(10, title.frame.origin.y + title.frame.size.height + 10, title.frame.size.width, 50);
    interactButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [interactButton setTitle:@"Interact" forState:UIControlStateNormal];
    [interactButton addTarget:self action:@selector(interactWithLocation) forControlEvents:UIControlEventTouchUpInside];
    
    walklabel.frame = interactButton.frame;
    walklabel.text = [NSString stringWithFormat:@"You need to walk %.1f meters to interact with this object!", distanceToWalk];
    walklabel.lineBreakMode = NSLineBreakByWordWrapping;
    walklabel.numberOfLines = 0;
    walklabel.font = [walklabel.font fontWithSize:10];
    
    UIImage *btnImage = [UIImage imageNamed:@"298-circlex-white.png"];
    [dismissButton setImage:btnImage forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(280, self.view.bounds.size.height - 30, dismissSize, dismissSize);
    [dismissButton addTarget:self action:@selector(dismissHUD) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [UIColor redColor];
}

- (Media *) getMediaForLocation:(Location *)l
{
    if ([l.gameObject isKindOfClass:[Player class]]) {
        Player *otherPlayer = (Player *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:otherPlayer.playerMediaId];
    }
    else if([l.gameObject isKindOfClass:[Npc class]]){
        Npc *npc = (Npc *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:npc.mediaId];
    }
    else if([l.gameObject isKindOfClass:[Item class]]){
        Item *item = (Item *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:item.mediaId];
    }
    else if([l.gameObject isKindOfClass:[Node class]]){
        Node *node = (Node *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:node.mediaId];
    }
    else if([l.gameObject isKindOfClass:[WebPage class]]){
        WebPage *webPage = (WebPage *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:webPage.iconMediaId];
    }
    else if ([l.gameObject isKindOfClass:[Panoramic class]]){
        Panoramic *pan = (Panoramic *)l.gameObject;
        return [[AppModel sharedAppModel] mediaForMediaId:pan.mediaId];
    }
    else if ([l.gameObject isKindOfClass:[Note class]]){
        return [[AppModel sharedAppModel] mediaForMediaId:l.gameObject.iconMediaId];
    }
    return nil;
}

- (void) setTitle:(NSString *)t icon:(Media *)m
{
    title.text = t;
    [iconView setMedia:m];
}

- (void) dismissHUD
{
    [delegate dismissHUD];
}

- (void) interactWithLocation
{
    [self displayGameObject:location.gameObject fromSource:location];
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    return [delegate displayGameObject:g fromSource:s];
}

- (void) displayTab:(NSString *)t
{
    [delegate displayTab:t];
}

- (void) displayScannerWithPrompt:(NSString *)p
{
    [delegate displayScannerWithPrompt:p];
}

@end
