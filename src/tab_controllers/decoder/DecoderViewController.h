//
//  DecoderViewController.h
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin Madison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import "ARISGamePlayTabBarViewController.h"
#import "AppModel.h"

@protocol StateControllerProtocol;

@protocol DecoderViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface DecoderViewController : ARISGamePlayTabBarViewController 
- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d inMode:(int)m;
- (void) launchScannerWithPrompt:(NSString *)p;
@end
