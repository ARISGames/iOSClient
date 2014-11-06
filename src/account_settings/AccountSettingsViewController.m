//
//  AccountSettingsViewController.m
//  ARIS
//
//  Created by Ben Longoria on 2/11/09.
//  Copyright 2009 University of Wisconsin. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ForgotPasswordViewController.h"
#import "ARISSelectorHandle.h"
#import "AppModel.h"

@interface AccountSettingsViewController() <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *tableView;
    UIView *logoutButton;
    UILabel *logoutLabel;
    UIImageView *logoutArrow;
    UIView *logoutLine; 
    
    NSMutableArray *cellTitles;
    NSMutableArray *cellIcons; 
    NSMutableArray *cellSelectors;  
    id<AccountSettingsViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation AccountSettingsViewController

- (id) initWithDelegate:(id<AccountSettingsViewControllerDelegate>)d
{
    if(self = [super init])
    {
        delegate = d;
        self.title = NSLocalizedString(@"AccountSettingsKey", @"");
        
        cellTitles    = [[NSMutableArray alloc] initWithCapacity:5];
        cellIcons     = [[NSMutableArray alloc] initWithCapacity:5]; 
        cellSelectors = [[NSMutableArray alloc] initWithCapacity:5]; 
        
        [cellTitles addObject:NSLocalizedString(@"PublicNameAndImageKey", @"")];
        [cellIcons addObject:[UIImage imageNamed:@"id_card.png"]];
        [cellSelectors addObject:[[ARISSelectorHandle alloc] initWithHandler:self selector:@selector(profileButtonTouched)]];
        
        [cellTitles addObject:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"ChangePasswordKey", @"")]];
        [cellIcons addObject:[UIImage imageNamed:@"lock.png"]];
        [cellSelectors addObject:[[ARISSelectorHandle alloc] initWithHandler:self selector:@selector(passButtonTouched)]]; 
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    self.view.backgroundColor = [ARISTemplate ARISColorSideNavigationBackdrop]; 
    
    tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.opaque = NO;
    tableView.backgroundColor = [UIColor clearColor];
       
    logoutButton = [[UIView alloc] init];
    logoutButton.userInteractionEnabled = YES;
    logoutButton.backgroundColor = [ARISTemplate ARISColorTextBackdrop];
    logoutButton.opaque = NO;
    [logoutButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutButtonTouched)]];  
    
    logoutLabel = [[UILabel alloc] init];  
    logoutLabel.textAlignment = NSTextAlignmentLeft;
    logoutLabel.font = [ARISTemplate ARISButtonFont];
    logoutLabel.text = NSLocalizedString(@"LogoutTitleKey", @"");
    logoutLabel.textColor = [ARISTemplate ARISColorText]; 
    logoutLabel.accessibilityLabel = @"Log Out";  
    
    logoutArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowBack"]];
       
    logoutLine = [[UIView alloc] init];
    logoutLine.backgroundColor = [UIColor ARISColorLightGray]; 
    
    [self.view addSubview:tableView];    
    [logoutButton addSubview:logoutLine];
    [logoutButton addSubview:logoutLabel];
    [logoutButton addSubview:logoutArrow]; 
    [self.view addSubview:logoutButton]; 
    
    UIView *logoContainer = [[UIView alloc] init];
    logoContainer.frame = self.navigationItem.titleView.frame;
    UIImageView *logoText  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_text_nav.png"]];
    logoText.frame = CGRectMake(logoContainer.frame.size.width/2-50, logoContainer.frame.size.height/2-15, 100, 30);
    [logoContainer addSubview:logoText];
    self.navigationItem.titleView = logoContainer; 
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    tableView.frame = self.view.bounds;
    tableView.contentInset = UIEdgeInsetsMake(64,0,44,0); 
    
    logoutButton.frame = CGRectMake(0,self.view.bounds.size.height-44,self.view.bounds.size.width,44); 
    logoutLabel.frame = CGRectMake(30,0,self.view.bounds.size.width-30,44);
    logoutArrow.frame = CGRectMake(6,13,19,19); 
    logoutLine.frame = CGRectMake(0,0,self.view.bounds.size.width,1);
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [tableView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellTitles.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    c.opaque = NO;
    c.backgroundColor = [UIColor clearColor];
    c.textLabel.textColor = [ARISTemplate ARISColorSideNavigationText];
    c.textLabel.font = [ARISTemplate ARISButtonFont]; 
    c.textLabel.text = [cellTitles objectAtIndex:indexPath.row];
    c.imageView.image = [cellIcons objectAtIndex:indexPath.row];
    
    return c;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((ARISSelectorHandle *)[cellSelectors objectAtIndex:indexPath.row]) go];
}

- (void) logoutButtonTouched
{
    [_MODEL_ logOut];
}

- (void) profileButtonTouched
{
    [delegate profileEditRequested];
}

- (void) passButtonTouched
{
    [delegate passChangeRequested];
}

- (void) dealloc
{
    
}

@end
