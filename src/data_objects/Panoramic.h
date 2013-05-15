//
//  Panoramic.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObjectProtocol.h"

@interface Panoramic : NSObject <GameObjectProtocol>
{
    int panoramicId;
    NSString *name;
    int iconMediaId;
    int mediaId;
}

@property(nonatomic, assign) int panoramicId;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) int iconMediaId;
@property(nonatomic, assign) int mediaId;

@end
