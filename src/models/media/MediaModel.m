//
//  MediaModel.m
//  ARIS
//
//  Created by Brian Thiel on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaModel.h"
#import "AppServices.h"
#import "Media.h"
#import "MediaCD.h"

#import "NSDictionary+ValidParsers.h"

@interface MediaModel()
{
    NSManagedObjectContext *context; 
}

@end

@implementation MediaModel

- (id) initWithContext:(NSManagedObjectContext *)c
{
    if(self = [super init])
    {
        context = c;
    }
    return self;
}

- (NSArray *) mediaForPredicate:(NSPredicate *)predicate
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MediaCD" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSArray *cachedMediaArray = [context executeFetchRequest:fetchRequest error:&error] ;
    
    return cachedMediaArray;
}

- (void) commitContext
{
    NSError *error; 
    if(![[AppModel sharedAppModel].managedObjectContext save:&error])
        NSLog(@"Error deleting Media - error:%@",error); 
}

- (void) clearCache
{
    NSArray *cachedMediaArray = [self mediaForPredicate:nil];
    
    for(NSManagedObject *managedObject in cachedMediaArray)
    {
        [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
        NSLog(@"Media object deleted"); //this is really only useful because this potentially takes a while, and this shows that its not frozen
    }
    
    [self commitContext];
}

- (void) deleteMediaFromCDWithId:(int)mediaId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mediaId = %d", mediaId];   
    NSArray *cachedMediaArray = [self mediaForPredicate:predicate];
    
    for(NSManagedObject *managedObject in cachedMediaArray)
    {
        [[AppModel sharedAppModel].managedObjectContext deleteObject:managedObject];
        NSLog(@"Media object deleted");
    }
    [self commitContext];
}

- (Media *) mediaForMediaId:(int)mediaId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"mediaId = %d", mediaId];
    NSArray *cachedMediaArray = [self mediaForPredicate:predicate];
    
    if([cachedMediaArray count] != 0)
    {
        MediaCD *mediaCD = (MediaCD *)[cachedMediaArray objectAtIndex:0];
        return [[Media alloc] initWithMediaCD:mediaCD];
    }
    
    //Media Not found; you should try fetching a new list from the server
    MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
    mediaCD.mediaId = [NSNumber numberWithInt:mediaId];
    
    [self commitContext];
    
    return [[Media alloc] initWithMediaCD:mediaCD]; 
}

- (void) syncMediaDataToCache:(NSArray *)mediaDataToCache
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(gameId = 0) OR (gameId = %d)", [AppModel sharedAppModel].currentGame.gameId]; 
    NSArray *currentlyCachedMediaArray = [self mediaForPredicate:predicate]; 
    
    //For quick check of existence in cache
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc] initWithCapacity:currentlyCachedMediaArray.count];
    for(int i = 0; i < [currentlyCachedMediaArray count]; i++)
        [currentlyCachedMediaMap setObject:[currentlyCachedMediaArray objectAtIndex:i] forKey:((MediaCD *)[currentlyCachedMediaArray objectAtIndex:i]).mediaId];
    
    MediaCD *tmpMedia;
    for(int i = 0; i < [mediaDataToCache count]; i++)
    {
        NSDictionary *mediaDict = [mediaDataToCache objectAtIndex:i];
        int mediaId        = [mediaDict validIntForKey:@"media_id"];
        NSString *fileName = [mediaDict validObjectForKey:@"file_path"];
        
        if(!(tmpMedia = [currentlyCachedMediaMap objectForKey:[NSNumber numberWithInt:mediaId]]))
        {
            tmpMedia = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
            tmpMedia.mediaId = [NSNumber numberWithInt:mediaId];
        }
        
        NSString *remoteURL = [NSString stringWithFormat:@"%@%@", [mediaDict validObjectForKey:@"url_path"], fileName];
        if(![remoteURL isEqualToString:tmpMedia.remoteURL])
        {
            tmpMedia.remoteURL = nil;
            tmpMedia.localURL = nil;
        }
        tmpMedia.remoteURL = remoteURL;
        
        tmpMedia.gameId = [NSNumber numberWithInt:[mediaDict validIntForKey:@"game_id"]];
        NSLog(@"Cached Media: %d with URL: %@",mediaId,tmpMedia.remoteURL);
    }
    [self commitContext];
}

@end
