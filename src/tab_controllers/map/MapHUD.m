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

@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol, ARISCollapseViewDelegate>
{
    UILabel *title;
    UILabel *walklabel;
    ARISMediaView *iconView;
    CGRect frame;
    Location *location;
    UIButton *interactButton;
    float distanceToWalk;
    MKAnnotationView *annotation;
    ARISCollapseView *collapseView;
    UIView *hudView;
    UIImageView *warningImage;
    
    CLLocation *userLocation;
    
    id<MapHUDDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}

@end
@implementation MapHUD
@synthesize annotation;
@synthesize collapseView;

- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d withFrame:(CGRect)f
{
    if(self = [super init])
    {
        delegate = d;
        frame = f;
    }
    return self;
}

- (void) setLocation:(Location *)l withAnnotation:(MKAnnotationView *)a
{
    location = l;
    annotation = a;
    
    CLLocation *annotationLocation = location.latlon;
    userLocation = [[AppModel sharedAppModel] player].location;
    CLLocationDistance distance = [userLocation distanceFromLocation:annotationLocation];
    
    [interactButton removeFromSuperview];
    [walklabel removeFromSuperview];
    [warningImage removeFromSuperview];
    
    if ((distance <= location.errorRange && userLocation != nil) || location.allowsQuickTravel) {
        distanceToWalk = 0;
        interactButton.enabled = YES;
    }
    else{
        interactButton.enabled = NO;
        distanceToWalk = distance - location.errorRange;
        [hudView addSubview:walklabel];
        [hudView addSubview:warningImage];
    }
    
    //TODO change label here and change to NSLocalized string
    if ([location.gameObject isKindOfClass:[Item class]]) {
        [interactButton setTitle:@"Pick up" forState:UIControlStateNormal];
    }
    else{
        [interactButton setTitle:@"View" forState:UIControlStateNormal];
    }
    
    
    //add the interact button to the collapse view instead of the hudView to overlap the ... on the collapse view
    [collapseView addSubview:interactButton];
    
    Media *locationMedia = [[AppModel sharedAppModel] mediaForMediaId:location.gameObject.iconMediaId];
    NSString *locationTitle = location.title;
    title.text = locationTitle;
    [iconView setMedia:locationMedia];
    
    [collapseView open];
}

- (void) loadView
{
    [super loadView];
    
    self.view.frame = CGRectMake(frame.origin.x, frame.origin.y - 20, frame.size.width, frame.size.height + 20);
    
    hudView = [[UIView alloc] init];
    title = [[UILabel alloc] init];
    iconView = [[ARISMediaView alloc] initWithDelegate:self];
    
    walklabel = [[UILabel alloc] init];
    interactButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    warningImage = [[UIImageView alloc] init];
    [warningImage setImage:[UIImage imageNamed:@"walkerWarning.png"]];
    
    [hudView addSubview:title];
    [hudView addSubview:iconView];
    
    CGRect collapseViewFrame = CGRectMake(0, 20, frame.size.width, frame.size.height);
    collapseView = [[ARISCollapseView alloc] initWithContentView:hudView frame:collapseViewFrame open:YES showHandle:NO draggable:YES tappable:YES delegate:self];
    
    [self.view addSubview:collapseView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    hudView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-10);
    
    int mediaSize = 80;
    title.frame = CGRectMake(20, 69, frame.size.width-130, 33);
    title.font = [title.font fontWithSize:18];
    
    [iconView setFrame:CGRectMake(frame.size.width - 100, frame.size.height - 110, mediaSize, mediaSize) withMode:ARISMediaDisplayModeAspectFill];
    
    interactButton.frame = CGRectMake((frame.size.width / 2) - (60/2), 5, 60, 30);
    interactButton.layer.cornerRadius = 5;
    interactButton.layer.borderWidth = 1;
    interactButton.layer.borderColor = [UIColor blueColor].CGColor;
    [interactButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [interactButton addTarget:self action:@selector(interactWithLocation) forControlEvents:UIControlEventTouchUpInside];
    interactButton.backgroundColor = [UIColor whiteColor];
    
    walklabel.frame = CGRectMake(65, 36, 140, 35);
    //TODO change this string to NSLocalized String
    float roundedDistance = lroundf(distanceToWalk);
    if (userLocation != nil) {
        walklabel.text = [NSString stringWithFormat:@"Out of range\nWalk %.0fm", roundedDistance];
    }
    else{
        walklabel.text = @"Out of range";
    }
    
    walklabel.textColor = [UIColor redColor];
    walklabel.lineBreakMode = NSLineBreakByWordWrapping;
    walklabel.numberOfLines = 0;
    walklabel.font = [walklabel.font fontWithSize:10];
    
    warningImage.frame = CGRectMake(20, 31, 40, 40);
}

- (void) dismissHUD
{
    [delegate dismissHUDWithAnnotation:annotation];
}

- (void) interactWithLocation
{
    [self displayGameObject:location.gameObject fromSource:location];
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id<GameObjectProtocol>)g fromSource:(id)s
{
    [collapseView close];
    [self dismissHUD];
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

#pragma mark ARISCollapseView Delegate Methods

- (void) collapseView:(ARISCollapseView *)cv didStartOpen:(BOOL)o
{
    if(!o){
        [interactButton setAlpha:0.0];
        [self dismissHUD];
        self.view.userInteractionEnabled = NO;
    }
    else{
        [interactButton setAlpha:1.0];
        self.view.userInteractionEnabled = YES;
    }
}

@end
