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

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#include <math.h>

#include <libavutil/opt.h>
#include <libavcodec/avcodec.h>
#include <libavutil/channel_layout.h>
#include <libavutil/common.h>
#include <libavutil/imgutils.h>
#include <libavutil/mathematics.h>
#include <libavutil/samplefmt.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

#define INBUF_SIZE 4096

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

  NSError *error = nil;
  NSDictionary *d_data = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
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

- (NSString *) getSubtitleText:(AVSubtitleRect *)rect
{
  NSString *s;
  if (rect->type == SUBTITLE_TEXT) {
    s = [NSString stringWithUTF8String:rect->text];
  } else if (rect->type == SUBTITLE_ASS) {
    // TODO: this needs to be way more robust
    NSArray *comps = [[NSString stringWithUTF8String:rect->ass] componentsSeparatedByString:@","];
    NSArray *text_comps = [comps subarrayWithRange:NSMakeRange(9, [comps count] - 9)];
    s = [text_comps componentsJoinedByString:@","];
  } else {
    return nil;
  }
  s = [s stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
  s = [s stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
  s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if ([s isEqualToString:@""]) {
    return nil;
  } else {
    return s;
  }
}

//technically not associated with AR _targets_, but instead the _triggers_ associated with those targets.
- (void) cacheARData
{
  av_register_all();
  
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
          
          // ffmpeg stuff starts here
          
          AVFormatContext *pFormatCtx = NULL;
          if (avformat_open_input(&pFormatCtx, media.localURL.path.UTF8String, NULL, NULL) != 0) {
            NSLog(@"ffmpeg: error, avformat couldn't open input %@", media.localURL.path);
            continue;
          }
          if (avformat_find_stream_info(pFormatCtx, NULL) < 0) {
            NSLog(@"ffmpeg: error, couldn't find stream information");
            continue;
          }
          int videoStream = -1;
          int subtitleStream = -1;
          int fps_num, fps_den;
          BOOL fps_halved = NO;
          for(int i = 0; i < pFormatCtx->nb_streams; i++) {
            AVStream *strm = pFormatCtx->streams[i];
            if(strm->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
              fps_num = strm->avg_frame_rate.num;
              fps_den = strm->avg_frame_rate.den;
              if (((float) fps_num) / ((float) fps_den) > 29) {
                fps_halved = YES;
                fps_den *= 2;
                NSLog(@"ffmpeg: cutting video fps in half");
              }
              videoStream = i;
            } else if (strm->codec->codec_type == AVMEDIA_TYPE_SUBTITLE) {
              subtitleStream = i;
            }
          }
          if (videoStream == -1) {
            NSLog(@"ffmpeg: no video stream found");
            continue;
          }
          AVCodecContext *pCodecCtxOrig = pFormatCtx->streams[videoStream]->codec;
          AVCodecContext *pCodecCtxOrigSub = subtitleStream == -1 ? NULL : pFormatCtx->streams[subtitleStream]->codec;
          NSLog(@"ffmpeg: detected codec: %s", avcodec_get_name(pCodecCtxOrig->codec_id));
          
          // decode example stuff starts here
          AVCodec *pCodec;
          AVCodecContext *pCodecCtx = NULL;
          AVCodec *pCodecSub;
          AVCodecContext *pCodecCtxSub = NULL;
          
          pCodec = avcodec_find_decoder(pCodecCtxOrig->codec_id);
          if (!pCodec) {
            NSLog(@"ffmpeg: codec not found!");
            continue;
          }
          pCodecCtx = avcodec_alloc_context3(pCodec);
          if (avcodec_copy_context(pCodecCtx, pCodecCtxOrig) != 0) {
            NSLog(@"ffmpeg: couldn't copy codec context");
            continue;
          }
          if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
            NSLog(@"ffmpeg: could not open codec");
            continue;
          }
          
          if (pCodecCtxOrigSub) {
            pCodecSub = avcodec_find_decoder(pCodecCtxOrigSub->codec_id);
            if (!pCodecSub) {
              NSLog(@"ffmpeg: sub codec not found!");
              continue;
            }
            pCodecCtxSub = avcodec_alloc_context3(pCodecSub);
            if (avcodec_copy_context(pCodecCtxSub, pCodecCtxOrigSub) != 0) {
              NSLog(@"ffmpeg: couldn't copy sub codec context");
              continue;
            }
            if (avcodec_open2(pCodecCtxSub, pCodecSub, NULL) < 0) {
              NSLog(@"ffmpeg: could not open sub codec");
              continue;
            }
          }
          
          AVFrame *pFrame = av_frame_alloc();
          if (!pFrame) {
            NSLog(@"ffmpeg: could not allocate video frame");
            continue;
          }
          AVFrame *pFrameRGBA = av_frame_alloc();
          if (!pFrameRGBA) {
            NSLog(@"ffmpeg: could not allocate output frame");
            continue;
          }
          uint8_t *buffer = NULL;
          int numBytes = avpicture_get_size(PIX_FMT_RGBA, 256, 256);
          buffer = (uint8_t *) av_malloc(numBytes * sizeof(uint8_t));
          avpicture_fill((AVPicture *) pFrameRGBA, buffer, PIX_FMT_RGBA, 256, 256);
          pFrameRGBA->width = 256;
          pFrameRGBA->height = 256;
          pFrameRGBA->format = PIX_FMT_RGBA;
          
          NSLog(@"ffmpeg: initialized ok!");
          
          struct SwsContext *sws_ctx = NULL;
          int frameFinished;
          AVPacket packet;
          int frame_count = 0;
          sws_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt, 256, 256, PIX_FMT_RGBA, SWS_FAST_BILINEAR, NULL, NULL, NULL);
          BOOL skip_frame = NO;
          NSMutableArray *captionStarts = [[NSMutableArray alloc] init];
          NSMutableArray *captionEnds   = [[NSMutableArray alloc] init];
          NSMutableArray *captionTexts  = [[NSMutableArray alloc] init];
          while (av_read_frame(pFormatCtx, &packet) >= 0) {
            if (packet.stream_index == videoStream) {
              int err = avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
              if (err < 0) {
                NSLog(@"ffmpeg: avcodec_decode_video2 failed");
                break;
              }
              if (frameFinished) {
                if (skip_frame) {
                  NSLog(@"ffmpeg: skipping a frame");
                  skip_frame = NO;
                  continue;
                }
                if (!skip_frame && fps_halved) skip_frame = YES;
                NSLog(@"ffmpeg: got frame %d", frame_count);
                sws_scale(sws_ctx, (uint8_t const * const *) pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameRGBA->data, pFrameRGBA->linesize);
                
                NSURL *arURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@_%d.png",newFolder,f,frame_count]];
                NSLog(@"ffmpeg: opening file %@", arURL);
                NSError *fileError;
                [[NSFileManager defaultManager] createFileAtPath:arURL.path contents:nil attributes:nil];
                NSFileHandle *f_frame = [NSFileHandle fileHandleForWritingToURL:arURL error:&fileError];
                if (fileError) {
                  NSLog(@"%@", fileError);
                }
                
                AVCodec *codecOut = avcodec_find_encoder(AV_CODEC_ID_PNG);
                AVCodecContext *contextOut = avcodec_alloc_context3(codecOut);
                contextOut->pix_fmt = PIX_FMT_RGBA;
                contextOut->height = 256;
                contextOut->width = 256;
                contextOut->codec_type = AVMEDIA_TYPE_VIDEO;
                contextOut->time_base.num = pCodecCtx->time_base.num;
                contextOut->time_base.den = pCodecCtx->time_base.den;
                err = avcodec_open2(contextOut, codecOut, NULL);
                if (err < 0) {
                  NSLog(@"ffmpeg: error, avcodec_open2 (png output) failed with %d", err);
                  break;
                }
                AVPacket outPacket;
                av_init_packet(&outPacket);
                outPacket.size = 0;
                outPacket.data = NULL;
                int got_frame = 0;
                if (avcodec_encode_video2(contextOut, &outPacket, pFrameRGBA, &got_frame) < 0) {
                  NSLog(@"ffmpeg: error, could not encode video frame");
                  break;
                }
                
                NSData *data_frame = [NSData dataWithBytes:outPacket.data length:outPacket.size];
                [f_frame writeData:data_frame];
                [f_frame closeFile];
                
                av_free_packet(&outPacket);
                avcodec_close(contextOut);
                av_free(contextOut);
                
                frame_count++;
              }
            } else if (packet.stream_index == subtitleStream) {
              int gotSub;
              AVSubtitle sub;
              int err = avcodec_decode_subtitle2(pCodecCtxSub, &sub, &gotSub, &packet);
              if (err < 0) {
                NSLog(@"ffmpeg: avcodec_decode_subtitle2 failed");
              }
              if (gotSub) {
                if (sub.num_rects > 0) {
                  NSString *cap = [self getSubtitleText:sub.rects[0]];
                  if (cap) {
                    double packetTime
                      = ((double) packet.pts)
                      * ((double) pFormatCtx->streams[subtitleStream]->time_base.num)
                      / ((double) pFormatCtx->streams[subtitleStream]->time_base.den);
                    double capStart = packetTime + ((double) sub.start_display_time) / 1000;
                    double capEnd = packetTime + ((double) sub.end_display_time) / 1000;
                    [captionStarts addObject:[NSNumber numberWithDouble:capStart]];
                    [captionEnds addObject:[NSNumber numberWithDouble:capEnd]];
                    [captionTexts addObject:cap];
                    NSLog(@"Got subtitle: %@", cap);
                  } else {
                    NSLog(@"Got subtitle but rect text is NULL.");
                  }
                } else {
                  NSLog(@"Got subtitle with no rects.");
                }
              } else {
                NSLog(@"Got subtitle packet but no subtitle was decoded.");
              }
            }
            av_free_packet(&packet);
          }
          
          sws_freeContext(sws_ctx);
          av_free(buffer);
          av_frame_free(&pFrameRGBA);
          av_frame_free(&pFrame);
          if (pCodecCtxSub) avcodec_free_context(&pCodecCtxSub);
          avcodec_free_context(&pCodecCtx);
          avformat_free_context(pFormatCtx);
          
          NSString *logOutput = [NSString stringWithFormat:@"%d\n%d\n%lu\n", fps_num, fps_den, (unsigned long)captionStarts.count];
          for (int i = 0; i < captionStarts.count; i++) {
            logOutput = [logOutput stringByAppendingFormat:@"%@\n%@\n%@\n", [captionStarts[i] stringValue], [captionEnds[i] stringValue], captionTexts[i]];
          }
          [logOutput writeToFile:splitting_done_url atomically:true encoding:NSUTF8StringEncoding error:nil];
          NSLog(@"ffmpeg: video frame rate is %d/%d", fps_num, fps_den);
        }
      }
    }
    dispatch_async( dispatch_get_main_queue(), ^{
      float progress = ((float) i) / ((float) triggers.count);
      _ARIS_NOTIF_SEND_(@"AR_PERCENT_LOADED", nil,
                        @{@"percent":[NSNumber numberWithFloat:progress]});
    });
  }
  dispatch_async( dispatch_get_main_queue(), ^{
    _ARIS_NOTIF_SEND_(@"AR_DATA_LOADED",nil,nil);
  });
  return;
}

- (void) dealloc
{
  if(xmlConnection) [xmlConnection cancel];
  if(datConnection) [datConnection cancel];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
