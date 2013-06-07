//
//  MQRCode.h
//  ARIS
//
//  Created by Miodrag Glumac on 10/24/11.
//  Copyright (c) 2011 Amherst College. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MGame;

@interface MQRCode : NSManagedObject

@property (nonatomic, retain) NSNumber * qrCodeId;
@property (nonatomic, retain) NSString * linkType;
@property (nonatomic, retain) NSNumber * linkId;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * matchMediaId;
@property (nonatomic, retain) MGame *game;

@end
