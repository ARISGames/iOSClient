//
//  JSONConnection.m
//  ARIS
//
//  Created by David J Gagnon on 8/28/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "JSONConnection.h"
#import "AppModel.h"
#import "ARISAppDelegate.h"
#import "AppServices.h"
#import "ServiceResult.h"
#import "ARISURLConnection.h"
#import "ARISAlertHandler.h"

@implementation JSONConnection

@synthesize jsonServerURL;
@synthesize serviceName;
@synthesize methodName;
@synthesize arguments;
@synthesize handler;
@synthesize userInfo;
@synthesize completeRequestURL;
@synthesize asyncData;
@synthesize connection;

- (JSONConnection*)initWithServer:(NSURL *)server
                   andServiceName:(NSString *)service 
                    andMethodName:(NSString *)method
                     andArguments:(NSArray *)args
                      andUserInfo:(NSMutableDictionary *)auserInfo{
	
	self.jsonServerURL = server;
	self.serviceName = service;
	self.methodName = method;	
	self.arguments = args;
	self.userInfo = auserInfo;

	//Compute the Arguments 
	NSMutableString *requestParameters = [NSMutableString stringWithFormat:@"json.php/%@.%@.%@", kARISServerServicePackage, self.serviceName, self.methodName];	
	NSEnumerator *argumentsEnumerator = [self.arguments objectEnumerator];
	NSString *argument;
	while (argument = [argumentsEnumerator nextObject]) {
        
        
		[requestParameters appendString:@"/"];
        // replace special characters
        argument = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                                                                         (__bridge_retained CFStringRef)argument,
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'();:@&=+$,?%#",
                                                                                         kCFStringEncodingUTF8 );
        
        // double encode slashes (CFURLCreateStringByAddingPercentEscapes doesn't handle them well)
        // actions.php on server side decodes them once before sending these arguments on to their respective functions.
        argument = [argument stringByReplacingOccurrencesOfString:@"/" withString:@"%252F"]; 
        [requestParameters appendString:argument];
	}
    NSMutableString *serverString = [NSMutableString stringWithString:[server absoluteString]];
    [serverString appendString:@"/"];
    [serverString appendString:requestParameters];
    NSURL *url = [NSURL URLWithString:[serverString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];

    self.completeRequestURL = url;
    
	NSLog(@"Requesting URL: %@", self.completeRequestURL);

	return self;
}

- (ServiceResult *) performSynchronousRequest
{	
	NSURLRequest *request = [NSURLRequest requestWithURL:self.completeRequestURL];
    
    // Make synchronous request
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ARISAlertHandler sharedAlertHandler] showWaitingIndicator:NSLocalizedString(@"LoadingKey",@"")];
    
    NSURLResponse *response = [[NSURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];

	if(!resultData)
    {
		NSLog(@"JSONConnection: performSynchronousRequest Error");
        [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
		return nil;
	}
    
    //[response release];
    
	NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	ServiceResult *jsonResult = [[ServiceResult alloc] initWithJSONString:resultString andUserData:self.userInfo];
	
	return jsonResult;
}

- (void) performAsynchronousRequestWithHandler: (SEL)aHandler{    
    //save the handler
    if (aHandler) self.handler = aHandler;
    else self.handler = nil;
	
    //Make sure we were inited correctly
    if (!completeRequestURL) return;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:completeRequestURL];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[self.connection start];
	
	//Set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (self.asyncData == nil) {
        NSMutableData *asyncDataAlloc = [[NSMutableData alloc] initWithCapacity:2048];
        self.asyncData = asyncDataAlloc;
    }
    [self.asyncData appendData:incrementalData];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //end the UI indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[ARISAlertHandler sharedAlertHandler] removeNetworkAlert];
    
    //throw out the connection
    self.connection=nil;
    
    //Convert the data into a string
    NSString *jsonString = [[NSString alloc] initWithData:self.asyncData 
												 encoding:NSUTF8StringEncoding];
    
    //throw out the data
    self.asyncData=nil;
	
	//Get the JSONResult here
	ServiceResult *jsonResult = [[ServiceResult alloc] initWithJSONString:jsonString andUserData:[self userInfo]];
    
	if (self.handler != nil)
		[[AppServices sharedAppServices] performSelector:self.handler withObject:jsonResult];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"NSNotification: ConnectionLost");
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
	// inform the user
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[[AppServices sharedAppServices]  resetCurrentlyFetchingVars];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[ARISAlertHandler sharedAlertHandler] removeWaitingIndicator];
    [[ARISAlertHandler sharedAlertHandler] showNetworkAlert];
}



- (void)dealloc {
    if (connection) [connection cancel];
    
}
 
@end
