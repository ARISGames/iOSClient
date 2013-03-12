//
//  QRCodeProtocol.h
//  ARIS
//
//  Created by David Gagnon on 5/15/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

enum {
	QRCodeNPC		= 1,
	QRCodeItem		= 2,
	QRCodeNode		= 3
};
typedef UInt32 QRCodeKind;

@protocol QRCodeProtocol
- (NSString *)name; 
- (QRCodeKind)kind;
- (void)display;
@end
