//
//  ARISConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISConnection.h"
#import "SBJson.h"
#import "ARISAlertHandler.h"

NSString *const kARISServerServicePackage = @"v1";

@interface ARISConnection() <NSURLConnectionDelegate>
{
    SBJsonParser *jsonParser;
    SBJsonWriter *jsonWriter;
    NSString *server;
    NSMutableDictionary *connections;
}
@end

@implementation ARISConnection

- (id) initWithServer:(NSString *)s
{
    if(self = [super init])
    {
        jsonParser = [[SBJsonParser alloc] init]; 
        jsonWriter = [[SBJsonWriter alloc] init];  
        server = s;
        connections = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    return self;
}

- (void) performAsynchronousRequestWithService:(NSString *)service method:(NSString *)m arguments:(NSDictionary *)args handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs userInfo:(NSDictionary *)dict
{
    [self performAsyncURLRequest:[self createRequestURLWithHTTP:@"GET" fromService:service method:m arguments:args] handler:h successSelector:ss failSelector:fs userInfo:dict]; 
}

- (ServiceResult *) performSynchronousRequestWithService:(NSString *)service method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict
{
    return [self performSyncURLRequest:[self createRequestURLWithHTTP:@"GET" fromService:service method:m arguments:args] userInfo:dict];
}

- (void) performAsyncURLRequest:(NSURLRequest *)rURL handler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs userInfo:(NSDictionary *)u
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;   
    NSLog(@"Req asynch URL: %@", rURL.URL);
    
    ServiceResult *r = [[ServiceResult alloc] init];
    r.asyncData = [[NSMutableData alloc] initWithCapacity:2048]; 
    r.userInfo = u;
    r.url = rURL.URL;
    r.connection = [[NSURLConnection alloc] initWithRequest:rURL delegate:self];
    r.handler = h;
    r.successSelector = ss;
    r.failSelector = fs; 
    r.start = [NSDate date];
	
    [connections setObject:r forKey:r.connection.description];
	[r.connection start];
}

- (ServiceResult *) performSyncURLRequest:(NSURLRequest *)rURL userInfo:(NSDictionary *)u
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
    NSLog(@"Req synchr URL: %@", rURL.URL); 
    
    ServiceResult *sr = [[ServiceResult alloc] init];
    sr.userInfo = u;
    sr.url = rURL.URL; 
    sr.start = [NSDate date];
    
    NSURLResponse *response = [[NSURLResponse alloc] init]; //why do we just throw these out?
    NSError *error = [[NSError alloc] init];                //why do we just throw these out?
    NSData* result = [NSURLConnection sendSynchronousRequest:rURL returningResponse:&response error:&error];
    
    sr.time = -1*[sr.start timeIntervalSinceNow];
	
	if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	if(!result)
    {
		NSLog(@"ARISConnection: performSynchronousRequest Error");
        [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
		return nil;
	}
    sr.data = [self parseJSONString:[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]];
    
    return sr;
}

- (NSURLRequest *) createRequestURLWithHTTP:(NSString *)httpMethod fromService:(NSString *)service method:(NSString *)method arguments:(NSDictionary *)args
{
    NSString *requestBaseString = [NSMutableString stringWithFormat:@"%@/json.php/%@.%@.%@/", server, kARISServerServicePackage, service, method];	 
    
    if([httpMethod isEqualToString:@"GET"])
        return [self GETRequestWithURLString:requestBaseString arguments:[args allValues]];
    else
        return [self POSTRequestWithURLString:requestBaseString arguments:args]; 
}

- (NSURLRequest *) GETRequestWithURLString:(NSString *)baseString arguments:(NSArray *)args
{    
    NSMutableString *requestParameters = [[NSMutableString alloc] init];
    NSString *argument;
    for(int i = 0; i < [args count]; i++)
    {
        argument = [args objectAtIndex:i];
        
        // replace special characters
        // double encode slashes (CFURLCreateStringByAddingPercentEscapes doesn't handle them well)
        // actions.php on server side decodes them once before sending these arguments on to their respective functions. 
        argument = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge_retained CFStringRef)argument, NULL, (CFStringRef)@"!*'();:@&=+$,?%#", kCFStringEncodingUTF8);
        argument = [argument stringByReplacingOccurrencesOfString:@"/" withString:@"%252F"]; 
        argument = [argument stringByReplacingOccurrencesOfString:@" " withString:@"%20"];  
        
        [requestParameters appendString:argument];
        [requestParameters appendString:@"/"];   
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseString, requestParameters]];
    return [NSURLRequest requestWithURL:url];  
}

