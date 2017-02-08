//
//  ARTargetsModel.m
//  ARIS
//
//  Created by Phil Dougherty on 2/13/13.
//
//

// RULE OF THUMB:
// Merge any new object data rather than replace. Becuase 'everything is pointers' in obj c,
// we can't know what data we're invalidating by replacing a ptr

#import "ARTargetsModel.h"
#import "AppModel.h"
#import "AppServices.h"
#import "SBJson.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ARTargetsModel() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
  NSMutableData *xmlData;
  NSURLRequest *xmlRequest;
  NSURLConnection *xmlConnection;
  
  NSMutableData *datData;
  NSURLRequest *datRequest;
  NSURLConnection *datConnection;
}

@end

@implementation ARTargetsModel

@synthesize ar_targets;
@synthesize xmlURL;
@synthesize datURL;

- (id) init
{
  if(self = [super init])
  {
    [self clearGameData];
    _ARIS_NOTIF_LISTEN_(@"SERVICES_AR_TARGETS_RECEIVED",self,@selector(arTargetsReceived:),nil);
  }
  return self;
}

- (void) requestGameData
{
  [self requestARTargets];
  [self loadTargetDB];
}
- (void) clearGameData
{
  ar_targets = [[NSMutableDictionary alloc] init];
  n_game_data_received = 0;
}
- (long) nGameDataToReceive
{
  return 3;
}

- (void) arTargetsReceived:(NSNotification *)notif
{
  [self updateARTargets:notif.userInfo[@"ar_targets"]];
}

- (void) updateARTargets:(NSArray *)newARTargets
{
  ARTarget *newARTarget;
  NSNumber *newARTargetId;
  for(long i = 0; i < newARTargets.count; i++)
  {
    newARTarget = [newARTargets objectAtIndex:i];
    newARTargetId = [NSNumber numberWithLong:newARTarget.ar_target_id];
    if(!ar_targets[newARTargetId]) [ar_targets setObject:newARTarget forKey:newARTargetId];
  }
  n_game_data_received++;
  _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGETS_AVAILABLE",nil,nil);
  _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
}

- (void) requestARTargets
{
  [_SERVICES_ fetchARTargets];
}

// null ar_target (id == 0) NOT flyweight!!! (to allow for temporary customization safety)
- (ARTarget *) arTargetForId:(long)ar_target_id
{
  if(!ar_target_id) return [[ARTarget alloc] init];
  return ar_targets[[NSNumber numberWithLong:ar_target_id]];
}

- (NSString *) serializedName
{
  return @"ar_targets";
}

- (NSString *) serializeGameData
{
  NSArray *ar_targets_a = [ar_targets allValues];
  ARTarget *s_o;

  NSMutableString *r = [[NSMutableString alloc] init];
  [r appendString:@"{\"ar_targets\":["];
  for(long i = 0; i < ar_targets_a.count; i++)
  {
    s_o = ar_targets_a[i];
    [r appendString:[s_o serialize]];
    if(i != ar_targets_a.count-1) [r appendString:@","];
  }
  [r appendString:@"]}"];
  return r;
}

- (void) deserializeGameData:(NSString *)data
{
  [self clearGameData];
  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];

  NSDictionary *d_data = [jsonParser objectWithString:data];
  NSArray *d_ar_targets = d_data[@"ar_targets"];
  for(long i = 0; i < d_ar_targets.count; i++)
  {
    ARTarget *s = [[ARTarget alloc] initWithDictionary:d_ar_targets[i]];
    [ar_targets setObject:s forKey:[NSNumber numberWithLong:s.ar_target_id]];
  }
  n_game_data_received = [self nGameDataToReceive];
}

