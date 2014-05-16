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

NSString *const kARISServerServicePackage = @"v1";

@interface ARISConnection() <NSURLConnectionDelegate>
{
    SBJsonParser *jsonParser;
    SBJsonWriter *jsonWriter;
    ARISServiceGraveyard *graveyard;
    NSString *server;
    NSMutableDictionary *connections;
    NSMutableDictionary *requestDupMap; 
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
    }
    return self;
}

- (void) performAsynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs retryOnFail:(BOOL)r userInfo:(NSDictionary *)dict
{
    NSURLRequest *req;
    req = [self createRequestURLfromService:s method:m arguments:args];
    
    [self performAsyncURLRequest:req handler:h successSelector:ss failSelector:fs retryOnFail:r allowDuplicates:NO userInfo:dict];   
}

- (ARISServiceResult *) performSynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict
{
    return [self performSyncURLRequest:[self createRequestURLfromService:s method:m arguments:args] userInfo:dict];
}

- (void) performRevivalWithRequest:(RequestCD *)r
{
    [self performAsyncURLRequest:[self createRequestURLWithRequest:r] handler:nil successSelector:nil failSelector:nil retryOnFail:YES allowDuplicates:NO userInfo:nil];   
}

- (void) performAsyncURLRequest:(NSURLRequest *)rURL handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs retryOnFail:(BOOL)r allowDuplicates:(BOOL)d userInfo:(NSDictionary *)u
{
    if(!d)
    {
        if([requestDupMap objectForKey:[rURL.URL absoluteString]])
        {
            NSLog(@"Dup req abort : %@",rURL.URL.absoluteString);
            return;
        }
        else [requestDupMap setObject:[rURL.URL absoluteString] forKey:[rURL.URL absoluteString]];
    } 
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;   
    NSLog(@"Req asynch URL: %@", rURL.URL);
    
    ARISServiceResult *rs = [[ARISServiceResult alloc] init];
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
    NSLog(@"Req synchr URL: %@", rURL.URL); 
    
    ARISServiceResult *sr = [[ARISServiceResult alloc] init];
    sr.userInfo = u;
    sr.urlRequest = rURL; 
    sr.start = [NSDate date];
    
    NSURLResponse *response = [[NSURLResponse alloc] init]; //why do we just throw these out?
    NSError *error = [[NSError alloc] init];                //why do we just throw these out?
    NSData* result = [NSURLConnection sendSynchronousRequest:rURL returningResponse:&response error:&error];
    
    sr.time = -1*[sr.start timeIntervalSinceNow];
	
	if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	if(!result)
    {
		NSLog(@"ARISConnection: performSynchronousRequest Error");
        ///* silently handle errors */[[ARISAlertHandler sharedAlertHandler] showNetworkAlert]; 
		return nil;
	}
    sr.resultData = [self parseJSONString:[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]];
    
    return sr;
}

- (NSURLRequest *) createRequestURLfromService:(NSString *)s method:(NSString *)method arguments:(NSDictionary *)args
{
    NSString *requestBaseString = [NSMutableString stringWithFormat:@"%@/json.php/%@.%@.%@/", server, kARISServerServicePackage, s, method];	 
    
    NSString *sData = [jsonWriter stringWithObject:args];
    NSData *data = [sData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestBaseString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]; 
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"]; 
    [urlRequest setHTTPBody:data];
    
    return urlRequest; 
}

- (NSURLRequest *) createRequestURLWithRequest:(RequestCD *)r
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:r.url]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]; 
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [r.body length]] forHTTPHeaderField:@"Content-Length"]; 
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
    
    [requestDupMap removeObjectForKey:[sr.urlRequest.URL absoluteString]];
    
    sr.time = -1*[sr.start timeIntervalSinceNow]; 
    NSLog(@"Fin asynch URL: %@\t(%f)", sr.urlRequest.URL, sr.time); 
    
    sr.resultData = [self parseJSONString:[[NSString alloc] initWithData:sr.asyncData encoding:NSUTF8StringEncoding]];  
    [connections removeObjectForKey:c.description];
    if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    sr.connection = nil;
    sr.asyncData = nil;
    
	if(sr.handler && sr.successSelector)
		[sr.handler performSelector:sr.successSelector withObject:sr];
}

- (void) connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
    ARISServiceResult *sr = [connections objectForKey:c.description];
    if(!sr) return;
    
    [connections removeObjectForKey:c.description];
    if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	_ARIS_NOTIF_SEND_(@"ConnectionLost",nil,nil);
    NSLog(@"*** ARISConnection: requestFailed: %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
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
        NSLog(@"%@",response);
    }
    return request;
}

- (NSObject *) parseJSONString:(NSString *)json
{
    NSDictionary *result = [jsonParser objectWithString:json];
    if(!result)
    {
        NSLog(@"JSONResult: Error parsing JSON String: %@.", json);
        /* no need to show error to user
        [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",json]];
         */
        return nil;
    }
    
    int returnCode = [[result objectForKey:@"returnCode"] intValue];
    if(returnCode == 0) return [result objectForKey:@"data"];
    else
    {
        NSLog(@"JSONResult: Return code %d: %@",returnCode,[result objectForKey:@"returnCodeDescription"]);
        [_MODEL_ logOut];
        return nil;
    }
}

@end
