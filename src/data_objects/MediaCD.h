//
//  MediaCD.h
//  ARIS
//
//  Created by Kevin Harris on 9/25/09.
//  Copyright 2009 University of Wisconsin - Madison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MediaCD : NSManagedObject

@property (nonatomic, strong) NSNumber *gameId;
@property (nonatomic, strong) NSNumber *mediaId;
@property (nonatomic, strong) NSString *localURL;
@property (nonatomic, strong) NSString *remoteURL;

@end
