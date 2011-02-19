//
//  TutorialViewController.h
//  ARIS
//
//  Created by David J Gagnon on 2/18/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialPopupView.h"

@interface TutorialViewController : UIViewController {

	
}

- (void) showTutorialPopupPointingToTabForViewController:(UIViewController*)vc 
													type:(tutorialPopupType)type
												   title:(NSString *)title 
												 message:(NSString *)message;

- (void) dismissTutorialPopupWithType:(tutorialPopupType)type;

- (void) updatePointerForPopup:(TutorialPopupView*)tv pointingToViewController:(UIViewController*)vc;


@end
