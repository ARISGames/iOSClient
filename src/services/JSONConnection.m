//
//  JSONConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "JSONConnection.h"
#import "SBJson.h"
#import "ARISAlertHandler.h"

NSString *const kARISServerServicePackage = @"v1";

@interface JSONConnection() <NSURLConnectionDelegate>
{
    NSMutableDictionary *userInfo; 
   	NSMutableData *asyncData; 
   	NSURL *requestURL;
    NSURLConnection *connection; 
    id handler;
    SEL successSelector; 
    SEL failSelector;  
    SBJsonParser *jsonParser;
}
@end

@implementation JSONConnection

- (JSONConnection*) initWithServer:(NSURL *)server
                    andServiceName:(NSString *)service 
                     andMethodName:(NSString *)method
                      andArguments:(NSArray *)args
                       andUserInfo:(NSMutableDictionary *)auserInfo
{
    if(self = [super init])
    {
        jsonParser = [[SBJsonParser alloc] init];
        userInfo = auserInfo;
    
        NSMutableString *requestParameters = [NSMutableString stringWithFormat:@"json.php/%@.%@.%@", kARISServerServicePackage, service, method];	
    
        NSEnumerator *argumentsEnumerator = [args objectEnumerator];
        NSString *argument;
        while(argument = [argumentsEnumerator nextObject])
        {
            [requestParameters appendString:@"/"];  
        
            // replace special characters
            // double encode slashes (CFURLCreateStringByAddingPercentEscapes doesn't handle them well)
            // actions.php on server side decodes them once before sending these arguments on to their respective functions. 
            argument = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(__bridge_retained CFStringRef)argument,NULL,(CFStringRef)@"!*'();:@&=+$,?%#",kCFStringEncodingUTF8 );
            argument = [argument stringByReplacingOccurrencesOfString:@"/" withString:@"%252F"]; 
        
            [requestParameters appendString:argument];
        }
        NSMutableString *serverString = [NSMutableString stringWithString:[server absoluteString]];
        [serverString appendString:@"/"];
        [serverString appendString:requestParameters];
        requestURL = [NSURL URLWithString:[serverString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    }
    
	return self;
}

- (ServiceResult *) performSynchronousRequest
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
    
    NSLog(@"Req synchr URL: %@", requestURL); 
	NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    NSURLResponse *response = [[NSURLResponse alloc] init]; //why do we just throw these out?
    NSError *error = [[NSError alloc] init];                //why do we just throw these out?
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	if(!resultData)
    {
		NSLog(@"JSONConnection: performSynchronousRequest Error");
        [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
		return nil;
	}
    
    return [self parseJSONResult:[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]];
}

- (void) performAsynchronousRequestWithHandler:(id)h successSelector:(SEL)ss failSelector:(SEL)fs
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;   
    
    NSLog(@"Req asynch URL: %@", requestURL);  
    
    handler = h;
    successSelector = ss;
    failSelector = fs; 
	
    connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:requestURL] delegate:self];
	[connection start];
}

- (void) connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    if(asyncData == nil) asyncData = [[NSMutableData alloc] initWithCapacity:2048];
    [asyncData appendData:incrementalData];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)theConnection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;  
    
    ServiceResult *result = [self parseJSONResult:[[NSString alloc] initWithData:asyncData encoding:NSUTF8StringEncoding]]; 
    connection = nil;
    asyncData  = nil;   
    
	if(handler && successSelector)
		[handler performSelector:successSelector withObject:result];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
    
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
   	if(handler && failSelector)
		[handler performSelector:failSelector withObject:error]; 
    
    [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
}

- (ServiceResult*) parseJSONResult:(NSString *)json
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
        return [[ServiceResult alloc] initWithData:[self parseOutColRowStructure:[result objectForKey:@"data"]] userInfo:userInfo];
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

- (void) dealloc
{
    if(connection) [connection cancel];
}

@end

@implementation ServiceResult
@synthesize data;
@synthesize userInfo;

- (id) initWithData:(NSObject *)d userInfo:(NSDictionary *)u
{
    if(self = [super init])
    {
        self.data = d;
        self.userInfo = u; 
    }
    return self;
}

@end
