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
#import "ASIHTTPRequest.h"

@implementation JSONConnection

@synthesize jsonServerURL;
@synthesize serviceName;
@synthesize methodName;
@synthesize arguments;
@synthesize handler;
@synthesize userInfo;
@synthesize completeRequestURL;

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
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.completeRequestURL];
	[request setNumberOfTimesToRetryOnTimeout: 2];

	
	// Make synchronous request
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNewWaitingIndicator: @"Loading" displayProgressBar:NO];
	
	[request startSynchronous];
				  
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeNewWaitingIndicator];

	NSError *error = [request error];
	if (error) {
		NSLog(@"*** JSONConnection: performSynchronousRequest Error: %@ %@",
			  [error localizedDescription],
			  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
		[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];
		return nil;		
	}				  
	
		
	NSString *jsonString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[[JSONResult alloc] initWithJSONString:jsonString andUserData:self.userInfo] autorelease];
	[jsonString release];
	
	return jsonResult;
}

- (void) performAsynchronousRequestWithHandler: (SEL)ahandler{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.completeRequestURL];
    if (ahandler) self.handler = NSStringFromSelector(ahandler);
	[request setNumberOfTimesToRetryOnTimeout:2];
	[request setDelegate:self];
	[request setTimeOutSeconds:30];

	[self retain];
	
	[request startAsynchronousWithUpload:NO];
	
	//Set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"JSONConnection: requestFinished");
	
	//end the loading and spinner UI indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeNetworkAlert];	
	
	NSString *jsonString = [[NSString alloc] initWithData:[request responseData] 
												 encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[JSONResult alloc] initWithJSONString:jsonString andUserData:[self userInfo]];
	[jsonString release];
	
	SEL parser = NSSelectorFromString(self.handler);   

	if (parser) {
		[[AppServices sharedAppServices] performSelector:parser withObject:jsonResult];
	}
	
	[jsonResult release];
}

- (void)requestFailed:(ASIHTTPRequest *)request {	
	NSError *error = [request error];
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
    [super dealloc];
}
 
@end