- (NSURLRequest *) POSTRequestWithURLString:(NSString *)baseString arguments:(NSDictionary *)args
{
    NSStringEncoding enc = NSUTF8StringEncoding; 
    
    NSString *data = [jsonWriter stringWithObject:args];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json"                              forHTTPHeaderField:@"Accept"]; 
    [urlRequest setValue:@"application/json"                              forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"]; 
    [urlRequest setHTTPBody:data];
    
    return urlRequest;
}

- (void) connection:(NSURLConnection *)c didReceiveData:(NSData *)d
{
    ServiceResult *sr = [connections objectForKey:c.description];
    if(sr) [sr.asyncData appendData:d];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c
{
    ServiceResult *sr = [connections objectForKey:c.description];
    if(!sr) return;
    
    sr.time = -1*[sr.start timeIntervalSinceNow]; 
    NSLog(@"Fin asynch URL: %@\t(%f)", sr.url, sr.time); 
    
    sr.data = [self parseJSONString:[[NSString alloc] initWithData:sr.asyncData encoding:NSUTF8StringEncoding]];  
    [connections removeObjectForKey:c.description];
    if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    sr.connection = nil;
    sr.asyncData = nil;
    
	if(sr.handler && sr.successSelector)
		[sr.handler performSelector:sr.successSelector withObject:sr];
}

- (void) connection:(NSURLConnection *)c didFailWithError:(NSError *)error
{
    ServiceResult *sr = [connections objectForKey:c.description];
    if(!sr) return; 
    
    [connections removeObjectForKey:c.description];
    if([connections count] == 0) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
    
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
    NSLog(@"*** ARISConnection: requestFailed: %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
   	if(sr.handler && sr.failSelector)
		[sr.handler performSelector:sr.failSelector withObject:error]; 
    
    [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
}

- (NSObject *) parseJSONString:(NSString *)json
{
    NSDictionary *result = [jsonParser objectWithString:json];
    if(!result)
    {
        NSLog(@"JSONResult: Error parsing JSON String: %@.", json);
        [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",json]];  
        return nil;
    }
    
    int returnCode = [[result objectForKey:@"returnCode"] intValue];
    if(returnCode == 0)
        return [self parseOutColRowStructure:[result objectForKey:@"data"]];
    else
    {
        NSLog(@"JSONResult: Return code %d: %@",returnCode,[result objectForKey:@"returnCodeDescription"]);
        NSLog(@"NSNotification: LogoutRequested");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self userInfo:nil]];
        return nil;
    }
}

- (NSObject*) parseOutColRowStructure:(NSObject *)dataObject
{
	if(![dataObject isKindOfClass:[NSDictionary class]]) return dataObject;
	NSDictionary *dataDict = ((NSDictionary*) dataObject);
	
    //this literally does nothing... is it supposed to?
	if(!([dataDict objectForKey:@"columns"] && [dataDict objectForKey:@"rows"]))
    {
		NSObject *objectInDictionary;
		NSEnumerator *dictEnumer = [dataDict objectEnumerator];
		while(objectInDictionary = [dictEnumer nextObject])
			objectInDictionary = [self parseOutColRowStructure:objectInDictionary];
        
		return dataDict;
	}

	NSArray *columnsArray = [dataDict objectForKey:@"columns"];
	NSArray *rowsArray    = [dataDict objectForKey:@"rows"];
	NSEnumerator *rowsEnumerator    = [rowsArray objectEnumerator];
	NSMutableArray *dictionaryArray = [[NSMutableArray alloc] init];
	
	NSArray *row;
	while(row = [rowsEnumerator nextObject])
    {		
		NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
		for(int i = 0; i < [columnsArray count]; i++)
			[obj setObject:[row objectAtIndex:i] forKey:[columnsArray objectAtIndex:i]];
        
		[dictionaryArray addObject:obj];
	}
	return dictionaryArray;
}

@end

@implementation ServiceResult
@synthesize data;
@synthesize userInfo;
@synthesize asyncData; 
@synthesize url; 
@synthesize connection; 
@synthesize handler;
@synthesize successSelector; 
@synthesize failSelector;  
@synthesize start;  
@synthesize time;  

- (void) dealloc
{
    [self.connection cancel];
}
@end
