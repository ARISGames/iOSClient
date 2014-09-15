//
//  CameraViewController.m
//  ARIS
//
//  Created by David Gagnon on 3/4/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "DecoderViewController.h"
#import "StateControllerProtocol.h"
#import "ARISAppDelegate.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"

@interface DecoderViewController() <UITextFieldDelegate>
{
	UITextField *codeTextField;
    
    id<DecoderViewControllerDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation DecoderViewController

- (id) initWithDelegate:(id<DecoderViewControllerDelegate, StateControllerProtocol>)d
{
    if(self = [super initWithDelegate:d])
    {
        self.tabID = @"DECODER";
        self.tabIconName = @"qr_icon.png";
        self.title = NSLocalizedString(@"QRDecoderTitleKey", @"");
        
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor ARISColorBlack];  

    self.view.backgroundColor = [UIColor ARISColorWhite]; 
    codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20,20+64,self.view.frame.size.width-40,30)];
    codeTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    codeTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    codeTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    codeTextField.textAlignment = NSTextAlignmentCenter;
    codeTextField.placeholder = NSLocalizedString(@"EnterCodeKey",@"");
    codeTextField.delegate = self;
    [self.view addSubview:codeTextField];
}

- (void) viewWillAppearFirstTime:(BOOL)animated
{
    [super viewWillAppearFirstTime:animated];
    
    //overwrite the nav button written by superview so we can listen for touchDOWN events as well (to dismiss camera)
    UIButton *threeLineNavButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [threeLineNavButton setImage:[UIImage imageNamed:@"threelines"] forState:UIControlStateNormal];
    [threeLineNavButton addTarget:self action:@selector(showNav) forControlEvents:UIControlEventTouchUpInside];
    threeLineNavButton.accessibilityLabel = @"In-Game Menu";
    [threeLineNavButton addTarget:self action:@selector(clearScreenActions) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:threeLineNavButton];  
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [codeTextField becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self clearScreenActions];
}

- (void) showNav
{
    [self clearScreenActions];
    [super showNav];
}

- (void) clearScreenActions
{
    [codeTextField resignFirstResponder];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{	
	[textField resignFirstResponder]; 
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the keyboard go away before loading the object
    Trigger *t;
    if([codeTextField.text isEqualToString:@"log-out"]) [_MODEL_ logOut];
    else 
    {
        t = [_MODEL_TRIGGERS_ triggerForQRCode:codeTextField.text];
    
    	if(!t) [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"QRScannerErrorTitleKey", @"") message:NSLocalizedString(@"QRScannerErrorMessageKey", @"")];
        else [delegate displayTrigger:t];
    }
        
    codeTextField.text = @"";
	return YES;
}

- (void) dealloc
{
    _ARIS_NOTIF_IGNORE_ALL_(self); 
}

@end
