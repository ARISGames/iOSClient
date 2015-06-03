//
//  LoadingIndicatorViewController.m
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import "LoadingIndicatorViewController.h"
#import "ARISServiceResult.h"

@interface LoadingIndicatorViewController()
{
  NSMutableArray *connections; // ARISServiceResult
  NSMutableArray *labels;      // UILabel
  NSMutableArray *bars;        // UIProgressView
  NSMutableArray *spinners;    // UIActivityIndicatorView
  
  NSTimer *progressPoller;
  id<LoadingIndicatorViewControllerDelegate> __unsafe_unretained delegate;
}
@end

@implementation LoadingIndicatorViewController

- (id) initWithDelegate:(id <LoadingIndicatorViewControllerDelegate>)d
{
  if(self = [super init])
  {
    connections = [[NSMutableArray alloc] init];
    labels      = [[NSMutableArray alloc] init];
    bars        = [[NSMutableArray alloc] init];
    spinners    = [[NSMutableArray alloc] init];
    delegate = d;
    
    progressPoller = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pollProgress) userInfo:nil repeats:YES];
    _ARIS_NOTIF_LISTEN_(@"CONNECTION_LAG",self,@selector(connectionsLagging:),nil);
  }
  return self;
}

- (void) loadView
{
  [super loadView];
  
  self.view.userInteractionEnabled = NO;
}

- (void) viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  int h = self.view.frame.size.height;
  UILabel *l;
  UIProgressView *b;
  UIActivityIndicatorView *s;
  for(long i = 0; i < connections.count; i++)
  {
    l = labels[i];
    b = bars[i];
    s = spinners[i];

    l.frame = CGRectMake(10+10+10,h-55,self.view.frame.size.width-20-10-10,20);
    b.frame = CGRectMake(10,h-30,self.view.frame.size.width-20,20);
    s.frame = CGRectMake(10,h-50,10,10);

    h-=30;
  }
}

- (void) connectionsLagging:(NSNotification *)n
{
  NSArray *laggers = n.userInfo[@"laggers"];
  
  for(int i = 0; i < connections.count; i++)
  {
    BOOL found = NO;
    for(int j = 0; j < laggers.count; j++)
      if(connections[i] == laggers[j]) found = YES;
    if(!found)
    {
      [self removeConnectionAt:i];
      i--;
    }
  }
  
  for(int i = 0; i < laggers.count; i++)
  {
    BOOL found = NO;
    for(int j = 0; j < connections.count; j++)
      if(laggers[i] == connections[j]) found = YES;
    if(!found)
      [self addConnection:laggers[i]];
  }
}

- (void) pollProgress
{
  for(int i = 0; i < connections.count; i++)
  {
    ARISServiceResult *sr = connections[i];
    if(!sr.connection)
    {
      [self removeConnectionAt:i];
      i--;
    }
  }
  for(int i = 0; i < connections.count; i++)
    ((UIProgressView *)bars[i]).progress = ((ARISServiceResult *)connections[i]).progress;
}

- (void) addConnection:(ARISServiceResult *)a
{
  UILabel *l = [[UILabel alloc] init];
  UIProgressView *b = [[UIProgressView alloc] init];
  UIActivityIndicatorView *s = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  
  l.text = a.humanDescription;
  l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
  l.userInteractionEnabled = NO;
  b.userInteractionEnabled = NO;
  b.progress = a.progress;
  [s startAnimating];
  s.userInteractionEnabled = NO;
  
  [connections addObject:a];
  [labels      addObject:l];
  [bars        addObject:b];
  [spinners    addObject:s];
  
  [self.view addSubview:l];
  [self.view addSubview:b];
  [self.view addSubview:s];
}

- (void) removeConnectionAt:(int)i
{
  [labels[i] removeFromSuperview];
  [bars[i] removeFromSuperview];
  [spinners[i] removeFromSuperview];
  
  [connections removeObject:connections[i]];
  [labels      removeObject:labels[i]];
  [bars        removeObject:bars[i]];
  [spinners    removeObject:spinners[i]];
}

- (void) dealloc
{
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
