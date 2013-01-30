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
    
    //Media Not found; you should try fetching a new list from the server
    Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
    media.uid = [NSNumber numberWithInt: uid];
    
    if (![context save:&error])
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    
    return media;
}

-(Media *)addMediaToCache:(int) uid{
    Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
    media.uid = [NSNumber numberWithInt: uid];
    return media;
}

-(NSArray *)mediaForPredicate:(NSPredicate *)predicate{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSArray *allMedia = [context executeFetchRequest:fetchRequest error:&error] ;
    
    return allMedia;
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
        NSLog(@"MediaCache:mediaForUrl: Found a media, reusing");
    }
    
    NSLog(@"MediaCache:mediaForUrl: Media Not Found, creating");
    
    //Media Not found; you should try fetching a new list from the server
    Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
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
        /*NSArray *allStores = [[AppModel sharedAppModel].persistentStoreCoordinator persistentStores];
         unsigned long long totalBytes = 0;
         NSFileManager *fileManager = [NSFileManager defaultManager];
         for (NSPersistentStore *store in allStores) {
         if (![store.URL isFileURL]) continue; // only file URLs are compatible with NSFileManager
         NSString *path = [[store URL] path];
         // NSDictionary has a category to assist with NSFileManager attributes
         totalBytes += [[fileManager attributesOfItemAtPath:path error:NULL] fileSize];
         }*/
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"UploadContent.sqlite"];
        
        NSError *error = nil;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:persistentStorePath error:&error];
        NSLog(@"Persistent store size: %@ bytes", [fileAttributes objectForKey:NSFileSize]);
        
        NSDictionary *fileSystemAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:persistentStorePath error:&error];
        NSLog(@"Free space on file system: %@ bytes", [fileSystemAttributes objectForKey:NSFileSystemFreeSize]);
        float mBLeft = [[fileSystemAttributes objectForKey:NSFileSystemFreeSize] floatValue]/(float)1000000;
        NSLog(@"Free space in MB: %f",mBLeft);
        if (mBLeft <= 100) {
            [self clearCache];
        }
    }
    return self;
}

@end
