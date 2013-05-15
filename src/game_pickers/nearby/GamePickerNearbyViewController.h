//
//  GamePickerNEarbyViewController.h
//  ARIS
//
//  Created by Ben Longoria on 2/13/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePickerViewController.h"

@interface GamePickerNearbyViewController : GamePickerViewController
{
    int distanceFilter;
    BOOL locational;
    
    IBOutlet UISegmentedControl *distanceControl;
    IBOutlet UISegmentedControl *locationalControl;
}

-(IBAction)controlChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UISegmentedControl *distanceControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *locationalControl;

@end
