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
    if(![context save:&error])
        NSLog(@"Error saving media context - error:%@",error); 
}

- (void) clearCache
{
    NSArray *cachedMediaArray = [self mediaForPredicate:nil];
    
    for(NSManagedObject *managedObject in cachedMediaArray)
    {
        [context deleteObject:managedObject];
        NSLog(@"Media object deleted"); //this is really only useful because this potentially takes a while, and this shows that its not frozen
    }
    
    [self commitContext];
}

- (void) deleteMediaFromCDWithId:(int)media_id
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"media_id = %d", media_id];   
    NSArray *cachedMediaArray = [self mediaForPredicate:predicate];
    
    for(NSManagedObject *managedObject in cachedMediaArray)
    {
        [context deleteObject:managedObject];
        NSLog(@"Media object deleted");
    }
    [self commitContext];
}

- (Media *) mediaForId:(int)media_id
{
    if(media_id == 0) return nil; 
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"media_id = %d", media_id];
    NSArray *cachedMediaArray = [self mediaForPredicate:predicate];
    
    if([cachedMediaArray count] != 0)
    {
        MediaCD *mediaCD = (MediaCD *)[cachedMediaArray objectAtIndex:0];
        return [[Media alloc] initWithMediaCD:mediaCD];
    }
    
    //Media Not found; you should try fetching a new list from the server
    MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
    mediaCD.media_id = [NSNumber numberWithInt:media_id];
    mediaCD.game_id = [NSNumber numberWithInt:0]; 
    
    [self commitContext];
    
    return [[Media alloc] initWithMediaCD:mediaCD]; 
}

- (Media *) newMedia
{
    MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
    return [[Media alloc] initWithMediaCD:mediaCD]; 
}

- (void) syncMediaDataToCache:(NSArray *)mediaDataToCache
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(game_id = 0) OR (game_id = %d)", _MODEL_GAME_.game_id]; 
    NSArray *currentlyCachedMediaArray = [self mediaForPredicate:predicate]; 
    
    //For quick check of existence in cache
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc] initWithCapacity:currentlyCachedMediaArray.count];
    for(int i = 0; i < [currentlyCachedMediaArray count]; i++)
        [currentlyCachedMediaMap setObject:[currentlyCachedMediaArray objectAtIndex:i] forKey:((MediaCD *)[currentlyCachedMediaArray objectAtIndex:i]).media_id];
    
    MediaCD *tmpMedia;
    for(int i = 0; i < [mediaDataToCache count]; i++)
    {
        NSDictionary *mediaDict = [mediaDataToCache objectAtIndex:i];
        int media_id        = [mediaDict validIntForKey:@"media_id"];
        NSString *fileName = [mediaDict validObjectForKey:@"file_path"];
        
        if(!(tmpMedia = [currentlyCachedMediaMap objectForKey:[NSNumber numberWithInt:media_id]]))
        {
            tmpMedia = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
            tmpMedia.media_id = [NSNumber numberWithInt:media_id];
        }
        
        NSString *remoteURL = [NSString stringWithFormat:@"%@%@", [mediaDict validObjectForKey:@"url_path"], fileName];
        if(![remoteURL isEqualToString:tmpMedia.remoteURL])
        {
            tmpMedia.remoteURL = nil;
            tmpMedia.localURL = nil;
        }
        tmpMedia.remoteURL = remoteURL;
        
        tmpMedia.game_id = [NSNumber numberWithInt:[mediaDict validIntForKey:@"game_id"]];
        NSLog(@"Cached Media: %d with URL: %@",media_id,tmpMedia.remoteURL);
    }
    [self commitContext];
}

- (void) saveAlteredMedia:(Media *)m //yuck
{
    [self commitContext];
}

@end
