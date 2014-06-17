//
//  Media.m
//  ARIS
//
//  Created by Phil Dougherty on 12/17/13.
//
//

#import "Media.h"
#import "MediaCD.h"

@interface Media()
{
    MediaCD *mediaCD;
}

@end

@implementation Media

@synthesize media_id;
@synthesize game_id;
@synthesize user_id;
@synthesize localURL;
@synthesize remoteURL;
@synthesize data;

- (id) init
{
    NSLog(@"SHOULDNT MANUALLY INIT MEDIA- get it from mediaModel");
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

- (int) game_id
{
    return [mediaCD.game_id intValue];
}

- (void) setGameId:(int)gid
{
    mediaCD.game_id = [NSNumber numberWithInt:gid];
}

- (int) user_id
{
    return [mediaCD.user_id intValue];
}

- (void) setUserId:(int)uid
{
    mediaCD.user_id = [NSNumber numberWithInt:uid];
}

- (int) media_id
{
    return [mediaCD.media_id intValue];
}

- (void) setMediaId:(int)mid
{
    mediaCD.media_id = [NSNumber numberWithInt:mid];
}

- (NSURL *) localURL
{
    return [NSURL URLWithString:mediaCD.localURL];
}

- (void) setLocalURL:(NSURL *)lURL
{
    mediaCD.localURL = [lURL absoluteString];
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

@end
