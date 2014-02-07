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
    ARISWebView *descriptionView;
    ARISMediaView *iconView;
    CGRect frame;
    Location *location;
    UIButton *dismissButton;
    UIButton *interactButton;
    
    id<MapHUDDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end
@implementation MapHUD

- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d withFrame:(CGRect)f withLocation:(Location *)l
{
    if(self = [super init])
    {
        delegate = d;
        frame = f;
        location = l;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    title = [[UILabel alloc] init]; 
    descriptionView = [[ARISWebView alloc] initWithDelegate:self];
    iconView = [[ARISMediaView alloc] initWithDelegate:self];
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    interactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:title];
    [self.view addSubview:descriptionView];
    [self.view addSubview:iconView];
    [self.view addSubview:dismissButton];
    
    NSNumber *latitude = [[NSNumber alloc] initWithDouble:44.81890];
    NSNumber *longitude = [[NSNumber alloc] initWithDouble:-93.166777];
    CLLocation *eagan = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    [AppModel sharedAppModel].player.location = eagan;
    
    CLLocation *annotationLocation = location.latlon;
    CLLocation *userLocation = [[AppModel sharedAppModel] player].location;
    CLLocationDistance distance = [userLocation distanceFromLocation:annotationLocation];
    NSLog(@"Annotation Latitude: %f Longitude: %f", annotationLocation.coordinate.latitude, annotationLocation.coordinate.longitude);
    NSLog(@"User Latitude: %f Longitude: %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    NSLog(@"Distance: %f", distance);
    NSLog(@"Error Distance: %d", location.errorRange);
    
    if (distance < location.errorRange) {
        [self.view addSubview:interactButton];
    }
    
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //hard code most of the positioning for now
    title.frame = CGRectMake(10, self.view.bounds.origin.y + 10, self.view.bounds.size.width-70, 20);
    descriptionView.frame = CGRectMake(10, title.frame.origin.y + 30,self.view.bounds.size.width-70, self.view.bounds.size.height*.6);
    [iconView setFrame:CGRectMake(self.view.bounds.size.width-50,10,40,40) withMode:ARISMediaDisplayModeAspectFill];
    interactButton.frame = CGRectMake(10, self.view.bounds.size.height - 50, descriptionView.bounds.size.width, 30);
    [interactButton setTitle:@"Interact" forState:UIControlStateNormal];
    [interactButton addTarget:self action:@selector(interactWithLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *btnImage = [UIImage imageNamed:@"298-circlex-white.png"];
    [dismissButton setImage:btnImage forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height - 30, 20, 20);
    [dismissButton addTarget:self action:@selector(dismissHUD) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [UIColor redColor];
    
    NSLog(@"Getting media from locationId: %d", location.locationId);
    Media *locationMedia = [[AppModel sharedAppModel] mediaForMediaId:location.gameObject.iconMediaId];
    NSString *locationTitle = location.title;
    NSString *locationDescription = [self getLocationDescription:location];
    
    [self setTitle:locationTitle description:locationDescription icon:locationMedia];
}

- (NSString *) getLocationDescription:(Location *)l
{
    if ([l.gameObject isKindOfClass:[Npc class]]) {
        Npc *npc = (Npc *)l.gameObject;
        return npc.greeting;
    }
    else if([l.gameObject isKindOfClass:[Item class]]){
        Item *item = (Item *)l.gameObject;
        return item.idescription;
    }
    else if([l.gameObject isKindOfClass:[Node class]]){
        Node *node = (Node *)l.gameObject;
        return node.text;
    }
    else if([l.gameObject isKindOfClass:[Player class]]){
        Player *otherPlayer = (Player *)l.gameObject;
        return otherPlayer.groupname;
    }
    else if([l.gameObject isKindOfClass:[WebPage class]]){
        WebPage *webPage = (WebPage *)l.gameObject;
        return webPage.name;
    }
    else if([l.gameObject isKindOfClass:[Panoramic class]]){
        Panoramic *panoramic = (Panoramic *)l.gameObject;
        return panoramic.name;
    }
    else if([l.gameObject isKindOfClass:[Note class]]){
        Note *note = (Note *)l.gameObject;
        return note.desc;
    }
    return @"DEFAULT STRING";
}

- (void) setTitle:(NSString *)t description:(NSString *)d icon:(Media *)m
{
    title.text = t;
    [descriptionView loadHTMLString:d baseURL:nil];
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
