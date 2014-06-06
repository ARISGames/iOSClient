//
//  LoginViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "LoginViewController.h"

using namespace std; //math.h undef's "isinf", which is used in mapkit...
#import "ARISAlertHandler.h"
#import "AppModel.h"

#import <ZXingWidgetController.h>
#import "QRCodeReader.h"

#import "SelfRegistrationViewController.h"
#import "ForgotPasswordViewController.h"

@interface LoginViewController() <ZXingDelegate, SelfRegistrationViewControllerDelegate, UITextFieldDelegate>
{
  UITextField *usernameField;
  UITextField *passwordField;
  UIButton *loginButton;
  UIButton *qrButton;
  UIButton *newAccountButton;
  UIButton *changePassButton;
  UIView *line1;
  UIView *line2;

  NSString *groupName;
  int game_id;
  BOOL newPlayer;
  BOOL disableLeaveGame;

  id<LoginViewControllerDelegate> __unsafe_unretained delegate;
}

@end

@implementation LoginViewController

- (id) initWithDelegate:(id<LoginViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
    self.title = NSLocalizedString(@"LoginTitleKey", @"");
      
    _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_IN",self,@selector(resetState),nil); 
    _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_OUT",self,@selector(resetState),nil); 
  }
  return self;
}

- (void) loadView
{
  [super loadView];
  self.view.backgroundColor = [UIColor ARISColorWhite];

  UIView *titleContainer = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
  UIImageView *logoText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
  logoText.frame = CGRectMake(titleContainer.frame.size.width/2-50, titleContainer.frame.size.height/2-15, 100, 30);
  [titleContainer addSubview:logoText];
  self.navigationItem.titleView = titleContainer;
  [self.navigationController.navigationBar layoutIfNeeded];

  int navOffset = 66;

  usernameField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20,self.view.frame.size.width-40,20)];
  usernameField.font = [ARISTemplate ARISInputFont];
  usernameField.delegate = self;
  usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
  usernameField.placeholder = @"ARIS ID";
  usernameField.accessibilityLabel = @"Username Field";
  usernameField.clearButtonMode = UITextFieldViewModeAlways;
  [self.view addSubview:usernameField];

  passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20,navOffset+20+20+20,self.view.frame.size.width-40,20)];
  passwordField.font = [ARISTemplate ARISInputFont]; 
  passwordField.delegate = self;
  passwordField.secureTextEntry = YES;
  passwordField.placeholder = NSLocalizedString(@"PasswordKey", @"");
  passwordField.clearButtonMode = UITextFieldViewModeAlways;
  passwordField.accessibilityLabel = @"Password Field";
  [self.view addSubview:passwordField];

  loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
  loginButton.backgroundColor = [UIColor clearColor];
  [loginButton setBackgroundImage:[UIImage imageNamed:@"arrowForward"] forState:UIControlStateNormal];
  [loginButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
  [loginButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
  loginButton.accessibilityLabel = @"Login";
  loginButton.frame = CGRectMake(self.view.frame.size.width-50, navOffset+100, 20, 20);
  [loginButton addTarget:self action:@selector(loginButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:loginButton];

  qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
  qrButton.backgroundColor = [UIColor clearColor];
  qrButton.alpha = 0.1;
  qrButton.opaque = NO;
  [qrButton setImage:[UIImage imageNamed:@"qr.png"] forState:UIControlStateNormal];
  qrButton.frame = CGRectMake(80, self.view.frame.size.height-(self.view.frame.size.width-160)-80, self.view.frame.size.width-160, self.view.frame.size.width-160);
  [qrButton addTarget:self action:@selector(QRButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:qrButton];

  newAccountButton = [UIButton buttonWithType:UIButtonTypeCustom];
  newAccountButton.backgroundColor = [UIColor clearColor];
  [newAccountButton setTitle:NSLocalizedString(@"CreateAccountKey",@"") forState:UIControlStateNormal];
  [newAccountButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
  [newAccountButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
  newAccountButton.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 20);
  [newAccountButton addTarget:self action:@selector(newAccountButtonTouched) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:newAccountButton];

  changePassButton = [UIButton buttonWithType:UIButtonTypeCustom];
  changePassButton.backgroundColor = [UIColor clearColor];
  [changePassButton setTitle:NSLocalizedString(@"ForgotPasswordKey", @"") forState:UIControlStateNormal];
  [changePassButton setTitleColor:[UIColor ARISColorDarkBlue] forState:UIControlStateNormal];
  [changePassButton.titleLabel setFont:[ARISTemplate ARISButtonFont]];
  changePassButton.frame = CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 20);
  [changePassButton addTarget:self action:@selector(changePassTouch) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:changePassButton];

  line1 = [[UIView alloc] initWithFrame:CGRectMake(20, navOffset+20+20+5, self.view.frame.size.width-40, 1)];
  line1.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
  [self.view addSubview:line1];

  line2 = [[UIView alloc] initWithFrame:CGRectMake(20, navOffset+20+20+20+20+5, self.view.frame.size.width-40, 1)];
  line2.backgroundColor = [UIColor colorWithRed:(194.0/255.0) green:(198.0/255.0)  blue:(191.0/255.0) alpha:1.0];
  [self.view addSubview:line2];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  int navOffset = 66;

  usernameField.frame    = CGRectMake(20,navOffset+20,self.view.frame.size.width-40,20);
  passwordField.frame    = CGRectMake(20,navOffset+20+20+20,self.view.frame.size.width-40,20);
  loginButton.frame      = CGRectMake(self.view.frame.size.width-50, navOffset+100, 20, 20);
  qrButton.frame         = CGRectMake(80, self.view.frame.size.height-(self.view.frame.size.width-160)-80, self.view.frame.size.width-160, self.view.frame.size.width-160);
  newAccountButton.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 20);
  changePassButton.frame = CGRectMake(0, self.view.frame.size.height-30, self.view.frame.size.width, 20);
  line1.frame            = CGRectMake(20, navOffset+20+20+5, self.view.frame.size.width-40, 1);
  line2.frame            = CGRectMake(20, navOffset+20+20+20+20+5, self.view.frame.size.width-40, 1);

  [self resetState];
}

- (void) resetState
{
  usernameField.text = @"";
  passwordField.text = @"";
  game_id = 0;
  newPlayer = NO;
}

- (void) resignKeyboard
{
  [usernameField resignFirstResponder];
  [passwordField resignFirstResponder];
}

- (void) attemptLogin
{
  [_MODEL_ attemptLogInWithUserName:usernameField.text password:passwordField.text];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
  if(textField == usernameField) { [passwordField becomeFirstResponder]; }
  if(textField == passwordField) { [self resignKeyboard]; [self attemptLogin]; }
  return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [self resignKeyboard];
}

- (void) loginButtonTouched
{
  [self resignKeyboard];
  [self attemptLogin];
}

- (void) QRButtonTouched
{
  [self resignKeyboard];
  ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self oneDMode:NO showLicense:NO];
  widController.readers = [[NSMutableSet alloc ] initWithObjects:[[QRCodeReader alloc] init], nil];

  [self presentViewController:widController animated:NO completion:nil];
}

- (void) changePassTouch   
{
  [self resignKeyboard];
  ForgotPasswordViewController *forgotPassViewController = [[ForgotPasswordViewController alloc] init];
  [[self navigationController] pushViewController:forgotPassViewController animated:YES];
}

- (void) newAccountButtonTouched
{
  [self resignKeyboard];
  SelfRegistrationViewController *selfRegistrationViewController = [[SelfRegistrationViewController alloc] initWithDelegate:self];
  [[self navigationController] pushViewController:selfRegistrationViewController animated:YES];
}

- (void) zxingController:(ZXingWidgetController*)controller didScanResult:(NSString *)result
{
  [self dismissViewControllerAnimated:NO completion:nil];

  //Create: 1,groupName,game_id,disableLeaveGame
  //Login:  0,userName,password,game_id,disableLeaveGame
  NSArray *terms  = [result componentsSeparatedByString:@","];
  if(terms.count > 1)
  {
    game_id = 0;
    disableLeaveGame = NO;
    if(terms.count > 0 && [[terms objectAtIndex:0] boolValue]) //create = 1
    {
      if(terms.count > 1) groupName        = [terms objectAtIndex:1];
      if(terms.count > 2) game_id          = [[terms objectAtIndex:2] intValue];
      if(terms.count > 3) disableLeaveGame = [[terms objectAtIndex:3] boolValue];
       
      _MODEL_.disableLeaveGame = disableLeaveGame;
      //_MODEL_.fallbackGameId = game_id;
      [_MODEL_ createAccountWithUserName:usernameField.text displayName:@"" groupName:groupName email:@"" password:passwordField.text]; 
    }
    else if(terms.count > 0) //create = 0
    {
      if(terms.count > 1) usernameField.text = [terms objectAtIndex:1];
      if(terms.count > 2) passwordField.text = [terms objectAtIndex:2];
      if(terms.count > 3) game_id             = [[terms objectAtIndex:3] intValue];
      if(terms.count > 4) disableLeaveGame   = [[terms objectAtIndex:4] boolValue];
        
      _MODEL_.disableLeaveGame = disableLeaveGame;
      //_MODEL_.fallbackGameId = game_id; 
      [_MODEL_ attemptLogInWithUserName:usernameField.text password:passwordField.text]; 
    }
  }
}

- (void) zxingControllerDidCancel:(ZXingWidgetController*)controller
{
  [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSUInteger) supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskPortrait;
}

@end
