//
//  AugmentedViewController.h
//  ARIS
//
//  Created by Michael Tolly on 11/23/16.
//
//

#import <AVFoundation/AVFoundation.h>
#import "ARISViewController.h"
#import "GamePlayTabBarViewControllerProtocol.h"
#import "SampleApplicationSession.h"
#import "AugmentedEAGLView.h"
#import <Vuforia/DataSet.h>

@protocol AugmentedViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@class Tab;
@interface AugmentedViewController : ARISViewController <GamePlayTabBarViewControllerProtocol, SampleApplicationControl> {

    Vuforia::DataSet*  dataSetCurrent;
    Vuforia::DataSet*  dataSet;
    
    // menu options
    BOOL continuousAutofocusEnabled;
    
}

@property (nonatomic, strong) AugmentedEAGLView* eaglView;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) SampleApplicationSession * vapp;

@property (nonatomic, readwrite) BOOL showingMenu;

- (id) initWithTab:(Tab *)t delegate:(id<AugmentedViewControllerDelegate>)d;

- (void) setOverlay:(Media *)media;

@end
