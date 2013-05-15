//
//  ARISAlertHAndler.m
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import "ARISAlertHandler.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "RootViewController.h"

@interface ARISAlertHandler () <MFMailComposeViewControllerDelegate>
{
    UIAlertView *waitingIndicator;
    UIActivityIndicatorView *loadingSpiral;
    
    UIAlertView *networkAlert;
    UIAlertView *serverAlert;
    
    MFMailComposeViewController *mailComposeViewController;
    
    NSString *errorMessage;
    NSString *errorDetail;
}

@property (nonatomic, strong) UIAlertView *waitingIndicator;
@property (nonatomic, strong) UIActivityIndicatorView *loadingSpiral;
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) UIAlertView *networkAlert;
@property (nonatomic, strong) UIAlertView *serverAlert;

@end

@implementation ARISAlertHandler

@synthesize waitingIndicator;
@synthesize loadingSpiral;
@synthesize mailComposeViewController;
@synthesize networkAlert;
@synthesize serverAlert;

+ (id) sharedAlertHandler
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
        self.waitingIndicator = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        self.loadingSpiral = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingSpiral.center = CGPointMake(142,73);//CGPointMake(super.bounds.size.width / 2, super.bounds.size.height - 40); didn't work
        [self.waitingIndicator addSubview:self.loadingSpiral];
    
        self.networkAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PoorConnectionTitleKey", @"")
                                                       message:NSLocalizedString(@"PoorConnectionMessageKey", @"")
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"OkKey", @"")
                                             otherButtonTitles:nil];
    
        self.serverAlert = [[UIAlertView alloc] initWithTitle:@""
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"IgnoreKey", @"")
                                            otherButtonTitles:NSLocalizedString(@"ReportKey", @""),nil];
    }
    return self;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OkKey", @"") otherButtonTitles:nil];
    [alert show];
}

- (void)showServerAlertEmailWithTitle:(NSString *)title message:(NSString *)message details:(NSString*)detail
{
	errorMessage = message;
    errorDetail  = detail;
    
    self.serverAlert.title = title;
    self.serverAlert.message = [NSString stringWithFormat:@"%@-%@",NSLocalizedString(@"ARISAppDelegateWIFIErrorMessageKey", @""),message];
    
    [self.serverAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)//Since only the server error alert with email has button 1, we know who we are dealing with
    {
		NSLog(@"RootViewController: AlertView button wants to send an email" );
		self.mailComposeViewController = [[MFMailComposeViewController alloc] init];
		self.mailComposeViewController.mailComposeDelegate = self;
		[self.mailComposeViewController setToRecipients:[NSMutableArray arrayWithObjects:@"arisgames-dev@googlegroups.com",nil]];
		[self.mailComposeViewController setSubject:@"ARIS Error Report"];
		[self.mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@\n\nDetails:\n%@", errorMessage, errorDetail] isHTML:NO];
        [[RootViewController sharedRootViewController] presentViewController:self.mailComposeViewController animated:NO completion:nil];
	}
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
	[self.mailComposeViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)showNetworkAlert
{
    [networkAlert show];
}

- (void)removeNetworkAlert
{
	[self.networkAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)showWaitingIndicator:(NSString *)message
{
    self.waitingIndicator.title = message;
    [self.loadingSpiral startAnimating];
    [self.waitingIndicator show];
}

- (void)removeWaitingIndicator
{
    [self.loadingSpiral stopAnimating];
	[self.waitingIndicator dismissWithClickedButtonIndex:0 animated:YES];
}

@end
