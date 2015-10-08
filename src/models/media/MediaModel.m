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

@interface MediaModel() <ARISMediaLoaderDelegate>
{
  NSMutableDictionary *medias; //light cache on mediaCD wrappers ('Media' objects)
  NSManagedObjectContext *context;
  NSMutableDictionary *mediaIdsToLoad;
  NSMutableArray *mediaDataLoadDelegateHandles;
  NSMutableArray *mediaDataLoadMedia;
  int mediaDataLoaded;
}

@end

@implementation MediaModel

- (id) initWithContext:(NSManagedObjectContext *)c
{
    if(self = [super init])
    {
        [self clearGameData];
        context = c;
        _ARIS_NOTIF_LISTEN_(@"SERVICES_MEDIAS_RECEIVED",self,@selector(mediasReceived:),nil);
        _ARIS_NOTIF_LISTEN_(@"SERVICES_MEDIA_RECEIVED",self,@selector(mediaReceived:),nil);
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
        _ARIS_LOG_(@"Error saving media context - error:%@",error);
}

- (void) clearCache
{
    NSArray *cachedMediaArray = [self mediaForPredicate:nil];

    for(NSManagedObject *managedObject in cachedMediaArray)
    {
        [context deleteObject:managedObject];
        _ARIS_LOG_(@"Media object deleted"); //this is really only useful because this potentially takes a while, and this shows that its not frozen
    }

    [self commitContext];
}

- (void) requestGameData
{
  [self requestMedia];
}
- (void) clearGameData
{
    medias = [[NSMutableDictionary alloc] init];
    mediaIdsToLoad = [[NSMutableDictionary alloc] init];
    n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 1;
}

- (void) mediasReceived:(NSNotification *)notif
{
    [self updateMedias:notif.userInfo[@"medias"]];
}

- (void) mediaReceived:(NSNotification *)notif
{
    [self updateMedias:@[notif.userInfo[@"media"]]];
}

//Different than other models, as it expects raw dicts rather than fully populated objects
- (void) updateMedias:(NSArray *)mediaToCacheDicts
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(game_id = 0) OR (game_id = %ld)", _MODEL_GAME_.game_id];
    NSArray *currentlyCachedMediaArray = [self mediaForPredicate:predicate];

    //Turn array to dict for quick check of existence in cache
    NSMutableDictionary *currentlyCachedMediaMap = [[NSMutableDictionary alloc] init];
    for(long i = 0; i < currentlyCachedMediaArray.count; i++)
        [currentlyCachedMediaMap setObject:currentlyCachedMediaArray[i] forKey:((MediaCD *)currentlyCachedMediaArray[i]).media_id];

    MediaCD *tmpMedia;
    for(long i = 0; i < mediaToCacheDicts.count; i++)
    {
        NSDictionary *mediaDict = mediaToCacheDicts[i];

        long media_id = [mediaDict validIntForKey:@"media_id"];
        [mediaIdsToLoad setObject:[NSNumber numberWithLong:media_id] forKey:[NSNumber numberWithLong:media_id]];
        if(!(tmpMedia = currentlyCachedMediaMap[[NSNumber numberWithLong:media_id]]))
        {
            tmpMedia = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
            tmpMedia.media_id = [NSNumber numberWithLong:media_id];
        }

        NSString *remoteURL = [mediaDict validObjectForKey:@"url"];
        if(![remoteURL isEqualToString:tmpMedia.remoteURL]) //if remote URL changed, invalidate local URL
            tmpMedia.localURL = nil;
        tmpMedia.remoteURL = remoteURL;

        tmpMedia.game_id = [NSNumber numberWithLong:[mediaDict validIntForKey:@"game_id"]];
        tmpMedia.user_id = [NSNumber numberWithLong:[mediaDict validIntForKey:@"user_id"]];
        _ARIS_LOG_(@"Media cache   : Media id:%ld cached:%@",media_id,tmpMedia.remoteURL);
    }
    [self commitContext];
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_MEDIA_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"MODEL_GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestMedia
{
  [_SERVICES_ fetchMedias];
}

- (void) requestMediaData
{
  NSArray *media_ids = [mediaIdsToLoad allKeys];
  Media *m;
  ARISDelegateHandle *d;

  mediaDataLoadDelegateHandles = [[NSMutableArray alloc] init];
  mediaDataLoadMedia = [[NSMutableArray alloc] init];
  mediaDataLoaded = 0;

  for(int i = 0; i < media_ids.count; i++)
  {
    m = [self mediaForId:[((NSNumber *)media_ids[i]) longValue]];
    if(!m.data)
    {
      d = [[ARISDelegateHandle alloc] initWithDelegate:self];
      [mediaDataLoadDelegateHandles addObject:d];
      [mediaDataLoadMedia addObject:m];
    }
  }
  if(mediaDataLoadDelegateHandles.count == 0)
    [self mediaLoaded:nil];

  for(int i = 0; i < mediaDataLoadMedia.count; i++) //needs separate loop so notif doesn't get sent in same stack as generating count
      [_SERVICES_MEDIA_ loadMedia:mediaDataLoadMedia[i] delegateHandle:mediaDataLoadDelegateHandles[i]]; //calls 'mediaLoaded' upon complete
}

- (void) mediaLoaded:(Media *)m
{
  mediaDataLoaded++;
  _ARIS_NOTIF_SEND_(@"MODEL_MEDIA_DATA_LOADED",nil,nil);
  if(mediaDataLoaded >= mediaDataLoadDelegateHandles.count)
  {
    _ARIS_NOTIF_SEND_(@"MODEL_MEDIA_DATA_COMPLETE",nil,nil);
    mediaDataLoadMedia = nil;
    mediaDataLoadDelegateHandles = nil;
  }
}

- (Media *) mediaForId:(long)media_id
{
  if(media_id == 0) return nil;

  //oh my hack
  if(media_id == DEFAULT_PLAQUE_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"plaque_icon_120"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }
  if(media_id == DEFAULT_ITEM_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"item_icon_120"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }
  if(media_id == DEFAULT_DIALOG_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"conversation_icon_120"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }
  if(media_id == DEFAULT_WEB_PAGE_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"webpage_icon_120"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }
  if(media_id == LOGO_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"logo_icon"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }
  if(media_id == DEFAULT_NOTE_ICON_MEDIA_ID)
  {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      Media *media = [[Media alloc] initWithMediaCD:mediaCD];
      media.data =  UIImagePNGRepresentation([UIImage imageNamed:@"note_icon"]);
      media.thumb = media.data;
      [media setPartialLocalURL:@"blah.png"]; //fake name to get it to know it's of type "IMAGE"
      return media;
  }

  Media *media;
  if(!(media = medias[[NSNumber numberWithLong:media_id]])) //if doesn't exist in light cache...
  {
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"media_id = %ld", media_id];
    NSArray *matchingCachedMediaArray = [self mediaForPredicate:predicate];

    if(matchingCachedMediaArray.count != 0) //if DOES exist in disk cache
      media = [[Media alloc] initWithMediaCD:(MediaCD *)matchingCachedMediaArray[0]];
    else //if doesn't yet exist
    {
      MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
      mediaCD.media_id = [NSNumber numberWithLong:media_id];
      mediaCD.game_id  = [NSNumber numberWithLong:0];
      mediaCD.user_id  = [NSNumber numberWithLong:0];
      media = [[Media alloc] initWithMediaCD:mediaCD];
    }
  }
  medias[[NSNumber numberWithLong:media.media_id]] = media; //set light cache

  [self commitContext];

  return media;
}

- (Media *) newMedia
{
    MediaCD *mediaCD = [NSEntityDescription insertNewObjectForEntityForName:@"MediaCD" inManagedObjectContext:context];
    mediaCD.media_id = [NSNumber numberWithLong:0];
    mediaCD.game_id  = [NSNumber numberWithLong:0];
    mediaCD.user_id  = [NSNumber numberWithLong:0];
    return [[Media alloc] initWithMediaCD:mediaCD];
}

- (void) saveAlteredMedia:(Media *)m //yuck
{
    [self commitContext];
}

@end
