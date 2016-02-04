//
//  RootViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARISContainerViewController.h"
#import "GamePlayViewController.h"

@interface RootViewController : ARISContainerViewController
{
    GamePlayViewController *viewingObject;
}
+ (RootViewController *) sharedRootViewController;
@property (nonatomic, strong) GamePlayViewController *gamePlayViewController;
@end
