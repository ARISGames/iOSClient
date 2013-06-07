//
//  StoreLocallyViewController.m
//  ARIS
//
//  Created by Miodrag Glumac on 2/29/12.
//  Copyright (c) 2012 Amherst College. All rights reserved.
//

#import "StoreLocallyViewController.h"
#import "AppModel.h"
#import "LocalData.h"

@interface StoreLocallyViewController ()

@end

@implementation StoreLocallyViewController
@synthesize progressTitle;
@synthesize progressLabel;
@synthesize progressView;
@synthesize doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    doneButton.enabled = NO;
    doneButton.alpha = 0.5;
    //
}

- (void)viewDidAppear:(BOOL)animated {
    self.progressTitle.text = [NSString stringWithFormat:@"Downloading Game: %@", _game.name];
    // start downloading
    LocalData *local = [LocalData sharedLocal];
    [local updateServer:^(BOOL success) {
        if (success) {
            [local storeGame:_game completion:^(NSString *name, float progress, BOOL done) {
                progressLabel.text = name;
                progressView.progress = progress;
                if (done) {
                    doneButton.enabled = YES;
                    doneButton.alpha = 1.0;
                }
            }];
        }
        else {
            doneButton.enabled = YES;
            doneButton.alpha = 1.0;
        }
    }];
}

- (void)viewDidUnload
{
    [self setTitle:nil];
    [self setProgressLabel:nil];
    [self setProgressView:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
 */


- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
