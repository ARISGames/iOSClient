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


@interface MapHUD() <ARISMediaViewDelegate, ARISWebViewDelegate, StateControllerProtocol>
{
    UILabel *title; 
    ARISWebView *descriptionView;
    ARISMediaView *iconView;
    CGRect frame;
    Location *location;
    UIButton *dismissButton;
    
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
    [self.view addSubview:title];
    [self.view addSubview:descriptionView];
    [self.view addSubview:iconView];
    [self.view addSubview:dismissButton];
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
    
    //set the icons media
    Media *locationMedia = [[AppModel sharedAppModel] mediaForMediaId:location.locationId];
    NSString *locationTitle = location.title;
    NSString *locationDescription = location.description;
    
    UIImage *btnImage = [UIImage imageNamed:@"298-circlex-white.png"];
    [dismissButton setImage:btnImage forState:UIControlStateNormal];
    dismissButton.frame = CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height - 30, 20, 20);
    [dismissButton addTarget:self action:@selector(dismissHUD) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.backgroundColor = [UIColor redColor];
    
    [self setTitle:locationTitle description:locationDescription icon:locationMedia];
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
