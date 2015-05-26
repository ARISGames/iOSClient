//
//  LoadingIndicatorViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "LoadingIndicatorViewController.h"
#import "ARISMediaView.h"

@interface LoadingIndicatorViewController() <ARISMediaViewDelegate>
{
  NSMutableArray *connections; // ?
  NSMutableArray *labels;      // UILabel
  NSMutableArray *bars;        // UIProgressView
  id<LoadingIndicatorViewDelegate> __unsafe_unretained delegate;
}
@end

@implementation LoadingIndicatorViewController

- (id) initWithDelegate:(id <LoadingIndicatorViewDelegate>)d
{
  if(self = [super init])
  {
    connections = [[NSMutableArray alloc] init];
    labels      = [[NSMutableArray alloc] init];
    bars        = [[NSMutableArray alloc] init];
    delegate = d;
  }
  return self;
}

- (void) loadView
{
  [super loadView];

  self.view.backgroundColor = [[UIColor ARISColorTranslucentWhite] colorWithAlphaComponent:0.4];
  self.view.userInteractionEnabled = NO;
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  for(long i = 0; i < connections.count; i++)
  {
    //labels[i].frame = CGRectMake(0,0,0,0);
    //bars[i].frame = CGRectMake(0,0,0,0);
  }
}

- (void) dealloc
{

}

@end
