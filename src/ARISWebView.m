//
//  ARISWebView.m
//  ARIS
//
//  Created by Phil Dougherty on 7/30/13.
//
//

#import "ARISWebView.h"
#import "AppModel.h"
#import "MediaModel.h"
#import "AppServices.h"
#import "User.h"
#import "ARISAppDelegate.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ARISWebView() <UIWebViewDelegate>
{
    UIWebView *webView;
    NSMutableDictionary *audioPlayers;
    id<ARISWebViewDelegate> __unsafe_unretained delegate;
}

@end

@implementation ARISWebView

- (id) initWithFrame:(CGRect)frame delegate:(id<ARISWebViewDelegate>)d
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
        [self setDelegate:d];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (id) initWithDelegate:(id<ARISWebViewDelegate>)d
{
    if(self = [super init])
    {
        [self initialize];
        [self setDelegate:d];
    }
    return self;
}

- (void) initialize
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.delegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    [self addSubview:webView];
    audioPlayers = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void) setFrame:(CGRect)f
{
    [super setFrame:f];
    webView.frame = self.bounds;
}

- (void) setDelegate:(id<ARISWebViewDelegate>)d
{
    delegate = d;
}

- (void) loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [webView loadHTMLString:string baseURL:baseURL];
}

- (NSString *) stringByEvaluatingJavaScriptFromString:(NSString *)s;
{
    return [webView stringByEvaluatingJavaScriptFromString:s];
}

- (void) stopLoading
{
    [webView stopLoading];
}

- (UIScrollView *) scrollView
{
    return webView.scrollView;
}

- (void) setScalesPageToFit:(BOOL)s
{
    webView.scalesPageToFit = s;
}

- (void) setAllowsInlineMediaPlayback:(BOOL)a
{
    webView.allowsInlineMediaPlayback = a;
}

- (void) setMediaPlaybackRequiresUserAction:(BOOL)m
{
    webView.mediaPlaybackRequiresUserAction = m;
}

- (void) loadRequest:(NSURLRequest *)request
{
    _ARIS_LOG_(@"ARISWebView loadingRequest: %@",request);
    //[[NSURLCache sharedURLCache] removeAllCachedResponses];//Uncomment to clear cache
    [webView loadRequest:request];
}

- (void) loadRequest:(NSURLRequest *)request withAppendation:(NSString *)appendation
{
    NSString *url = [[request URL] absoluteString];

    if([url rangeOfString:@"?"].location == NSNotFound)
        url = [url stringByAppendingString:[NSString stringWithFormat:@"?game_id=%ld&user_id=%ld&aris=1%@",_MODEL_GAME_.game_id, _MODEL_PLAYER_.user_id, appendation]];
    else
        url = [url stringByAppendingString:[NSString stringWithFormat:@"&game_id=%ld&user_id=%ld&aris=1%@",_MODEL_GAME_.game_id, _MODEL_PLAYER_.user_id, appendation]];

    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (BOOL) webView:(UIWebView*)wv shouldStartLoadWithRequest:(NSURLRequest*)r navigationType:(UIWebViewNavigationType)nt
{
    NSString *url = [r URL].absoluteString;
    if([url isEqualToString:@"about:blank"]) return YES;
    if([self isARISRequest:r]) { [self handleARISRequest:r]; return NO; }

    if([delegate respondsToSelector:@selector(ARISWebView:shouldStartLoadWithRequest:navigationType:)])
        return [delegate ARISWebView:self shouldStartLoadWithRequest:r navigationType:nt];
    return NO;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    if([delegate respondsToSelector:@selector(ARISWebViewDidStartLoad:)])
        [delegate ARISWebViewDidStartLoad:self];
}

- (void) webViewDidFinishLoad:(UIWebView *)wv
{
    [self injectHTMLWithARISjs];
    if([delegate respondsToSelector:@selector(ARISWebViewDidFinishLoad:)])
        [delegate ARISWebViewDidFinishLoad:self];
}

- (void) injectHTMLWithARISjs
{
    NSString *arisjs = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"arisjs" ofType:@"js"] encoding:NSASCIIStringEncoding error:NULL];
    [webView stringByEvaluatingJavaScriptFromString:arisjs];
}

