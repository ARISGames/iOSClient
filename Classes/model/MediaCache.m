//
//  MediaCache.m
//  ARIS
//
//  Created by Brian Thiel on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaCache.h"
#import "AppServices.h"

@implementation MediaCache
@synthesize mediaCount,maxMediaCount,context;

- (void)clearCache{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
        NSLog(@"Media object deleted");
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting Media - error:%@",error);
    }
    
}


-(void)deleteMediaFromCDWithId:(int)mediaId{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:[AppModel sharedAppModel].managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppModel sharedAppModel].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        int objectId = [[(Media *)managedObject uid]intValue];
        if(objectId == mediaId)
        {
            [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
            NSLog(@"Media object deleted");
        }
    }
    if (![[AppModel sharedAppModel].managedObjectContext save:&error]) {
        NSLog(@"Error deleting Media - error:%@",error);
    }
    
}



-(Media *)mediaForMediaId:(int)uid{
    NSLog(@"MediaCache:getSavedMediaWithId: %d",uid);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uid = %d", uid];
    [fetchRequest setPredicate:predicate];
    NSArray *allMedia = [context executeFetchRequest:fetchRequest error:&error] ;
if([allMedia count] != 0)
{
        Media *media = (Media *)[allMedia objectAtIndex:0];
            return media;
        
    }
    
    //Media Not found try fetching a new list and looking
    Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    media.uid = [NSNumber numberWithInt: uid];   
    
    return media;
   
}

-(Media *)mediaForUrl:(NSURL *)url{
    NSLog(@"MediaCache:mediaForUrl");
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media" 
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"url like %@", [url absoluteString]];
    [fetchRequest setPredicate:predicate];
    NSArray *allMedia = [context executeFetchRequest:fetchRequest error:&error] ;
    if([allMedia count] != 0)
    {
        Media *media = (Media *)[allMedia objectAtIndex:0];
            return media;
        
    }
    
    //Media Not found try fetching a new list and looking
    Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    media.url = [url absoluteString];   
    
    return media;
}
#pragma mark Header Implementations


- (id)init
{
    self = [super init];
    if (self) {
        mediaCount = 0;
        maxMediaCount = 100;
        self.context = [AppModel sharedAppModel].managedObjectContext;
       // [self clearCache];
    }
    return self;
}

@end
