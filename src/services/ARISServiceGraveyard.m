//
//  ARISServiceGraveyard.m
//  ARIS
//
//  Created by Phil Dougherty on 2/6/14.
//
//

#import "ARISServiceGraveyard.h"
#import "ARISConnection.h"
#import "ARISServiceResult.h"
#import "RequestCD.h"

@interface ARISServiceGraveyard()
{
    NSManagedObjectContext *context; 
}

@end

@implementation ARISServiceGraveyard

- (id) initWithContext:(NSManagedObjectContext *)c
{
    if(self = [super init])
    {
        context = c;
    }
    return self;
}

- (NSArray *) requestsForPredicate:(NSPredicate *)predicate
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RequestCD" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSArray *cachedRequestArray = [context executeFetchRequest:fetchRequest error:&error] ;
    
    return cachedRequestArray;
}

- (void) commitContext
{
    NSError *error; 
    if(![context save:&error])
        NSLog(@"Error saving request context - error:%@",error); 
}

- (void) clearCache
{
    NSArray *cachedRequestsArray = [self requestsForPredicate:nil];
    
    for(NSManagedObject *managedObject in cachedRequestsArray)
    {
        [context deleteObject:managedObject];
        NSLog(@"Request deleted"); //this is really only useful because this potentially takes a while, and this shows that its not frozen
    }
    
    [self commitContext];
}

- (void) addServiceResult:(ARISServiceResult *)sr
{
    RequestCD *requestCD = [NSEntityDescription insertNewObjectForEntityForName:@"RequestCD" inManagedObjectContext:context]; 
    requestCD.url = [sr.urlRequest.URL absoluteString]; 
    requestCD.method = sr.urlRequest.HTTPMethod;
    requestCD.body = sr.urlRequest.HTTPBody; 
    [self commitContext];
}

- (void) reviveRequestsWithConnection:(ARISConnection *)c
{
    NSArray *deadRequests = [self requestsForPredicate:nil]; 
    for(int i = 0; i < [deadRequests count]; i++)
    {
        [c performRevivalWithRequest:[deadRequests objectAtIndex:i]];
        [context deleteObject:[deadRequests objectAtIndex:i]];
    }
    [self commitContext];
}

@end
