//
//  QRScannerParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRCodeProtocol.h"

@protocol QRScannerParserDelegateDelegate <NSObject>
- (void) qrParserDidFinish:(id<QRCodeProtocol>)qrcode;
@end

@interface QRScannerParserDelegate : NSObject {
	id<QRScannerParserDelegateDelegate> delegate;
	id<QRCodeProtocol> qrcode;
}

@property(nonatomic, assign) id<QRScannerParserDelegateDelegate> delegate;
@property(retain, readwrite) id<QRCodeProtocol> qrcode;

@end
