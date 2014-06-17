//
//  MediaModel.m
//  ARIS
//
//  Created by Brian Thiel on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "MediaCD.h"

#import "NSDictionary+ValidParsers.h"

@interface MediaModel()
{
    NSMutableDictionary *medias; //light cache on mediaCD wrappers ('Media' objects)
    NSManagedObjectContext *context;
}

@end

@implementation MediaModel

- (id) initWithContext:(NSManagedObjectContext *)c
{
    if(self = [super init])
    {
        [self clearGameData];
        context = c;
        _ARIS_NOTIF_LISTEN_(@"SERVICES_MEDIA_RECEIVED",self,@selector(mediasReceived:),nil);
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

- (void) clearGameData
{
    medias = [[NSMutableDictionary alloc] init];
}

- (void) mediasReceived:(NSNotification *)notif
{
    [self updateMedias:notif.userInfo[@"media"]];
}

//Different than other models, as it expects raw dicts rather than fully populated objects
- (void) updateMedias:(NSArray *)mediaToCacheDicts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(game_id = 0) OR (game_id = %d)", _MODEL_GAME_.game_id];
    NSArray *currentlyCachedMediaArray = [self mediaForPredicate:predicate]; 

    //Turn array to dict for quick check of existence in cache
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < currentlyCachedMediaArray.count; i++)
        [currentlyCachedMediaMap setObject:currentlyCachedMediaArray[i] forKey:((MediaCD *)currentlyCachedMediaArray[i]).media_id];

    MediaCD *tmpMedia;
    for(int i = 0; i < mediaToCacheDicts.count; i++)
    {
        NSDictionary *mediaDict = mediaToCacheDicts[i];

        int media_id = [mediaDict validIntForKey:@"media_id"];
        if(!(tmpMedia = currentlyCachedMediaMap[[NSNumber numberWithInt:media_id]]))
        {
            tmpMedia = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
            tmpMedia.media_id = [NSNumber numberWithInt:media_id];
        }

        NSString *remoteURL = [mediaDict validObjectForKey:@"url"];
        if(![remoteURL isEqualToString:tmpMedia.remoteURL]) //if remote URL changed, invalidate local URL
            tmpMedia.localURL = nil;
        tmpMedia.remoteURL = remoteURL;

        tmpMedia.game_id = [NSNumber numberWithInt:[mediaDict validIntForKey:@"game_id"]];
        tmpMedia.user_id = [NSNumber numberWithInt:[mediaDict validIntForKey:@"user_id"]];
        NSLog(@"Cached Media: %d with URL: %@",media_id,tmpMedia.remoteURL);
    }
    [self commitContext];
    _ARIS_NOTIF_SEND_(@"MODEL_MEDIA_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestMedia
{
  [_SERVICES_ fetchMedia];
}

- (Media *) mediaForId:(int)media_id
{
  if(media_id == 0) return nil;

  Media *media;
  if(!(media = medias[[NSNumber numberWithInt:media_id]])) //if doesn't exist in light cache...
  {
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"media_id = %d", media_id];
    NSArray *matchingCachedMediaArray = [self mediaForPredicate:predicate];

    if(matchingCachedMediaArray.count != 0) //if DOES exist in disk cache
      media = [[Media alloc] initWithMediaCD:(MediaCD *)matchingCachedMediaArray[0]];
    else //if doesn't yet exist
    {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithInt:media_id];
      mediaCD.game_id  = [NSNumber numberWithInt:0];
      mediaCD.user_id  = [NSNumber numberWithInt:0];
      media = [[Media alloc] initWithMediaCD:mediaCD]; 
    }
  }
  medias[[NSNumber numberWithInt:media.media_id]] = media; //set light cache

  [self commitContext];

  return media;
}

- (Media *) newMedia
{
    MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
    mediaCD.media_id = [NSNumber numberWithInt:0];
    mediaCD.game_id  = [NSNumber numberWithInt:0];
    mediaCD.user_id  = [NSNumber numberWithInt:0];
    return [[Media alloc] initWithMediaCD:mediaCD];
}

- (void) saveAlteredMedia:(Media *)m //yuck
{
    [self commitContext];
}

@end
