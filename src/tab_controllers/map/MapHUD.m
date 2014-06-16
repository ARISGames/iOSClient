//
//  MapHUD.m
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import "MapHUD.h"
#import "ARISMediaView.h"
#import "AppModel.h"

#import "User.h"
#import "Dialog.h"
#import "Item.h"
#import "Plaque.h"
#import "WebPage.h"
#import "Note.h"
#import "UIImage+Scale.h"


@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol, ARISCollapseViewDelegate>
{
    ARISCollapseView *collapseView; 
    UIView *hudView;
    UILabel *prompt;
    UILabel *warning; 
    
    //Location *location;
    ARISMediaView *warningImage;
    ARISMediaView *whiteGradient;
    ARISMediaView *arrowsImage;
    
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
    
    self.view.backgroundColor = [UIColor clearColor];
    hudView = [[UIView alloc] init];
    
    prompt = [[UILabel alloc] init];
    prompt.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    prompt.lineBreakMode = NSLineBreakByWordWrapping;
    prompt.numberOfLines = 0; 
    prompt.textColor = [UIColor blackColor];
    
    warning = [[UILabel alloc] init]; 
    warning.font = [ARISTemplate ARISCellSubtextFont]; 
    warning.lineBreakMode = NSLineBreakByWordWrapping;
    warning.numberOfLines = 0;  
    warning.textColor = [UIColor ARISColorRed];
    
    warningImage = [[ARISMediaView alloc] init];
    [warningImage setImage:[UIImage imageNamed:@"Walk-WarningRED.png"]];
    
    whiteGradient = [[ARISMediaView alloc] init];
    [whiteGradient setImage:[[UIImage imageNamed:@"White-Gradient-100-0.png"]scaleToSize:CGSizeMake(320, 57)]];
    
    arrowsImage = [[ARISMediaView alloc] init];
    [arrowsImage setImage:[UIImage imageNamed:@"Diamond.png"]];
    
    
    CGRect collapseViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    collapseView = [[ARISCollapseView alloc] initWithContentView:hudView frame:collapseViewFrame open:NO showHandle:NO draggable:YES tappable:NO delegate:self];
    collapseView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
    
    [self.view addSubview:collapseView];
    
    [hudView addSubview:whiteGradient];
    [hudView addSubview:prompt];
    [hudView addSubview:warning];
    [hudView addSubview:arrowsImage];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [collapseView setFrame:self.view.bounds];
    hudView.frame = CGRectMake(0, 23, self.view.frame.size.width, self.view.frame.size.height-23);
       
    whiteGradient.frame = CGRectMake(hudView.bounds.origin.x, hudView.bounds.origin.y, hudView.bounds.size.width, 57);
    prompt.frame = CGRectMake(75, 12, self.view.frame.size.width-160, 25);
    warning.frame = CGRectMake(75, 35, self.view.frame.size.width-160, 17);
    warningImage.frame = CGRectMake(self.view.frame.size.width-70, 2, 50, 52);
    arrowsImage.frame = CGRectMake(20, 0, 50, 50);
}

/*
- (void) setLocation:(Location *)l
{
    [warningImage removeFromSuperview];
    location = l;
    
    CLLocationDistance distance = [_MODEL_PLAYER_.location distanceFromLocation:location.latlon];
    
    prompt.text = location.name;
    float distanceToWalk; 
    if((distance <= location.errorRange && _MODEL_PLAYER_.location != nil) || location.allowsQuickTravel)
    {
        distanceToWalk = 0;
        warning.text = @"";
    }
    else
    {
        [hudView addSubview:warningImage];
        distanceToWalk = distance - location.errorRange;
        float roundedDistance = lroundf(distanceToWalk);
        if(_MODEL_PLAYER_.location != nil)
            warning.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"OutOfRangeWalkKey", @""), [NSString stringWithFormat:@"%.0fm", roundedDistance]];
        else
            warning.text = NSLocalizedString(@"OutOfRangeKey", @"");
    }
}
 */

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
}

#pragma mark StateControlProtocol delegate methods

- (BOOL) displayGameObject:(id)g fromSource:(id)s
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
