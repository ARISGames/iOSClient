//
//  JSONResult.m
//  ARIS
//
//  Created by David J Gagnon on 8/27/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import "ServiceResult.h"
#import "JSON.h"
#import "AppModel.h"
#import "ARISAlertHandler.h"

@implementation ServiceResult

@synthesize returnCode;
@synthesize returnCodeDescription;
@synthesize data;
@synthesize userInfo;

- (id) initWithJSONString:(NSString *)JSONString andUserData:(NSDictionary *)userData
{	
    if(self = [super init])
    {
        SBJSON *json = [[SBJSON alloc] init];
        NSError *jsonError = nil;
        NSDictionary *resultDictionary = [json objectWithString:JSONString error:&jsonError];

        if(jsonError.code)
        {
            NSLog(@"JSONResult: SERVER RESPONSE ERROR - Error %d parsing JSON String: %@. There must be a problem with the server",jsonError.code, JSONString);
            [[ARISAlertHandler sharedAlertHandler] showServerAlertEmailWithTitle:NSLocalizedString(@"BadServerResponseTitleKey",@"") message:NSLocalizedString(@"BadServerResponseMessageKey",@"") details:[NSString stringWithFormat:@"JSONResult: Error Parsing String:\n\n%@",JSONString]];
        }
        self.returnCode            = [[resultDictionary objectForKey:@"returnCode"]intValue];
        self.returnCodeDescription = [resultDictionary objectForKey:@"returnCodeDescription"];

        NSObject *dataObject = [resultDictionary objectForKey:@"data"];
            
        if(self.returnCode == 0)
            self.data = [self parseJSONData:dataObject];
        else if(self.returnCode == 1)
        {
            NSLog(@"JSONResult: The return code was 1, we have a bad game id: id = %d",[AppModel sharedAppModel].currentGame.gameId);
            NSLog(@"NSNotification: LogoutRequested");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"LogoutRequested" object:self userInfo:nil]];
        }
        else if(self.returnCode == 4)
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
    }
            
    return self;
}

- (NSObject*) parseJSONData:(NSObject *)dataObject
{
	if(![dataObject isKindOfClass:[NSDictionary class]]) return dataObject;
	NSDictionary *dataDict = ((NSDictionary*) dataObject);
	
    //this literally does nothing...
	if(!([dataDict objectForKey:@"columns"] && [dataDict objectForKey:@"rows"]))
    {
		NSObject *objectInDictionary;
		NSEnumerator *dictEnumer = [dataDict objectEnumerator];
		while(objectInDictionary = [dictEnumer nextObject])
			objectInDictionary = [self parseJSONData:objectInDictionary];
        
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

- (NSString *) description
{
    return [NSString stringWithFormat:@"Data:%@\nReturnCode:%d - Description:%@",data,returnCode,returnCodeDescription];
}

@end