- (void) loadTargetDB
{
  NSURL *xmlUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/gamedatav2/%ld/ar/vuforiadb.xml",_MODEL_.serverURL,_MODEL_GAME_.game_id]];
  xmlData = [[NSMutableData alloc] initWithCapacity:2048];
  xmlRequest = [NSURLRequest requestWithURL:xmlUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
  xmlConnection = [[NSURLConnection alloc] initWithRequest:xmlRequest delegate:self];
  
  NSURL *datUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/gamedatav2/%ld/ar/vuforiadb.dat",_MODEL_.serverURL,_MODEL_GAME_.game_id]];
  datData = [[NSMutableData alloc] initWithCapacity:2048];
  datRequest = [NSURLRequest requestWithURL:datUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
  datConnection = [[NSURLConnection alloc] initWithRequest:datRequest delegate:self];
}

- (void) connection:(NSURLConnection *)c didReceiveData:(NSData *)d
{
  if(c == xmlConnection) [xmlData appendData:d];
  if(c == datConnection) [datData appendData:d];
}

- (void) connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
  if(c == xmlConnection)
  {
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_XML_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
  if(c == datConnection)
  {
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_DAT_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c
{
  NSString *g = [NSString stringWithFormat:@"%ld",_MODEL_GAME_.game_id]; //game_id as string
  NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
  NSString *partial_url;
  NSError *e;
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:newFolder isDirectory:nil])
    [[NSFileManager defaultManager] createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];
  
  if(c == xmlConnection)
  {
    partial_url = [NSString stringWithFormat:@"%@/vuforiadb.xml",g];
    xmlURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(partial_url)]];
    if([xmlData writeToURL:xmlURL atomically:YES])
      [xmlURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&e];
    xmlConnection = nil;
    xmlData = nil;
    n_game_data_received++;
    
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_XML_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
  if(c == datConnection)
  {
    partial_url = [NSString stringWithFormat:@"%@/vuforiadb.dat",g];
    datURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(partial_url)]];
    if([datData writeToURL:datURL atomically:YES])
      [datURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&e];
    datConnection = nil;
    datData = nil;
    n_game_data_received++;
    _ARIS_NOTIF_SEND_(@"MODEL_AR_TARGET_DB_DAT_AVAILABLE",nil,nil);
    _ARIS_NOTIF_SEND_(@"GAME_PIECE_AVAILABLE",nil,nil);
  }
}

