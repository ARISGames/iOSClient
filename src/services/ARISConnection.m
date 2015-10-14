//
//  ARISConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISConnection.h"
#import "AppModel.h"
#import "SBJson.h"
#import "ARISServiceResult.h"
#import "RequestCD.h"
#import "ARISServiceGraveyard.h"
#import "ARISAlertHandler.h"
#import "AppModel.h"

//#define CONNECTION_DEBUG

NSString *const kARISServerServicePackage = @"v2";

@interface ARISConnection() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    SBJsonParser *jsonParser;
    SBJsonWriter *jsonWriter;
    ARISServiceGraveyard *graveyard;
    NSString *server;
    NSMutableDictionary *connections;
    NSMutableDictionary *requestDupMap;
    NSDictionary *auth;

    NSTimer *progressPoller;
}
@end

@implementation ARISConnection

- (id) initWithServer:(NSString *)s graveyard:(ARISServiceGraveyard *)g
{
    if(self = [super init])
    {
        jsonParser = [[SBJsonParser alloc] init];
        jsonWriter = [[SBJsonWriter alloc] init];
        server = s;
        graveyard = g;
        connections   = [[NSMutableDictionary alloc] initWithCapacity:20];
        requestDupMap = [[NSMutableDictionary alloc] initWithCapacity:20];

        progressPoller = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pollProgress) userInfo:nil repeats:YES];

        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_IN", self, @selector(setAuth), nil);
        _ARIS_NOTIF_LISTEN_(@"MODEL_LOGGED_OUT", self, @selector(unsetAuth), nil);
    }
    return self;
}

- (void) setServer:(NSString *)s { server = s; }
- (void) setAuth { auth = @{@"user_id":[NSNumber numberWithLong:_MODEL_PLAYER_.user_id],@"key":_MODEL_PLAYER_.read_write_key}; }
- (void) unsetAuth { auth = nil; }

- (void) performAsynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs retryOnFail:(BOOL)r humanDesc:(NSString *)desc userInfo:(NSDictionary *)dict
{
    [self performAsyncURLRequest:[self createRequestURLFromService:s method:m arguments:args] handler:h successSelector:ss failSelector:fs retryOnFail:r allowDuplicates:NO humanDesc:desc userInfo:dict];
}

- (ARISServiceResult *) performSynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict
{
    return [self performSyncURLRequest:[self createRequestURLFromService:s method:m arguments:args] userInfo:dict];
}

- (void) performRevivalWithRequest:(RequestCD *)r
{
    [self performAsyncURLRequest:[self createRequestURLWithRequest:r] handler:nil successSelector:nil failSelector:nil retryOnFail:YES allowDuplicates:NO humanDesc:@"Retrying failed request..." userInfo:nil];
}

- (NSString *) hashFromURLReq:(NSURLRequest *)rURL
{
    //used to store in dict
    return [NSString stringWithFormat:@"%@%@",[rURL.URL absoluteString],[[NSString alloc] initWithData:rURL.HTTPBody encoding:NSUTF8StringEncoding]];
}
- (void) performAsyncURLRequest:(NSURLRequest *)rURL handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs retryOnFail:(BOOL)r allowDuplicates:(BOOL)d humanDesc:(NSString *)desc userInfo:(NSDictionary *)u
{
    if(!d)
    {
        if([requestDupMap objectForKey:[self hashFromURLReq:rURL]])
        {
            _ARIS_LOG_(@"Dup req abort : %@",rURL.URL.absoluteString);
            #ifdef CONNECTION_DEBUG
            _ARIS_LOG_(@"Dup req data  : %@", [[NSString alloc] initWithData:rURL.HTTPBody encoding:NSUTF8StringEncoding]);
            #endif
            return;
        }
        else [requestDupMap setObject:[rURL.URL absoluteString] forKey:[self hashFromURLReq:rURL]];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _ARIS_LOG_(@"Req asynch URL: %@", rURL.URL);
    #ifdef CONNECTION_DEBUG
    _ARIS_LOG_(@"Req async data: %@", [[NSString alloc] initWithData:rURL.HTTPBody encoding:NSUTF8StringEncoding]);
    #endif

    ARISServiceResult *rs = [[ARISServiceResult alloc] init];
    rs.humanDescription = desc;
    rs.asyncData = [[NSMutableData alloc] initWithCapacity:2048];
    rs.userInfo = u;
    rs.urlRequest = rURL;
    rs.connection = [[NSURLConnection alloc] initWithRequest:rURL delegate:self];
    rs.handler = h;
    rs.successSelector = ss;
    rs.failSelector = fs;
    rs.retryOnFail = r;
    rs.start = [NSDate date];

    [connections setObject:rs forKey:rs.connection.description];
    [rs.connection start];
}

- (ARISServiceResult *) performSyncURLRequest:(NSURLRequest *)rURL userInfo:(NSDictionary *)u
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _ARIS_LOG_(@"Req synchr URL: %@", rURL.URL);

    ARISServiceResult *sr = [[ARISServiceResult alloc] init];
    sr.userInfo = u;
    sr.urlRequest = rURL;
    sr.start = [NSDate date];

    NSURLResponse *response = [[NSURLResponse alloc] init]; //why do we just throw these out?
    NSError *error = [[NSError alloc] init];                //why do we just throw these out?
    NSData* result = [NSURLConnection sendSynchronousRequest:rURL returningResponse:&response error:&error];

    sr.time = -1*[sr.start timeIntervalSinceNow];

    if(connections.count == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if(!result)
    {
      _ARIS_LOG_(@"ARISConnection: performSynchronousRequest Error");
      ///* silently handle errors */[[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
      return nil;
    }
    sr.resultData = [self parseJSONString:[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]];

    return sr;
}

- (NSURLRequest *) createRequestURLFromService:(NSString *)s method:(NSString *)method arguments:(NSDictionary *)args
{
    NSString *requestBaseString = [NSMutableString stringWithFormat:@"%@/json.php/%@.%@.%@/", server, kARISServerServicePackage, s, method];

    if(auth)
    {
        //if this isn't the most awkward shuffle of mutability...
        NSMutableDictionary *margs = [NSMutableDictionary dictionaryWithDictionary:args];
        margs[@"auth"] = auth; //inject authentication for all requests
        args = margs;
    }

    NSString *sData = [jsonWriter stringWithObject:args];
    NSData *data = [sData dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestBaseString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%ld", [data length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:data];

    return urlRequest;
}

- (NSURLRequest *) createRequestURLWithRequest:(RequestCD *)r
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:r.url]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%ld", [r.body length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:r.body];
    return urlRequest;
}

