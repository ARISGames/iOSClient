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
#import "MediaModel.h"
#import "ARISDelegateHandle.h"

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
        metaConnections = [[NSMutableArray      alloc] initWithCapacity:10]; 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryLoadingAllMedia) name:@"ReceivedMediaList" object:nil]; 
    }
    return self;
}

- (void) loadMedia:(Media *)m delegateHandle:(ARISDelegateHandle *)dh
{
    if(!m) return;
    
    MediaResult *mr = [[MediaResult alloc] init];
    mr.media = m;
    mr.delegateHandle = dh;
    
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
    else
    {
        mr.media.data = [NSData dataWithContentsOfURL:mr.media.localURL];
        [self mediaLoadedForMR:mr]; 
    }
}

- (void) loadMetaDataForMR:(MediaResult *)mr
{
    for(int i = 0; i < [metaConnections count]; i++)
        if(((MediaResult *)[metaConnections objectAtIndex:i]).media.mediaId == mr.media.mediaId) return;
    [metaConnections addObject:mr]; 
    [[AppServices sharedAppServices] fetchMediaMeta:mr.media];
}

- (void) retryLoadingAllMedia
{
    MediaResult *mr;
    
    //do the ol' switcheroo so we wont get into an infinite loop of adding, removing, readding, etc...
    NSMutableArray *oldMetaConnections = metaConnections;
    metaConnections = [[NSMutableArray alloc] initWithCapacity:10];
    
    while([oldMetaConnections count] > 0)
    {
        mr = [oldMetaConnections objectAtIndex:0];
        mr.media = [[AppModel sharedAppModel] mediaForMediaId:mr.media.mediaId];
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
    mr.media.data = mr.data;
    [mr cancelConnection];//MUST do this only AFTER data has already been transferred to media

    NSString *newFileFolder   = [NSString stringWithFormat:@"%@/%d",[[AppModel sharedAppModel] applicationDocumentsDirectory],mr.media.gameId]; 
    if(![[NSFileManager defaultManager] fileExistsAtPath:newFileFolder isDirectory:nil])
        [[NSFileManager defaultManager] createDirectoryAtPath:newFileFolder withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *newFileFullPath = [NSString stringWithFormat:@"%@/%@",newFileFolder,[[[mr.media.remoteURL absoluteString] componentsSeparatedByString:@"/"] lastObject]];
    [mr.media.data writeToFile:newFileFullPath options:nil error:nil];
    mr.media.localURL = [NSURL URLWithString:[[NSString stringWithFormat:@"file://%@",newFileFullPath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [[AppModel sharedAppModel].mediaModel saveAlteredMedia:mr.media];//not as elegant as I'd like...
    
    [self mediaLoadedForMR:mr];
}

- (void) mediaLoadedForMR:(MediaResult *)mr
{
    //This is so ugly. See comments in ARISDelegateHandle.h for reasoning
    if(mr.delegateHandle.delegate && [[mr.delegateHandle.delegate class] conformsToProtocol:@protocol(ARISMediaLoaderDelegate)])
        [mr.delegateHandle.delegate mediaLoaded:mr.media];
    [mr.delegateHandle invalidate];
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
@synthesize delegateHandle;

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
