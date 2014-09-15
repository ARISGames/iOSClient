//
//  ScannerViewController.h
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

@protocol ScannerViewControllerDelegate <GamePlayTabBarViewControllerDelegate>
@end

@interface ScannerViewController : ARISGamePlayTabBarViewController 
- (id) initWithDelegate:(id<ScannerViewControllerDelegate, StateControllerProtocol>)d;
- (void) setPrompt:(NSString *)p;
@end
