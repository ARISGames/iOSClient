//
//  GamePickerPopularViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePickerViewController.h"

@interface GamePickerPopularViewController : GamePickerViewController
{
    int time;
    
    IBOutlet UISegmentedControl *timeControl;
}

- (IBAction)controlChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UISegmentedControl *timeControl;

@end
