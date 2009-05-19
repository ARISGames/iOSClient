//
//  QRCode.h
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRCodeProtocol.h"


@interface QRCode : NSObject <QRCodeProtocol> {
	NSString *name;
	QRCodeKind kind;
	NSString *iconURL;
	NSString *URL;
}


@property(copy, readwrite) NSString *name;
@property(readwrite, assign) QRCodeKind kind;
@property(copy, readwrite) NSString *URL;
@property(copy, readwrite) NSString *iconURL;

@end
