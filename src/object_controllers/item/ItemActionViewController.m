//
//  ItemActionViewController.m
//  ARIS
//
//  Created by Brian Thiel on 7/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ItemActionViewController.h"
#import "ARISAppDelegate.h"
#import "ARISAlertHandler.h"
#import "AppServices.h"
#import "Media.h"

@interface ItemActionViewController() <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIButton *actionButton;
    UIPickerView *picker;
    
    NSString *prompt;
    int qty;
    int amtChosen;
    
    id<ItemActionViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation ItemActionViewController

- (id) initWithPrompt:(NSString *)s qty:(int)q delegate:(id)d
{
    if(self = [super init])
    {
        prompt = s;
        qty = q;
        
        amtChosen = qty;
        delegate = d;
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height/2,self.view.bounds.size.width,self.view.bounds.size.height/2)];
    [picker selectRow:1 inComponent:0 animated:NO]; 
    
    actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [actionButton setTitle:prompt forState:UIControlStateNormal];
    actionButton.frame = CGRectMake(20, 84, self.view.bounds.size.width-40, 40);
    
    [self.view addSubview:picker];
    [self.view addSubview:actionButton]; 
}

- (void) actionButtonTouched
{
    [delegate amtChosen:amtChosen];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return qty+1;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(row == 0) return @"Max";
    else return [NSString stringWithFormat:@"%d",row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(row == 0) amtChosen = qty;
    else         amtChosen = row;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
