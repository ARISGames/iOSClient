//
//  GameObjectDisplayViewController.m
//  ARIS
//
//  Created by Phil Dougherty on 3/1/13.
//
//

#import "GameObjectDisplayViewController.h"

@interface GameObjectDisplayViewController ()

@end

@implementation GameObjectDisplayViewController

- (id)initWithRootViewController:(UIViewController *)d
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        delegate = d;
        
        currentlyDisplayedObject       = nil;
        currentlyDisplayedObjectOrigin = nil;
        displayQueue = [[NSMutableArray alloc] initWithCapacity:5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dequeueDisplayPackage) name:@"DisplayObjectDismissed" object:nil];
    }
    return self;
}

- (void)display:(id<DisplayableObjectProtocol>)object from:(id<DisplayOriginProtocol>)origin
{
    NSDictionary * displayPackage = [[NSDictionary alloc] initWithObjectsAndKeys:object,@"object",origin,@"origin", nil];
    [displayQueue addObject:displayPackage];
    
    if(!currentlyDisplayedObject && !currentlyDisplayedObjectOrigin) [self dequeueDisplayPackage];
}

- (void)dequeueDisplayPackage
{
    [self.view removeFromSuperview];
    if([displayQueue count] == 0) return;
    
    if(currentlyDisplayedObjectOrigin) [currentlyDisplayedObjectOrigin finishedDisplayingObject];
        
    NSDictionary *displayPackage;
    displayPackage = [displayQueue objectAtIndex:0];
    currentlyDisplayedObject       = [displayPackage objectForKey:@"object"];
    currentlyDisplayedObjectOrigin = [displayPackage objectForKey:@"origin"];
    currentlyDisplayedView         = [currentlyDisplayedObject getViewForDisplay];
    
    [self.view addSubview:currentlyDisplayedView];
    [currentlyDisplayedObjectOrigin didDisplayObject];
    
    [displayQueue removeObjectAtIndex:0];

    [delegate.view addSubview:self.view];
}

@end
