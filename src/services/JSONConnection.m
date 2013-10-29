//
//  JSONConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "JSONConnection.h"
#import "ServiceResult.h"
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
    
	NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	
	return [[ServiceResult alloc] initWithJSONString:resultString andUserData:userInfo];
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
    
    NSString *jsonString = [[NSString alloc] initWithData:asyncData encoding:NSUTF8StringEncoding];
	ServiceResult *jsonResult = [[ServiceResult alloc] initWithJSONString:jsonString andUserData:userInfo];
    connection = nil;
    asyncData  = nil;   
    
	if(handler && successSelector)
		[handler performSelector:successSelector withObject:jsonResult];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
   	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO; 
    
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
   	if(handler && failSelector)
		[handler performSelector:failSelector withObject:error]; 
    
	//[[AppServices sharedAppServices]  resetCurrentlyFetchingVars];
    [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
}

- (void)dealloc
{
    if(connection) [connection cancel];
}

@end
