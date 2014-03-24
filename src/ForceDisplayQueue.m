//
//  ForceDisplayQueue.m
//  ARIS
//
//  Created by Phil Dougherty on 2/24/14.
//
//

#import "ForceDisplayQueue.h"

#import "StateControllerProtocol.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "Player.h"

@interface ForceDisplayQueue ()
{
    NSMutableArray *nearbyLocationsList;
    id<ForceDisplayQueueDelegate, StateControllerProtocol> __unsafe_unretained delegate;
}
@end

@implementation ForceDisplayQueue

- (id) initWithDelegate:(id<ForceDisplayQueueDelegate, StateControllerProtocol>)d
{
    if(self = [super init])
    {
        delegate = d;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceDisplayEligibleLocations) name:@"PlayerMoved"        object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceDisplayEligibleLocations) name:@"LocationsAvailable" object:nil];
		nearbyLocationsList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void) forceDisplayEligibleLocations
{
    NSMutableArray *newNearbyLocationsList = [NSMutableArray arrayWithCapacity:5];
    
    Location *forceLocation;
    
    //Find locations that are "nearby" from the list of all locations
    for(Location *location in [AppModel sharedAppModel].currentGame.locationsModel.currentLocations)
    {
        BOOL match = NO;
        for(Location *oldLocation in nearbyLocationsList)
            if(oldLocation.locationId == location.locationId) match = YES;
        if(!match && [[AppModel sharedAppModel].player.location distanceFromLocation:location.latlon] < location.errorRange &&
           (location.gameObject.type != GameObjectItem || location.qty > 0 || location.infiniteQty) && location.gameObject.type != GameObjectPlayer)
            [newNearbyLocationsList addObject:location];
        else if(match && (location.errorRange >= 2147483637 || [[AppModel sharedAppModel].player.location distanceFromLocation:location.latlon] < location.errorRange+10) &&
           (location.gameObject.type != GameObjectItem || location.qty > 0 || location.infiniteQty) && location.gameObject.type != GameObjectPlayer)
            [newNearbyLocationsList addObject:location];
    }
    
    //Find new nearby locations to be force displayed (ie- newly nearby && forcedDisplay == YES)
    BOOL match = NO; 
    BOOL shouldPlaySound = NO; 
    for(Location *location in newNearbyLocationsList)
    {
        match = NO;
        for(Location *oldLocation in nearbyLocationsList)
            if(oldLocation.locationId == location.locationId) match = YES;
        if(!match && location.forcedDisplay)
            forceLocation = location;
        if(!match) shouldPlaySound = YES;
    }
    
    //Try to display location- if successful, add to 'already nearby' list
    if(forceLocation)
    {
        if([delegate displayGameObject:forceLocation.gameObject fromSource:forceLocation])
            [nearbyLocationsList addObject:forceLocation];
    }
    
    //Otherwise, play sound and use new locations list as current
    else
    {
        if(shouldPlaySound) 
            [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] playAudioAlert:@"nearbyObject" shouldVibrate:NO];
        
        nearbyLocationsList = newNearbyLocationsList; //Throw out old locations list
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
