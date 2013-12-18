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
    MediaResult *mr = [[MediaResult alloc] init];
    mr.media = m;
    mr.delegate = d;
    
    [self loadMediaFromMR:mr];
}

- (void) loadMediaFromMR:(MediaResult *)mr
{
    if(!mr.media.remoteURL) { [self loadMetaDataForMR:mr]; return; }
    if(mr.media.data)       { [self mediaLoadedForMR:mr];  return; }

    if(!mr.media.localURL)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:mr.media.remoteURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        if(mr.connection) [mr.connection cancel];
        mr.data = [[NSMutableData alloc] initWithCapacity:2048];
        mr.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [dataConnections setObject:mr forKey:mr.connection.description]; 
    }
}

- (void) loadMetaDataForMR:(MediaResult *)mr
{
    for(int i = 0; i < [metaConnections count]; i++)
        if(((MediaResult *)[metaConnections objectAtIndex:i]).media.mediaId == mr.media.mediaId) return;
    [metaConnections addObject:mr]; 
    [[AppServices sharedAppServices] fetchMediaMeta:mr.media]; 
}

- (void) loadVideoFrameForMR:(MediaResult *)mr
{
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
    [mr cancelConnection];   
    mr.media.data = mr.data;
    
    NSString *mediaFolder   = [[[AppModel sharedAppModel] applicationDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",mr.media.gameId]]; 
    NSString *mediaFileName = [[[mr.media.remoteURL absoluteString] componentsSeparatedByString:@"/"] lastObject];
    NSURL *newFileURL = [NSURL URLWithString:[mediaFolder stringByAppendingPathComponent:mediaFileName]];
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:mediaFolder isDirectory:&isDir] && isDir)
        [[NSFileManager defaultManager] createDirectoryAtPath:mediaFolder withIntermediateDirectories:YES attributes:nil error:nil];
    [mr.media.data writeToFile:[newFileURL absoluteString] atomically:YES];
    mr.media.localURL = newFileURL;
    
    [self mediaLoadedForMR:mr];
}

- (void) mediaLoadedForMR:(MediaResult *)mr
{
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
