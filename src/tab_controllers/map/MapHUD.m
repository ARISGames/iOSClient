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
    ARISCollapseView *collapseView; 
    CircleButton *circleButton; 
    UIView *hudView; 
    UILabel *walklabel;
    UIImageView *warningImage; 
    
    Location *location; 
    
    id<MapHUDDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation MapHUD

- (id) initWithDelegate:(id<MapHUDDelegate, StateControllerProtocol>)d
{
    if(self = [super init])
    {
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    hudView = [[UIView alloc] init];
    hudView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];  
    
    walklabel = [[UILabel alloc] init];
    circleButton = [[CircleButton alloc] init];
    warningImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"walkerWarning.png"]];
    
    CGRect collapseViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    collapseView = [[ARISCollapseView alloc] initWithContentView:hudView frame:collapseViewFrame open:NO showHandle:NO draggable:YES tappable:NO delegate:self];
    collapseView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];    
    [collapseView addSubview:circleButton];  
    
    [self.view addSubview:collapseView];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [collapseView setFrame:self.view.bounds];
    hudView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40);
       
    circleButton.frame = CGRectMake(0, 20, 80, 80);
    [circleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [circleButton addTarget:self action:@selector(interactWithLocation) forControlEvents:UIControlEventTouchUpInside]; 
    
    walklabel.frame = CGRectMake(85, 5, self.view.frame.size.width-85, 35);
    walklabel.font = [ARISTemplate ARISButtonFont]; 
    walklabel.textColor = [UIColor redColor];
    walklabel.lineBreakMode = NSLineBreakByWordWrapping;
    walklabel.numberOfLines = 0;
    
    warningImage.frame = CGRectMake(self.view.frame.size.width-40, 5, 30, 30);
}

- (void) setLocation:(Location *)l
{
    location = l;
    
    CLLocation *annotationLocation = location.latlon;
    CLLocationDistance distance = [[[AppModel sharedAppModel] player].location distanceFromLocation:annotationLocation];
    
    [walklabel removeFromSuperview];
    [warningImage removeFromSuperview];
    
    float distanceToWalk; 
    if ((distance <= location.errorRange && [[AppModel sharedAppModel] player].location != nil) || location.allowsQuickTravel) {
        distanceToWalk = 0;
        circleButton.enabled = YES;
    }
    else{
        circleButton.enabled = NO;
        distanceToWalk = distance - location.errorRange;
        //TODO change this string to NSLocalized String
        float roundedDistance = lroundf(distanceToWalk);
        if ([[AppModel sharedAppModel] player].location != nil) {
            walklabel.text = [NSString stringWithFormat:@"Out of range\nWalk %.0fm", roundedDistance];
        }
        else{
            walklabel.text = @"Out of range";
        }
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
}

- (void) open
{
    [collapseView open];
}

- (void) dismiss
{
    [collapseView close]; 
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

#pragma mark ARISCollapseView Delegate Methods

- (void) collapseView:(ARISCollapseView *)cv didStartOpen:(BOOL)o
{
    if(!o){
        self.view.userInteractionEnabled = NO;
    }
    else{
        self.view.userInteractionEnabled = YES;
    }
}

@end
