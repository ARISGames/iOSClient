//
//  XMLParserDelegate.h
//  ARIS
//
//  Created by Kevin Harris on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XMLParserDelegate : NSObject {
	NSDictionary *elementDictionary;
	NSMutableArray *results;
	NSString *notificationName;
}

- (XMLParserDelegate*)initWithDictionary:(NSDictionary *)aDictionary 
							  andResults:(NSMutableArray *)theResults
						 forNotification:(NSString *)name;

@end