- (void) connection:(NSURLConnection *)c didReceiveData:(NSData *)d
{
    ARISServiceResult *sr = [connections objectForKey:c.description];
    if(sr) [sr.asyncData appendData:d];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c
{
    ARISServiceResult *sr = [connections objectForKey:c.description];
    if(!sr) return;

    [requestDupMap removeObjectForKey:[self hashFromURLReq:sr.urlRequest]];

    sr.time = -1*[sr.start timeIntervalSinceNow];
    _ARIS_LOG_(@"Fin asynch URL: %@\t(%f)", sr.urlRequest.URL, sr.time);
    #ifdef CONNECTION_DEBUG
    _ARIS_LOG_(@"Fin async data: %@", [[NSString alloc] initWithData:sr.asyncData encoding:NSUTF8StringEncoding]);
    #endif

    sr.resultData = [self parseJSONString:[[NSString alloc] initWithData:sr.asyncData encoding:NSUTF8StringEncoding]];
    [connections removeObjectForKey:c.description];
    if(connections.count == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    sr.connection = nil;
    sr.asyncData = nil;

    if(sr.handler && sr.successSelector)
        [sr.handler performSelector:sr.successSelector withObject:sr];
}

- (void) connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
    ARISServiceResult *sr = [connections objectForKey:c.description];
    if(!sr) return;

    [requestDupMap removeObjectForKey:[self hashFromURLReq:sr.urlRequest]];

    sr.time = -1*[sr.start timeIntervalSinceNow];
    _ARIS_LOG_(@"Fail async URL: %@\t(%f)", sr.urlRequest.URL, sr.time);
    _ARIS_LOG_(@"Fail async URL: Info: %@ , %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

    [connections removeObjectForKey:c.description];
    if(connections.count == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if(sr.retryOnFail)
        [graveyard addServiceResult:sr];
    if(sr.handler && sr.failSelector)
        [sr.handler performSelector:sr.failSelector withObject:error];

    ///* silently handle errors */ [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
}

- (NSURLRequest *) connection:(NSURLConnection *)c willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if(response)
    {
        _ARIS_LOG_(@"%@",response);
    }
    return request;
}

- (void) connection:(NSURLConnection *)c didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    ARISServiceResult *sr = [connections objectForKey:c.description];
    sr.progress = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
}

- (NSObject *) parseJSONString:(NSString *)json
{
    NSDictionary *result = [jsonParser objectWithString:json];
    if(!result)
    {
        _ARIS_LOG_(@"JSONResult: Error parsing JSON String: %@.", json);
        /* no need to show error to user
        [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",json]];
         */
        return nil;
    }

    long returnCode = [[result objectForKey:@"returnCode"] intValue];
    if(returnCode == 0) return [result objectForKey:@"data"];
    else
    {
        _ARIS_LOG_(@"JSONResult: Return code %ld: %@",returnCode,[result objectForKey:@"returnCodeDescription"]);
        [_MODEL_ logOut];
        return nil;
    }
}

- (void) pollProgress
{
  ARISServiceResult *r;
  NSArray *connarr = [connections allValues];
  NSMutableArray *laggers = [[NSMutableArray alloc] init];
  for(int i = 0; i < connarr.count; i++)
  {
    r = connarr[i];
    if([r.start timeIntervalSinceNow] < -2)
      [laggers addObject:r];
  }
  if(connarr.count)
    _ARIS_NOTIF_SEND_(@"CONNECTION_LAG",nil,@{@"laggers":laggers});
}

- (void) dealloc
{
  [progressPoller invalidate];
  _ARIS_NOTIF_IGNORE_ALL_(self);
}

@end
