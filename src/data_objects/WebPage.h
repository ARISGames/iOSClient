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
    int webPageId;
	NSString *name;
	NSString *url;    
	int iconMediaId; 
}

@property(readwrite, assign) int webPageId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;
@property(readwrite, assign) int iconMediaId;

@end