- (BOOL) isARISRequest:(NSURLRequest *)request
{
    return [[[[request URL] scheme] lowercaseString] isEqualToString:@"aris"];
}

- (void) handleARISRequest:(NSURLRequest *)request
{
    _ARIS_LOG_(@"ARISWebView   : %@",[[request URL] absoluteString]);
    [webView stringByEvaluatingJavaScriptFromString: @"ARIS.isCurrentlyCalling();"];

    NSString *mainCommand = [[request URL] host];
    NSArray *components   = [[request URL] pathComponents];

    if([mainCommand isEqual:@"cache"])
    {
        NSArray *items = _MODEL_ITEMS_.items;
        long item_id;
        long item_qty;
        for(long i = 0; i < items.count; i++)
        {
            item_id = ((Item *)items[i]).item_id;
            item_qty = [_MODEL_PLAYER_INSTANCES_ qtyOwnedForItem:item_id];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.cache.setItem(%ld,%ld);",item_id,item_qty]];
        }
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.cache.detach()"]];
    }
    else if([mainCommand isEqualToString:@"logout"])
    {
      [self clear];
      if(!_MODEL_PLAYER_) return; //can't log out if noone logged in
        
      [_MODEL_ logOut];
    }
    else if([mainCommand isEqualToString:@"exit"])
    {
        [self clear];

        NSString *type = @"";
        NSString *token = @"";
        if(components.count > 1) type  = [components objectAtIndex:1];
        if(components.count > 2) token = [components objectAtIndex:2];

        if(!_MODEL_GAME_) return; //game doesn't exist yet, can't "exit to"

        if([type isEqualToString:@"game"])
            [_MODEL_ leaveGame];
        else if([type isEqualToString:@"tab"])
            [_MODEL_DISPLAY_QUEUE_ enqueueTab:[_MODEL_TABS_ tabForType:token]];
        else if([type isEqualToString:@"scanner"])
        {
            [_MODEL_TABS_ tabForType:@"SCANNER"].info = token;
            [_MODEL_DISPLAY_QUEUE_ enqueueTab:[_MODEL_TABS_ tabForType:@"SCANNER"]];
        }
        else if([type isEqualToString:@"plaque"])
            [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_PLAQUES_ plaqueForId:[token intValue]]];
        else if([type isEqualToString:@"webpage"])
            [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_WEB_PAGES_ webPageForId:[token intValue]]];
        else if([type isEqualToString:@"item"])
            [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_ITEMS_ itemForId:[token intValue]]];
        else if([type isEqualToString:@"character"] || [type isEqualToString:@"dialog"] || [type isEqualToString:@"conversation"])
            [_MODEL_DISPLAY_QUEUE_ enqueueObject:[_MODEL_DIALOGS_ dialogForId:[token intValue]]];

        if([delegate respondsToSelector:@selector(ARISWebViewRequestsDismissal:)])
            [delegate ARISWebViewRequestsDismissal:self];
    }
    else if([mainCommand isEqualToString:@"refreshStuff"])
    {
        if([delegate respondsToSelector:@selector(ARISWebViewRequestsRefresh:)])
            [delegate ARISWebViewRequestsRefresh:self];
    }
    else if([mainCommand isEqualToString:@"vibrate"])
        [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
    else if([mainCommand isEqualToString:@"player"])
    {
        Media *playerMedia = [_MODEL_MEDIA_ mediaForId:_MODEL_PLAYER_.media_id];
        NSString *playerJSON = [NSString stringWithFormat:
                                @"{"
                                "\"user_id\":%ld,"
                                "\"user_name\":\"%@\","
                                "\"display_name\":\"%@\","
                                "\"photoURL\":\"%@\""
                                "}",
                                _MODEL_PLAYER_.user_id,
                                _MODEL_PLAYER_.user_name,
                                _MODEL_PLAYER_.display_name,
                                playerMedia.remoteURL];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didReceivePlayer(%@);",playerJSON]];
    }
    else if([mainCommand isEqualToString:@"inventory"])
    {
        if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"get"])
        {
            long item_id = [[components objectAtIndex:2] intValue];
            long qty = [_MODEL_PLAYER_INSTANCES_ qtyOwnedForItem:item_id];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%ld,%ld);",item_id,qty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"set"])
        {
            long item_id = [[components objectAtIndex:2] intValue];
            long qty = [[components objectAtIndex:3] intValue];
            long newQty = [_MODEL_PLAYER_INSTANCES_ setItemsForPlayer:item_id qtyToSet:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%ld,%ld);",item_id,newQty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"give"])
        {
            long item_id = [[components objectAtIndex:2] intValue];
            long qty = [[components objectAtIndex:3] intValue];
            long newQty = [_MODEL_PLAYER_INSTANCES_ giveItemToPlayer:item_id qtyToAdd:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%ld,%ld);",item_id,newQty]];
        }
        if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"take"])
        {
            long item_id = [[components objectAtIndex:2] intValue];
            long qty = [[components objectAtIndex:3] intValue];
            long newQty = [_MODEL_PLAYER_INSTANCES_ takeItemFromPlayer:item_id qtyToRemove:qty];
            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.didUpdateItemQty(%ld,%ld);",item_id,newQty]];
        }
    }
    else if([mainCommand isEqualToString:@"media"])
    {
        if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"prepare"])
            [self loadAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"play"])
            [self playAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 2 && [[components objectAtIndex:1] isEqualToString:@"stop"])
            [self stopAudioFromMediaId:[[components objectAtIndex:2] intValue]];
        else if(components.count > 3 && [[components objectAtIndex:1] isEqualToString:@"setVolume"])
            [self setMediaId:[[components objectAtIndex:2] intValue] volumeTo:[[components objectAtIndex:3] floatValue]];
    }
    else if([mainCommand isEqualToString:@"vibrate"])
    {
        [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] vibrate];
    }

    [webView stringByEvaluatingJavaScriptFromString:@"ARIS.isNotCurrentlyCalling();"];
}

