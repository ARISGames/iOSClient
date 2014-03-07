//
//  OverlaysModel.m
//  ARIS
//
//  Created by Justin Moeller on 3/7/14.
//
//

#import "OverlaysModel.h"

@implementation OverlaysModel
@synthesize overlays;

- (id) init
{
    self = [super init];
    if (self) {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlaysReceived:) name:@"OverlaysReceived" object:nil];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) overlaysReceived:(NSNotification *)notification
{
    NSArray *newOverlays = [notification.userInfo objectForKey:@"overlays"];
    [self updateOverlays:newOverlays];
}

- (void) clearData
{
    [self updateOverlays:[[NSArray alloc] init]];
}

- (void) updateOverlays:(NSArray *)newOverlays
{
    overlays = newOverlays;
}

@end
