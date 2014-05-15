//
//  WebPage.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface WebPage : NSObject <GameObjectProtocol>
{
    int web_page_id;
	NSString *name;
	NSString *url;    
	int icon_media_id; 
}

@property(readwrite, assign) int web_page_id;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;
@property(readwrite, assign) int icon_media_id;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
