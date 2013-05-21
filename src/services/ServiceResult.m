//
//  JSONResult.m
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ServiceResult.h"
#import "JSON.h"
#import "ARISAppDelegate.h"
#import "ARISAlertHandler.h"

@implementation ServiceResult

@synthesize returnCode;
@synthesize returnCodeDescription;
@synthesize data;
@synthesize userInfo;

- (id) initWithJSONString:(NSString *)JSONString andUserData:(NSDictionary *)userData
{	
	// Parse JSON into a resultObject
	SBJSON *json = [[SBJSON alloc] init];
	NSError *jsonError = nil;
	NSDictionary *resultDictionary = [json objectWithString:JSONString error:&jsonError];

	if(jsonError.code)
    {
		NSLog(@"JSONResult: SERVER RESPONSE ERROR - Error %d parsing JSON String: %@. There must be a problem with the server",jsonError.code, JSONString);
        [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",JSONString]];
	}
	self.returnCode = [[resultDictionary objectForKey:@"returnCode"]intValue];
	self.returnCodeDescription = [resultDictionary objectForKey:@"returnCodeDescription"];

	NSObject *dataObject = [resultDictionary objectForKey:@"data"];
		
	if (self.returnCode == 0)
    {
		self.data = [self parseJSONData:dataObject];
	}
	else if (self.returnCode == 1)
    {
		NSLog(@"JSONResult: The return code was 1, we have a bad game id: id = %d",[AppModel sharedAppModel].currentGame.gameId);
        NSLog(@"NSNotification: LogoutRequested");
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self userInfo:nil]];
	}
    else if (self.returnCode == 4)
    {
        NSLog(@"Player doesn't exist for forgot password");
        return nil;
    }
	else
    {
		NSLog(@"JSONResult: SERVER RESPONSE ERROR - Return Code != 0 for Json String %@",JSONString);
        [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",JSONString]];
    }
    
    self.userInfo = userData;
		
	return self;
}

- (NSObject*) parseJSONData:(NSObject *)dataObject
{
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
	NSMutableArray *dictionaryArray = [[NSMutableArray alloc] init];
	
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
	}
	return dictionaryArray;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"Data:%@\nReturnCode:%d - Description:%@",data,returnCode,returnCodeDescription];
}

@end
