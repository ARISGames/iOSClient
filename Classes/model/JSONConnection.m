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
#import "ARISURLConnection.h"

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
		[requestParameters appendString:argument];
	}
	
	//Convert into a NSURLRequest
	self.completeRequestURL = [server URLByAppendingPathComponent:requestParameters];
	NSLog(@"JSONConnection: complete URL is : %@", self.completeRequestURL);

	return self;
}

- (JSONResult*) performSynchronousRequest{
	
	NSURLRequest *request = [NSURLRequest requestWithURL:self.completeRequestURL];
    
    // Make synchronous request
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNewWaitingIndicator: @"Loading" displayProgressBar:NO];
    
    NSURLResponse *response = [[NSURLResponse alloc]init];
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeNewWaitingIndicator];

	if (!resultData) {
		NSLog(@"JSONConnection: performSynchronousRequest Error");
		[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];
		return nil;		
	}				
    
    //[response release];
    [error release];
    
	NSString *resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[[JSONResult alloc] initWithJSONString:resultString andUserData:self.userInfo] autorelease];
	[resultString release];
	
	return jsonResult;
}

- (void) performAsynchronousRequestWithHandler: (SEL)aHandler{    
    //save the handler
    if (aHandler) self.handler = NSStringFromSelector(aHandler);
	
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
        self.asyncData = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [self.asyncData appendData:incrementalData];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //end the UI indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeNetworkAlert];	
    
    //throw out the connection
    self.connection=nil;
    
    //Convert the data into a string
    NSString *jsonString = [[NSString alloc] initWithData:self.asyncData 
												 encoding:NSUTF8StringEncoding];
    
    //throw out the data
    self.asyncData=nil;
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[JSONResult alloc] initWithJSONString:jsonString andUserData:[self userInfo]];
	[jsonString release];
	
	SEL parser = NSSelectorFromString(self.handler);   
    
	if (parser) {
		[[AppServices sharedAppServices] performSelector:parser withObject:jsonResult];
	}
	
	[jsonResult release];

}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ConnectionLost" object:nil]];
	// inform the user
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] resetCurrentlyFetchingVars];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeNewWaitingIndicator];	
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];	
	
}



- (void)dealloc {
	[jsonServerURL release];
	[serviceName release];
	[methodName release];
	[arguments release];
	[asyncData release];
    [completeRequestURL release];
    if (connection) [connection cancel];
    
    [super dealloc];
}
 
@end
