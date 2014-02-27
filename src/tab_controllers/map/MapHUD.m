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

#import "CircleButton.h"

@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol, ARISCollapseViewDelegate>
{
    UILabel *title;
    UILabel *walklabel;
    ARISMediaView *iconView;
    CGRect frame;
    Location *location;
    CircleButton *circleButton;
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
    
    [circleButton removeFromSuperview];
    [walklabel removeFromSuperview];
    [warningImage removeFromSuperview];
    
    if ((distance <= location.errorRange && userLocation != nil) || location.allowsQuickTravel) {
        distanceToWalk = 0;
        circleButton.enabled = YES;
    }
    else{
        circleButton.enabled = NO;
        distanceToWalk = distance - location.errorRange;
        [hudView addSubview:walklabel];
        [hudView addSubview:warningImage];
    }
    
    //TODO change label here and change to NSLocalized string
    if ([location.gameObject isKindOfClass:[Item class]]) {
        [circleButton setTitle:@"Pick up" forState:UIControlStateNormal];
    }
    else{
        [circleButton setTitle:@"View" forState:UIControlStateNormal];
    }
    
    
    //add the circle button to the collapse view instead of the hudView to overlap the ... on the collapse view
    [collapseView addSubview:circleButton];
    
    Media *locationMedia = [[AppModel sharedAppModel] mediaForMediaId:location.gameObject.iconMediaId];
    NSString *locationTitle = location.title;
    title.text = locationTitle;
    [iconView setMedia:locationMedia];
    
    [collapseView open];
}

- (void) loadView
{
    [super loadView];
    
    self.view.frame = frame;
    
    hudView = [[UIView alloc] init];
    title = [[UILabel alloc] init];
    iconView = [[ARISMediaView alloc] initWithDelegate:self];
    
    walklabel = [[UILabel alloc] init];
    circleButton = [[CircleButton alloc] init];
    warningImage = [[UIImageView alloc] init];
    [warningImage setImage:[UIImage imageNamed:@"walkerWarning.png"]];
    
    [hudView addSubview:title];
    [hudView addSubview:iconView];
    
    
    CGRect collapseViewFrame = CGRectMake(0, 50, frame.size.width, frame.size.height);
    collapseView = [[ARISCollapseView alloc] initWithContentView:hudView frame:collapseViewFrame open:YES showHandle:NO draggable:YES tappable:YES delegate:self];
    
    collapseView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:collapseView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    hudView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height-10);
    
    int mediaSize = 60;
    [iconView setFrame:CGRectMake(frame.size.width - 100, frame.size.height - 150, mediaSize, mediaSize) withMode:ARISMediaDisplayModeAspectFill];
    
    int titleWidth = frame.size.width-160;
    title.frame = CGRectMake((iconView.frame.origin.x + (iconView.frame.size.width / 2)) - (titleWidth / 2), 114, titleWidth, 33);
    title.font = [title.font fontWithSize:18];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [title setFont:boldFont];
    title.textAlignment = NSTextAlignmentCenter;
    
    circleButton.frame = CGRectMake((frame.size.width / 2) - (60/2), 5, 80, 80);
    [circleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [circleButton addTarget:self action:@selector(interactWithLocation) forControlEvents:UIControlEventTouchUpInside];
    
    walklabel.frame = CGRectMake(65, 66, 140, 35);
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
    walklabel.font = [UIFont boldSystemFontOfSize:20];
    
    warningImage.frame = CGRectMake(20, 61, 40, 40);
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
        [circleButton setAlpha:0.0];
        [self dismissHUD];
        self.view.userInteractionEnabled = NO;
    }
    else{
        [circleButton setAlpha:1.0];
        self.view.userInteractionEnabled = YES;
    }
}

@end
