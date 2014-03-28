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
    ARISCollapseView *collapseView; 
    UIView *hudView;
    UILabel *prompt;
    UILabel *warning; 
    
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
    
    prompt = [[UILabel alloc] init];
    prompt.font = [ARISTemplate ARISButtonFont]; 
    prompt.lineBreakMode = NSLineBreakByWordWrapping;
    prompt.numberOfLines = 0; 
    prompt.textColor = [UIColor blackColor];     
    
    warning = [[UILabel alloc] init]; 
    warning.font = [ARISTemplate ARISCellSubtextFont]; 
    warning.lineBreakMode = NSLineBreakByWordWrapping;
    warning.numberOfLines = 0;  
    warning.textColor = [UIColor redColor];      
    
    
    CGRect collapseViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    collapseView = [[ARISCollapseView alloc] initWithContentView:hudView frame:collapseViewFrame open:NO showHandle:NO draggable:YES tappable:NO delegate:self];
    collapseView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];    
    
    [self.view addSubview:collapseView];
    
    [hudView addSubview:prompt];   
    [hudView addSubview:warning];    
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [collapseView setFrame:self.view.bounds];
    hudView.frame = CGRectMake(0, 23, self.view.frame.size.width, self.view.frame.size.height-23);
       
    
    prompt.frame = CGRectMake(120, 2, self.view.frame.size.width-85, 35);
    warning.frame = CGRectMake(85, 20, self.view.frame.size.width-85, 35); 
}

- (void) setLocation:(Location *)l
{
    location = l;
    
    CLLocationDistance distance = [[[AppModel sharedAppModel] player].location distanceFromLocation:location.latlon];
    
    prompt.text = location.name;
    float distanceToWalk; 
    if((distance <= location.errorRange && [[AppModel sharedAppModel] player].location != nil) || location.allowsQuickTravel)
    {
        distanceToWalk = 0;
        warning.text = @"";
    }
    else
    {
        distanceToWalk = distance - location.errorRange;
        //TODO change this string to NSLocalized String
        float roundedDistance = lroundf(distanceToWalk);
        if([[AppModel sharedAppModel] player].location != nil)
            warning.text = [NSString stringWithFormat:@"Out of range- walk %.0fm", roundedDistance];
        else
            warning.text = @"Out of range";
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
    self.view.userInteractionEnabled = o;
}

@end
