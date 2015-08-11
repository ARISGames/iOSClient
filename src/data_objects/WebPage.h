//
//  WebPage.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantiableProtocol.h"

@interface WebPage : NSObject <InstantiableProtocol>
{
  long web_page_id;
	NSString *name;
	NSString *url;
	long icon_media_id;
	BOOL back_button_enabled;
}

@property (nonatomic, assign) long web_page_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) long icon_media_id;
@property (nonatomic, assign) BOOL back_button_enabled;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
