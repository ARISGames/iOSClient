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
#import "ARISURLConnection.h"
#import "ASIHTTPRequest.h"

@implementation JSONConnection

@synthesize jsonServerBaseURL;
@synthesize serviceName;
@synthesize methodName;
@synthesize arguments;

- (JSONConnection*)initWithArisJSONServer:(NSString *)server
			   andServiceName:(NSString *)service 
				andMethodName:(NSString *)method
				 andArguments:(NSArray *)args{
	
	self.jsonServerBaseURL = server;
	self.serviceName = service;
	self.methodName = method;	
	self.arguments = args;	

	return self;
}

- (JSONResult*) performSynchronousRequest{
	//Build the base URL string
	NSMutableString *requestString = [[NSMutableString alloc] initWithFormat:@"%@.%@.%@", 
							   self.jsonServerBaseURL, self.serviceName, self.methodName];
	
	//Add the Arguments
	NSEnumerator *argumentsEnumerator = [self.arguments objectEnumerator];
	NSString *argument;
	while (argument = [argumentsEnumerator nextObject]) {
		[requestString appendString:@"/"];
		[requestString appendString:argument];
	}

	NSLog(@"JSONConnection: JSON URL for sync request is : %@", requestString);
	
	//Convert into a NSURLRequest
	NSURL *url = [NSURL URLWithString:requestString];
	[requestString release];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
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
	JSONResult *jsonResult = [[[JSONResult alloc] initWithJSONString:jsonString] autorelease];
	[jsonString release];
	
	return jsonResult;
}

- (void) performAsynchronousRequestWithParser: (SEL)parser{
	//Build the base URL string
	NSMutableString *requestString = [[NSMutableString alloc] initWithFormat:@"%@.%@.%@", 
									  self.jsonServerBaseURL, self.serviceName, self.methodName];
	
	//Add the Arguments
	NSEnumerator *argumentsEnumerator = [self.arguments objectEnumerator];
	NSString *argument;
	while (argument = [argumentsEnumerator nextObject]) {
		[requestString appendString:@"/"];
		[requestString appendString:argument];
	}
	
	NSLog(@"JSONConnection: Begining Async request.  %@", requestString);
	
	//Convert into a NSURLRequest
	NSURL *requestURL = [NSURL URLWithString:requestString];
	[requestString release];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:requestURL];
	[request setNumberOfTimesToRetryOnTimeout:2];
	[request setDelegate:self];
	[request setTimeOutSeconds:60];


	//Store the parser in the request
	if (parser) [request setUserInfo:[NSDictionary dictionaryWithObject:NSStringFromSelector(parser) forKey:@"parser"]]; 
	[self retain];
	
	[request startAsynchronous];
	
	
	//Set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}


- (void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"JSONConnection: requestFinished");
	
	//end the loading and spinner UI indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSString *jsonString = [[NSString alloc] initWithData:[request responseData] 
												 encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[JSONResult alloc] initWithJSONString:jsonString];
	[jsonString release];
	
	SEL parser = NSSelectorFromString([[request userInfo] objectForKey:@"parser"]);   

	if (parser) {
		ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
		AppModel *appModel = appDelegate.appModel;		
		[appModel performSelector:parser withObject:jsonResult];
	}
	
	[jsonResult release];
}

- (void)requestFailed:(ASIHTTPRequest *)request {	
	NSError *error = [request error];
	
	// inform the user
    NSLog(@"*** JSONConnection: requestFailed: %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	//[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];	
	
}



- (void)dealloc {
	[jsonServerBaseURL release];
	[serviceName release];
	[methodName release];
	[arguments release];
	[asyncData release];
    [super dealloc];
}
 



@end
