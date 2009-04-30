//
//  QRCode.h
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QRCode : NSObject {
	NSString *label;
	NSString *type;
	NSString *iconURL;
	NSString *URL;
}


@property(copy, readwrite) NSString *label;
@property(copy, readwrite) NSString *type;
@property(copy, readwrite) NSString *URL;
@property(copy, readwrite) NSString *iconURL;

@end
