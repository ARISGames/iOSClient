//
//  Media.m
//  ARIS
//
//  Created by Phil Dougherty on 12/17/13.
//
//

#import "Media.h"
#import "MediaCD.h"
#import "AppModel.h"

@interface Media()
{
  MediaCD *mediaCD;
}

@end

@implementation Media

@synthesize media_id;
@synthesize game_id;
@synthesize user_id;
@synthesize autoplay;
@synthesize localURL;
@synthesize remoteURL;
@synthesize data;
@synthesize thumb;

- (id) init
{
  _ARIS_LOG_(@"SHOULDNT MANUALLY INIT MEDIA- get it from mediaModel");
  return nil;
}

- (id) initWithMediaCD:(MediaCD *)mcd
{
  if(self = [super init])
  {
    mediaCD = mcd;
  }
  return self;
}

- (long) game_id
{
  return [mediaCD.game_id intValue];
}

- (void) setGameId:(long)gid
{
  mediaCD.game_id = [NSNumber numberWithLong:gid];
}

- (long) user_id
{
  return [mediaCD.user_id intValue];
}

- (void) setUserId:(long)uid
{
  mediaCD.user_id = [NSNumber numberWithLong:uid];
}

- (long) media_id
{
  return [mediaCD.media_id intValue];
}

- (void) setMediaId:(long)mid
{
  mediaCD.media_id = [NSNumber numberWithLong:mid];
}

- (BOOL) autoplay
{
  return [mediaCD.autoplay intValue] != 0;
}

- (void) setAutoplay:(BOOL)ap
{
  mediaCD.autoplay = [NSNumber numberWithLong:(ap ? 1 : 0)];
}

- (NSURL *) localURL
{
  if(!mediaCD.localURL) return nil;
  if([mediaCD.localURL hasPrefix:@"file://"])
  {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@",mediaCD.localURL]];
  }
  else
  {
    return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(mediaCD.localURL)]];
  }
}

- (void) setPartialLocalURL:(NSString *)lURL
{
  mediaCD.localURL = lURL;
}

- (NSURL *) remoteURL
{
  //Hack to accommodate for server error
  NSString *fixedURLString = [mediaCD.remoteURL stringByReplacingOccurrencesOfString:@"gamedata//" withString:@"gamedata/player/"];
  return [NSURL URLWithString:fixedURLString];
}

- (void) setRemoteURL:(NSURL *)rURL
{
  mediaCD.remoteURL = [rURL absoluteString];
}

- (NSString *) fileExtension
{
  if(mediaCD.remoteURL) return [mediaCD.remoteURL pathExtension];
  return [mediaCD.localURL pathExtension];
}

- (NSString *) type
{
  NSString *ext = [[self fileExtension] lowercaseString];
  if([ext isEqualToString:@"jpg"]  ||
     [ext isEqualToString:@"jpeg"] ||
     [ext isEqualToString:@"png"]  ||
     [ext isEqualToString:@"gif"])
  {
    return @"IMAGE";
  }
  else if([ext isEqualToString:@"mov"] ||
          [ext isEqualToString:@"avi"] ||
          [ext isEqualToString:@"3gp"] ||
          [ext isEqualToString:@"m4v"] ||
          [ext isEqualToString:@"mp4"])
  {
    return @"VIDEO";
  }
  else if([ext isEqualToString:@"mp3"] ||
          [ext isEqualToString:@"wav"] ||
          [ext isEqualToString:@"m4a"] ||
          [ext isEqualToString:@"ogg"] ||
          [ext isEqualToString:@"caf"])
  {
    return @"AUDIO";
  }
  else return @"";
}

- (NSString *) mimeType
{
  NSString *ext = [[self fileExtension] lowercaseString];
  
  if ([ext isEqualToString:@"jpg"]) return @"image/jpeg";
  if ([ext isEqualToString:@"jpeg"]) return @"image/jpeg";
  if ([ext isEqualToString:@"png"]) return @"image/png";
  if ([ext isEqualToString:@"gif"]) return @"image/gif";
  
  if ([ext isEqualToString:@"mov"]) return @"video/quicktime";
  if ([ext isEqualToString:@"avi"]) return @"video/x-msvideo";
  if ([ext isEqualToString:@"3gp"]) return @"video/3gpp";
  if ([ext isEqualToString:@"m4v"]) return @"video/m4v";
  if ([ext isEqualToString:@"mp4"]) return @"video/mp4";
  
  if ([ext isEqualToString:@"mp3"]) return @"audio/mpeg";
  if ([ext isEqualToString:@"wav"]) return @"audio/wav";
  if ([ext isEqualToString:@"m4a"]) return @"audio/m4a";
  if ([ext isEqualToString:@"ogg"]) return @"audio/ogg";
  if ([ext isEqualToString:@"caf"]) return @"audio/x-caf";
  
  return @"application/octet-stream";
}

@end
