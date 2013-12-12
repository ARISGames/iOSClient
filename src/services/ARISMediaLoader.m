//
//  ARISMediaLoader.m
//  ARIS
//
//  Created by Phil Dougherty on 11/21/13.
//
//

#import "ARISMediaLoader.h"
#import "AppServices.h"
#import "AppModel.h"

@interface ARISMediaLoader()
{
    //ARISMoviePlayerViewController *movieViewController; //Only required to get thumbnail for video
    NSMutableDictionary *dataConnections; 
    NSMutableArray *metaConnections;
}
@end

@implementation ARISMediaLoader

- (id) init
{
    if(self = [super init])
    {
        dataConnections = [[NSMutableDictionary alloc] initWithCapacity:10];
        metaConnections = [[NSMutableArray alloc] initWithCapacity:10]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryLoadingAllMedia) name:@"ReceivedMediaList" object:nil]; 
    }
    return self;
}

- (void) loadMedia:(Media *)m delegate:(id<ARISMediaLoaderDelegate>)d
{
    //hack
    m.url = [m.url stringByReplacingOccurrencesOfString:@"gamedata//" withString:@"gamedata/player/"]; 
    
    MediaResult *mr = [[MediaResult alloc] init];
    mr.media = m;
    mr.delegate = d;
    
    [self loadMediaFromMR:mr];
}

- (void) loadMediaFromMR:(MediaResult *)mr
{
    if     (!mr.media.url || !mr.media.type)          [self loadMetaDataForMR:mr];
    else if([mr.media.type isEqualToString:@"PHOTO"]) [self loadPhotoForMR:mr];
    else if([mr.media.type isEqualToString:@"VIDEO"]) [self loadVideoFrameForMR:mr];
    else if([mr.media.type isEqualToString:@"AUDIO"]) return;  
}

- (void) loadMetaDataForMR:(MediaResult *)mr
{
    for(int i = 0; i < [metaConnections count]; i++)
        if(((MediaResult *)[metaConnections objectAtIndex:i]).media.uid == mr.media.uid) return;
    [metaConnections addObject:mr]; 
    [[AppServices sharedAppServices] fetchMediaMeta:mr.media]; 
}

- (void) loadPhotoForMR:(MediaResult *)mr
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mr.media.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    if(mr.connection) [mr.connection cancel];
    mr.data = [[NSMutableData alloc] initWithCapacity:2048];
    mr.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [dataConnections setObject:mr forKey:mr.connection.description];
}

- (void) loadVideoFrameForMR:(MediaResult *)mr
{
    /* 
    NSNumber *thumbTime = [NSNumber numberWithFloat:1.0f];
    NSArray *timeArray = [NSArray arrayWithObject:thumbTime];
    
    movieViewController = [[ARISMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:m.url]];
    movieViewController.moviePlayer.shouldAutoplay = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbDidFinish:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:movieViewController.moviePlayer];
    [movieViewController.moviePlayer requestThumbnailImagesAtTimes:timeArray timeOption:MPMovieTimeOptionNearestKeyFrame];
     */
}

/*
- (void) movieThumbDidFinish:(NSNotification*)n
{
    UIImage *i = [n.userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    media.image = UIImageJPEGRepresentation(i, 1.0);
}
 */ 
 
- (void) retryLoadingAllMedia
{
    MediaResult *mr;
    
    //do the ol' switcheroo so we wont get into an infinite loop of adding, removing, readding, etc...
    NSMutableArray *oldMetaConnections = metaConnections;
    metaConnections = [[NSMutableArray alloc] initWithCapacity:10];
    
    while([oldMetaConnections count] > 0)
    {
        mr = [oldMetaConnections objectAtIndex:0];
        mr.media = [[AppModel sharedAppModel] mediaForMediaId:[mr.media.uid intValue] ofType:mr.media.type];
        [oldMetaConnections removeObjectAtIndex:0];
        [self loadMediaFromMR:mr];
    }
}

- (void) connection:(NSURLConnection *)c didReceiveData:(NSData *)d
{
    MediaResult *mr = [dataConnections objectForKey:c.description];
    if(!mr) return;
    [mr.data appendData:d];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c
{
    MediaResult *mr = [dataConnections objectForKey:c.description]; 
    if(!mr) return; 
    [dataConnections removeObjectForKey:c.description]; 
    
    mr.media.image = mr.data;
    [mr cancelConnection];
    if(mr.delegate) [mr.delegate mediaLoaded:mr.media];
    mr.delegate = nil;
}

- (void) dealloc
{
    NSArray *objects = [dataConnections allValues];
    for(int i = 0; i < [objects count]; i++)
        [[objects objectAtIndex:i] cancelConnection];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation MediaResult
@synthesize media;
@synthesize data;
@synthesize url;
@synthesize connection;
@synthesize start;
@synthesize time;
@synthesize delegate;

- (void) cancelConnection
{
    [self.connection cancel];
    self.connection = nil;
    self.data = nil;
}

- (void) dealloc
{
    [self cancelConnection];
}

@end