- (void) loadAudioFromMediaId:(long)media_id
{
    Media* media = [_MODEL_MEDIA_ mediaForId:media_id];
    AVPlayer *player = [AVPlayer playerWithURL:media.localURL];
    [audioPlayers setObject:player forKey:[NSNumber numberWithLong:media_id]];
}

- (void) playAudioFromMediaId:(long)media_id
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithLong:media_id]];
    CMTime zero = CMTimeMakeWithSeconds(0, 600);
    [player seekToTime:zero];
    if(!player)
    {
        [self loadAudioFromMediaId:media_id];
        player = [audioPlayers objectForKey:[NSNumber numberWithLong:media_id]];
    }
    [player play];
}

- (void) stopAudioFromMediaId:(long)media_id
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithLong:media_id]];
    [player pause];
}

- (void) setMediaId:(long)media_id volumeTo:(float)volume
{
    AVPlayer *player = [audioPlayers objectForKey:[NSNumber numberWithLong:media_id]];

    NSArray *audioTracks = [player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }

    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];

    player.currentItem.audioMix = audioMix;

}

- (BOOL) hookWithParams:(NSString *)params
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.hook(%@);",params]];
    return false;
}

- (BOOL) tickWithParams:(NSString*)params
{
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ARIS.tick(%@);",params]];
    return false;
}

- (void) clear
{
    [webView stopLoading];
    webView.delegate = nil;
    [webView loadHTMLString:@"" baseURL:nil]; //clears out any pusher connections, etc...
    [audioPlayers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        AVPlayer *player = obj;
        [player pause];
    }];
}

- (void) dealloc
{
    [self clear];
}

@end