//technically not associated with AR _targets_, but instead the _triggers_ associated with those targets.
- (void) cacheARData
{
  NSArray *triggers = _MODEL_TRIGGERS_.allTriggers;
  for(int i = 0; i < triggers.count; i++)
  {
    Trigger *trigger = triggers[i];
    if([trigger.type isEqualToString:@"AR"])
    {
      Media *media = [_MODEL_MEDIA_ mediaForId:trigger.icon_media_id];
      if([media.type isEqualToString:@"VIDEO"])
      {
        //short names to cope with obj-c verbosity
        NSString *g = [NSString stringWithFormat:@"%ld/AR",media.game_id]; //game_id as string
        NSString *f = [[[[media.remoteURL absoluteString] componentsSeparatedByString:@"/"] lastObject] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //filename

        NSString *newFolder = _ARIS_LOCAL_URL_FROM_PARTIAL_PATH_(g);
        NSString *splitting_done_url = [NSString stringWithFormat:@"%@/%@_done.txt",newFolder,f];

        //short names to cope with obj-c verbosity
        if(![[NSFileManager defaultManager] fileExistsAtPath:newFolder isDirectory:nil])
            [[NSFileManager defaultManager] createDirectoryAtPath:newFolder withIntermediateDirectories:YES attributes:nil error:nil];

        if(![[NSFileManager defaultManager] fileExistsAtPath:splitting_done_url isDirectory:nil])
        {
          AVAsset *avasset = [AVAsset assetWithURL:media.localURL];
          AVURLAsset *avurlasset = [AVURLAsset URLAssetWithURL:media.localURL options:nil];
          
          NSArray *tracks = [avurlasset tracksWithMediaType:AVMediaTypeVideo];
          AVAssetTrack *track = [tracks objectAtIndex:0];
          CMTime duration = track.timeRange.duration;
          
          float startTime = 0;
          float endTime = duration.value/(float)duration.timescale;
          
          NSString *audioPath = [NSString stringWithFormat:@"%@/%@.m4a",newFolder,f];
          
          AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:avasset presetName:AVAssetExportPresetAppleM4A];
          
          exportSession.outputURL = [NSURL fileURLWithPath:audioPath];
          exportSession.outputFileType = AVFileTypeAppleM4A;
          
          CMTime vocalStartMarker = CMTimeMake((int)(floor(startTime * 100)), 100);
          CMTime vocalEndMarker = CMTimeMake((int)(ceil(endTime * 100)), 100);
          
          CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(vocalStartMarker, vocalEndMarker);
          exportSession.timeRange= exportTimeRange;
          if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
          }
          
          [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status==AVAssetExportSessionStatusFailed) {
              NSLog(@"AR AUDIO failed");
            }
            else {
              NSLog(@"AR AUDIO AudioLocation : %@",audioPath);
            }
          }];
          
          // --- Data private to this unit ---
          UIImage *image;
          AVAssetImageGenerator *avassetimagegen;
          MPMoviePlayerViewController *video;

          video = [[MPMoviePlayerViewController alloc] initWithContentURL:media.localURL];
          video.moviePlayer.shouldAutoplay = NO;
          video.moviePlayer.controlStyle = MPMovieControlStyleNone;
          [video.moviePlayer play];
          
          avassetimagegen = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
        
          avassetimagegen.appliesPreferredTrackTransform = YES;
          // MT: if you don't have these next 2 lines,
          // the times of images are wildly off from the requested times
          avassetimagegen.requestedTimeToleranceBefore = kCMTimeZero;
          avassetimagegen.requestedTimeToleranceAfter = kCMTimeZero;
          CMTime time = [avasset duration];
          
          int width = 256;
          int height = 256;
          
          CGImageRef rawFrame;
          CGImageRef resizedFrame;
          int cur_frame = 0;
          while(cur_frame * 64 < ((float)duration.value/duration.timescale)*1000.) //15 fps
          {
            NSURL *arURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%d.png",newFolder,f,cur_frame]];
            
            // alpha PNG overrides
            if (media.media_id == 411187) {
              NSString *resourceName = [NSString stringWithFormat:@"theater_%03d_small.png", cur_frame - 1];
              NSLog(@"Copying frame %@ to %@", resourceName, arURL);
              [UIImagePNGRepresentation([UIImage imageNamed:resourceName]) writeToURL:arURL atomically:YES];
              cur_frame++;
              continue;
            } else if (media.media_id == 410680) {
              NSString *resourceName = [NSString stringWithFormat:@"drycleaner_%03d_small.png", cur_frame - 1];
              NSLog(@"Copying frame %@ to %@", resourceName, arURL);
              [UIImagePNGRepresentation([UIImage imageNamed:resourceName]) writeToURL:arURL atomically:YES];
              cur_frame++;
              continue;
            } else if (media.media_id == 411383) {
              NSString *resourceName = [NSString stringWithFormat:@"tvshop_%03d_small.png", cur_frame - 1];
              NSLog(@"Copying frame %@ to %@", resourceName, arURL);
              [UIImagePNGRepresentation([UIImage imageNamed:resourceName]) writeToURL:arURL atomically:YES];
              cur_frame++;
              continue;
            }
            
            time.value = ((cur_frame*64.)/1000.)*duration.timescale;
            rawFrame = [avassetimagegen copyCGImageAtTime:time actualTime:NULL error:NULL];
            
            // create context, keeping original image properties
            CGColorSpaceRef colorspace = CGImageGetColorSpace(rawFrame);
            CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                                         CGImageGetBitsPerComponent(rawFrame),
                                                         CGImageGetBitsPerPixel(rawFrame)/8*width,//CGImageGetBytesPerRow(image),
                                                         colorspace,
                                                         CGImageGetAlphaInfo(rawFrame));
            // CGColorSpaceRelease(colorspace);
    
            // draw image to context (resizing it)
            CGContextDrawImage(context, CGRectMake(0, 0, width, height), rawFrame);
            // extract resulting image from context
            resizedFrame = CGBitmapContextCreateImage(context);
            CGContextRelease(context);
            CGImageRelease(rawFrame);  // CGImageRef won't be released by ARC
    
            image = [UIImage imageWithCGImage:resizedFrame];
            NSData *pngImageData =  UIImagePNGRepresentation(image);
          
            _ARIS_LOG_(@"AR Caching %@",arURL.absoluteString);
            [pngImageData writeToURL:arURL options:0 error:nil];
            [arURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
            cur_frame++;
          }
          
          [@"done!" writeToFile:splitting_done_url atomically:true encoding:NSUTF8StringEncoding error:nil];
        }
      }
    }
  }
  _ARIS_NOTIF_SEND_(@"AR_DATA_LOADED",nil,nil);
}

- (void) dealloc
{
  if(xmlConnection) [xmlConnection cancel];
  if(datConnection) [datConnection cancel];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
