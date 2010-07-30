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
	NSURL *requestURL = [[NSURL alloc]initWithString:requestString];
	[requestString release];
	
	NSURLRequest *requestURLRequest = [NSURLRequest requestWithURL:requestURL
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:60];
	[requestURL release];
	
	// Make synchronous request
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showWaitingIndicator: @"Loading" displayProgressBar:NO];
	
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]]; //Let the activity indicator show before doing the sync request
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *resultData = [NSURLConnection sendSynchronousRequest:requestURLRequest
											   returningResponse:&response
														   error:&error];	

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] removeWaitingIndicator];

	if (error != nil) {
		NSLog(@"JSONConnection: Error communicating with server.");
		[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];	
	}	
	
	NSString *jsonString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	
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
	NSURL *requestURL = [[NSURL alloc]initWithString:requestString];
	[requestString release];
	
	NSURLRequest *request = [NSURLRequest requestWithURL:requestURL
													   cachePolicy:NSURLRequestReturnCacheDataElseLoad
												   timeoutInterval:60];
	[requestURL release];
	
	//set up indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showWaitingIndicator: @"Loading"];
	
	//do it
	ARISURLConnection *urlConnection = [[ARISURLConnection alloc] initWithRequest:request delegate:self parser:parser];
	asyncData = [NSMutableData dataWithCapacity:1000];
	[asyncData retain];
	[urlConnection start];
	[urlConnection release];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
	NSLog(@"JSONConnection: didRevieveResponse");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"JSONConnection: Recieved Data: %@", dataAsString);
	[dataAsString release];
	
	[asyncData appendData:data];

}




- (void)connectionDidFinishLoading:(ARISURLConnection *)connection {
	NSLog(@"JSONConnection: Finished Loading Data");
	
	//end the loading and spinner UI indicators
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	NSString *jsonString = [[NSString alloc] initWithData:asyncData encoding:NSUTF8StringEncoding];
	
	//Get the JSONResult here
	JSONResult *jsonResult = [[JSONResult alloc] initWithJSONString:jsonString];
	[jsonString release];
	
	if (connection.parser) {
		ARISAppDelegate *appDelegate = (ARISAppDelegate *) [[UIApplication sharedApplication] delegate];
		AppModel *appModel = appDelegate.appModel;		
		[appModel performSelector:connection.parser withObject:jsonResult];
	}
	
	[jsonResult release];
}

- (void)connection:(ARISURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"JSONConnection: Error communicating with server.");
	
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
