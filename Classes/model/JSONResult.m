//
//  JSONResult.m
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "JSONResult.h"
#import "JSON.h"
#import "ARISAppDelegate.h"

@implementation JSONResult

@synthesize returnCode;
@synthesize returnCodeDescription;
@synthesize data;
@synthesize hash;



- (JSONResult*)initWithJSONString:(NSString *)JSONString{
	
	//Calculate the hash
	hash = [JSONString hash];
	
	// Parse JSON into a resultObject
	SBJSON *json = [[SBJSON new] autorelease];
	NSError *jsonError = nil;

	NSDictionary *resultDictionary = [json objectWithString:JSONString error:&jsonError];

	if (jsonError.code) {
		NSLog(@"JSONResult: Error %d parsing JSON String: %@. There must be a problem with the server",jsonError.code, JSONString);
		[(ARISAppDelegate *)[[UIApplication sharedApplication] delegate] showNetworkAlert];
		return nil;
	}
	self.returnCode = [[resultDictionary objectForKey:@"returnCode"]intValue];
	self.returnCodeDescription = [resultDictionary objectForKey:@"returnCodeDescription"];

	NSObject *dataObject = [resultDictionary objectForKey:@"data"];
	
	//NSLog(@"PARSER data: %@", dataObject);
	
	if (self.returnCode == 0) {
		NSLog(@"JSONResult: The return code was 0, continue to parse out the data");
		self.data = [self parseJSONData:dataObject];
	}
	else NSLog(@"JSONResult: The return code was NOT 0, do not parse out the data. Return Code Description: %@",self.returnCodeDescription);

		
	return self;
}


- (NSObject*) parseJSONData:(NSObject *)dataObject{
	//Check if this is a dictionary or or just a simple int/bool
	if (![dataObject isKindOfClass:[NSDictionary class]]) return dataObject;
	
	//This must be an NSDictionary, go ahead and cast it
	NSDictionary *dataDictionary = ((NSDictionary*) dataObject);
	
	//Check if this dictionary contains a rows/cols pair or is just an object
	if (!([dataDictionary objectForKey:@"columns"] && [dataDictionary objectForKey:@"rows"])) {
		//If any of the fields in this dictionary are also dictionaries, we need to parse them as well
		NSEnumerator *dictionaryEnumerator = [dataDictionary objectEnumerator];
		NSObject *objectInDictionary;
		while (objectInDictionary = [dictionaryEnumerator nextObject]) {	
			//parse it
			objectInDictionary = [self parseJSONData:objectInDictionary];
		}
	
		return dataDictionary;
	}

	//Parse the row/col pair into an array of dictionaries
	NSArray *columnsArray = [dataDictionary objectForKey:@"columns"];
	NSArray *rowsArray = [dataDictionary objectForKey:@"rows"];
	NSEnumerator *rowsEnumerator = [rowsArray objectEnumerator];
	NSMutableArray *dictionaryArray = [[[NSMutableArray alloc] init] autorelease];
	
	//add each row as a dictionary to the dictionaryArray 
	NSArray *rowArray;
	while (rowArray = [rowsEnumerator nextObject]) {		
		NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < [rowArray count]; i++) {
			NSString *value = [rowArray objectAtIndex:i];
			NSString *key = [columnsArray objectAtIndex:i];
			[tempDictionary setObject:value forKey:key];
		} 
		[dictionaryArray addObject: tempDictionary];
		[tempDictionary release];		
	}
	return dictionaryArray;
}



- (void)dealloc {
	[returnCodeDescription release];
	[data release];
    [super dealloc];
}




@end
