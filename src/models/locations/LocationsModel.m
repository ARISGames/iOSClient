//
//  LocationsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/20/13.
//
//

#import "LocationsModel.h"

@implementation LocationsModel

@synthesize currentLocations;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self clearData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(latestPlayerLocationsReceived:) name:@"LatestPlayerLocationsReceived" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearData
{
    [self updateLocations:[[NSArray alloc] init]];
}

-(void)latestPlayerLocationsReceived:(NSNotification *)notification
{
    [self updateLocations:[notification.userInfo objectForKey:@"locations"]];
}

-(void)updateLocations:(NSArray *)locations
{
    NSMutableArray *newlyAvailableLocations   = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableArray *newlyUnavailableLocations = [[NSMutableArray alloc] initWithCapacity:5];
    
    //Gained Locations
    for(Location *newLocation in locations)
    {
        BOOL match = NO;
        for (Location *existingLocation in self.currentLocations)
        {
            if ([newLocation compareTo:existingLocation])
                match = YES;
        }
        
        if(!match) //New Location
            [newlyAvailableLocations addObject:newLocation];
    }
    
    //Lost Locations
    for (Location *existingLocation in self.currentLocations)
    {
        BOOL match = NO;
        for (Location *newLocation in locations)
        {
            if ([newLocation compareTo:existingLocation])
                match = YES;
        }
        
        if(!match) //Lost location
            [newlyUnavailableLocations addObject:existingLocation];
    }
    
    self.currentLocations = locations;
    
    if([newlyAvailableLocations count] > 0)
    {
        NSDictionary *lDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyAvailableLocations,@"newlyAvailableLocations",
                               locations,@"allLocations",
                               nil];
        NSLog(@"NSNotification: NewlyAvailableLocationsAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyAvailableLocationsAvailable" object:self userInfo:lDict]];
    }
    if([newlyUnavailableLocations count] > 0)
    {
        NSDictionary *lDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               newlyUnavailableLocations,@"newlyUnavailableLocations",
                               locations,@"allLocations",
                               nil];
        NSLog(@"NSNotification: NewlyUnavailableLocationsAvailable");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NewlyUnavailableLocationsAvailable" object:self userInfo:lDict]];
    }
    NSDictionary *lDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           locations,@"allLocations",
                           nil];
    NSLog(@"NSNotification: LocationsAvailable");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LocationsAvailable" object:self userInfo:lDict]];
}

-(int)modifyQuantity:(int)quantityModifier forLocationId:(int)locationId
{
	NSLog(@"LocationsModel: modifying quantity for a location in the local location list");
    NSMutableArray *newLocations = [[NSMutableArray alloc] initWithCapacity:[self.currentLocations count]];
    for(int i = 0; i < [self.currentLocations count]; i++)
        [newLocations addObject:[((Location *)[self.currentLocations objectAtIndex:i]) copy]];
    
    Location *tmpLocation;
	for (int i = 0; i < [newLocations count]; i++)
    {
        tmpLocation = (Location *)[newLocations objectAtIndex:i];
		if (tmpLocation.locationId == locationId && tmpLocation.gameObject.type == GameObjectItem)
			tmpLocation.qty += quantityModifier;
        if(tmpLocation.qty == 0) { [newLocations removeObjectAtIndex:i]; i--; }
	}
    
    [self updateLocations:newLocations];
    return tmpLocation.qty;
}

-(Location *)locationForId:(int)locationId
{
    for(int i = 0; i < [currentLocations count]; i++)
        if(((Location *)[currentLocations objectAtIndex:i]).locationId == locationId) return [currentLocations objectAtIndex:i];
    return nil;
}

@end
