//
//  QRScannerParserDelegate.h
//  ARIS
//
//  Created by David Gagnon on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRCode.h"

@protocol QRScannerParserDelegateDelegate <NSObject>
- (void) qrParserDidFinish:(QRCode *)qrcode;
@end

@interface QRScannerParserDelegate : NSObject {
	QRCode *qrcode;
	id<QRScannerParserDelegateDelegate> delegate;
}

@property(copy, readwrite) QRCode *qrcode;
@property(nonatomic, assign) id<QRScannerParserDelegateDelegate> delegate;

@end
