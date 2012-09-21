//
//  GlobalPlayerViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 9/21/12.
//
//

#import "GlobalPlayerViewController.h"

@implementation GlobalPlayerViewController

@synthesize playerPic;
@synthesize playerNameField;
@synthesize playerPicOpt1;
@synthesize playerPicOpt2;
@synthesize playerPicOpt3;
@synthesize playerPicCam;

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
    playerPicOpt1.delegate = self;
    playerPicOpt2.delegate = self;
    playerPicOpt3.delegate = self;
    playerPicCam.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)playerNameFieldTouched:(id)sender
{
    
}

-(id)playerPicOptTouched:(id)sender
{
    return nil;
}

-(IBAction)goButtonTouched:(id)sender
{
    
}

-(void)asyncMediaImageTouched:(id)sender
{
    
}
-(void) imageFinishedLoading{
    
}

@end
