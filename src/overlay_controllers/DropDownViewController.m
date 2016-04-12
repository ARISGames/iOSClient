//
//  DropDownViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "DropDownViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "AppModel.h"

@interface DropDownViewController()
{
    UIView *dropDownView;
    UILabel *label;
}
@end

@implementation DropDownViewController

@synthesize delegate;

- (id) initWithDelegate:(id <DropDownViewDelegate>)d
{
  if(self = [super init])
  {
    delegate = d;
  }
  return self;
}


- (void) loadView
{
  [super loadView];

  self.view.backgroundColor = [UIColor ARISColorDarkBlue];

  dropDownView = [[UIView alloc] init];

  label = [[UILabel alloc] init];
  label.font = [ARISTemplate ARISBodyFont];
  label.textColor = [UIColor ARISColorWhite];
  label.textAlignment = NSTextAlignmentCenter;
  label.backgroundColor = [UIColor clearColor];

  [dropDownView addSubview:label];

  [self.view addSubview:dropDownView];
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  //self.view.frame = CGRectMake(0,22,self.view.bounds.size.width,1);
  self.view.clipsToBounds = YES;
  dropDownView.frame = CGRectMake(0,0,self.view.bounds.size.width,64);
  label.frame = CGRectMake(0,0,self.view.bounds.size.width,64);
}

- (void) setString:(NSString *)s
{
  if(!self.view) self.view.hidden = NO; //Just accesses view to force its load
  label.text = s;
  self.view.frame = CGRectMake(0,0,self.view.bounds.size.width,1);
  [UIView animateWithDuration:1 animations:^{self.view.frame = CGRectMake(0,0,self.view.bounds.size.width,64); } completion:nil];
  [self performSelector:@selector(requestDismiss) withObject:nil afterDelay:3.];
}

- (void) requestDismiss
{
  [UIView animateWithDuration:1
                   animations:^{self.view.frame = CGRectMake(0,0,self.view.bounds.size.width,1); }
                   completion:^(BOOL finished){if(delegate)[delegate dropDownRequestsDismiss];}];
}

@end
