//
//  StoreLocallyViewController.h
//  ARIS
//
//  Created by Miodrag Glumac on 2/29/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;

@interface StoreLocallyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *progressTitle;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) Game *game;

- (IBAction)done:(id)sender;
@end
