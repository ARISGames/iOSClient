//
//  ARISConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ARISConnection.h"
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
    //PHIL TAKE THIS OUT ONCE WE CAN SPECIFY POST OR ONCE EVERYTHING IS POST
    if(([s isEqualToString:@"notebook"] && [m isEqualToString:@"addNoteFromJSON"]) ||
       ([s isEqualToString:@"players"]  && [m isEqualToString:@"uploadPlayerMediaFromJSON"]))
        req = [self createRequestURLWithHTTP:@"POST" fromService:s method:m arguments:args];
    else
    //OK STOP
        req = [self createRequestURLWithHTTP:@"GET" fromService:s method:m arguments:args];
    
    [self performAsyncURLRequest:req handler:h successSelector:ss failSelector:fs retryOnFail:r allowDuplicates:NO userInfo:dict];   
}

- (ARISServiceResult *) performSynchronousRequestWithService:(NSString *)s method:(NSString *)m arguments:(NSDictionary *)args userInfo:(NSDictionary *)dict
{
    return [self performSyncURLRequest:[self createRequestURLWithHTTP:@"GET" fromService:s method:m arguments:args] userInfo:dict];
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

- (NSURLRequest *) createRequestURLWithHTTP:(NSString *)httpMethod fromService:(NSString *)s method:(NSString *)method arguments:(NSDictionary *)args
{
    NSString *requestBaseString = [NSMutableString stringWithFormat:@"%@/json.php/%@.%@.%@/", server, kARISServerServicePackage, s, method];	 
    
    if([httpMethod isEqualToString:@"GET"])
        return [self GETRequestWithURLString:requestBaseString arguments:[self hackOrderedValuesOutOfDictionaryWithAlphabetizedKeys:args]];
    else
        return [self POSTRequestWithURLString:requestBaseString arguments:args]; 
}

- (NSURLRequest *) createRequestURLWithRequest:(RequestCD *)r
{
    if([r.method isEqualToString:@"GET"])
        return [NSURLRequest requestWithURL:[NSURL URLWithString:r.url]];
    else if([r.method isEqualToString:@"POST"])
    {
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:r.url]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]; 
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%d", [r.body length]] forHTTPHeaderField:@"Content-Length"]; 
        [urlRequest setHTTPBody:r.body];
        return urlRequest;
    } 
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
    NSString *sData = [jsonWriter stringWithObject:args];
    NSData *data = [sData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseString]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]; 
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"]; 
    [urlRequest setHTTPBody:data];
    
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
    
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
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

//Ok. So the goal of this class was a light, clean wrapper to pass arguments into an http connection with 
//the aris server. The generalized way to pass arguments is a dictionary (eg "the 'gameId' is '5252'"). 
//However, the aris server is currently set up in such a way that is requrires ordered arguments (eg a
//request for the games available to user 570 when hes at this lat, that lon, and wants to see games in 
// development looks something like this:
// http://domain.com/stuff/570/43.0129345/89.123451/1 )
// In other words, its completely illegible to a human, and very easy to mess up if you dont know the ordering
// or if it changes. So EVENTUALLY, aris will switch away from this. But for NOW, so long as you pass a dictionary
// with alphebetized keys (eg "auser_id,blatitude,clongitude,dshowGamesInDev"), this will parse out the values
// in the correct order.

//But hey, at least it's isolated to this one clearly labeled hack function... ;)
- (NSArray *) hackOrderedValuesOutOfDictionaryWithAlphabetizedKeys:(NSDictionary *)d
{
    NSArray *orderedKeys = [[d allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray *orderedValues = [[NSMutableArray alloc] initWithCapacity:[orderedKeys count]];
    for(int i = 0; i < [orderedKeys count]; i++)
        [orderedValues addObject:[d objectForKey:[orderedKeys objectAtIndex:i]]];
    return [NSArray arrayWithArray:orderedValues];
}

@end
