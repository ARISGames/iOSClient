//
//  BumpTestViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 2/27/13.
//
//

#import "BumpTestViewController.h"
#import "BumpClient.h"

@interface BumpTestViewController ()

@end

@implementation BumpTestViewController

@synthesize debugView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)del
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        delegate = del;
        messageNumber = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureBump];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[BumpClient sharedClient] disconnect];
}

- (void) configureBump
{
    [self debugString:@"Configuring Bump..."];
    [BumpClient configureWithAPIKey:@"4ff1c7a0c2a84bb9938dafc3a1ac770c" andUserID:[[UIDevice currentDevice] name]];
    [[BumpClient sharedClient] connect];
    
    [[BumpClient sharedClient] setMatchBlock:^(BumpChannelID channel)
    {
        [self debugString:[NSString stringWithFormat:@"Matched with user: %@", [[BumpClient sharedClient] userIDForChannel:channel]]];
        [[BumpClient sharedClient] confirmMatch:YES onChannel:channel];
    }];
    
    [[BumpClient sharedClient] setChannelConfirmedBlock:^(BumpChannelID channel)
    {
        [self debugString:[NSString stringWithFormat:@"Confirmed channel: %@", [[BumpClient sharedClient] userIDForChannel:channel]]];
        [[BumpClient sharedClient] sendData:[@"TEST_DATA" dataUsingEncoding:NSUTF8StringEncoding] toChannel:channel];
    }];
    
    [[BumpClient sharedClient] setDataReceivedBlock:^(BumpChannelID channel, NSData *data)
    {
         NSString *receipt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         [self debugString:[NSString stringWithFormat:@"Data received: %@", receipt]];
    }];
    
    [[BumpClient sharedClient] setConnectionStateChangedBlock:^(BOOL connected)
    {
        if (connected) [self debugString:@"Bump Connected..."];
        else           [self debugString:@"Bump Disconnected..."];
    }];
    
    [[BumpClient sharedClient] setBumpEventBlock:^(bump_event event)
    {
        if(event == BUMP_EVENT_BUMP)     [self debugString:@"Bump Detected..."];
        if(event == BUMP_EVENT_NO_MATCH) [self debugString:@"No match..."];
    }];
}

-  (void)debugString:(NSString *)dString
{
    NSLog(@"BUMP_TEST: %@",dString);
    UILabel *debugMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, 10+(30*messageNumber), 280, 20)];
    debugMessage.text = dString;
    messageNumber++;
    self.debugView.contentSize = CGSizeMake(280,10+(30*messageNumber));
    [self.debugView addSubview:debugMessage];
    if(self.debugView.contentSize.height > self.debugView.bounds.size.height)
    {
        CGPoint bottomOffset = CGPointMake(0, self.debugView.contentSize.height - self.debugView.bounds.size.height);
        [self.debugView setContentOffset:bottomOffset animated:YES];
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSInteger) supportedInterfaceOrientations
{
    NSInteger mask = 0;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft])      mask |= UIInterfaceOrientationMaskLandscapeLeft;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight])     mask |= UIInterfaceOrientationMaskLandscapeRight;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait])           mask |= UIInterfaceOrientationMaskPortrait;
    if([self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown]) mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    return mask;
}

-(IBAction)returnPressed:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
