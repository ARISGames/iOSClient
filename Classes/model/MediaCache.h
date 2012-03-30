//
//  MediaCache.h
//  ARIS
//
//  Created by Brian Thiel on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Media.h"

@interface MediaCache : NSObject{
    NSManagedObjectContext *context;
    int mediaCount;
    int maxMediaCount;
}

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic) int mediaCount;
@property (nonatomic) int maxMediaCount;

-(Media *)mediaForMediaId:(int)uid;
-(Media *)mediaForUrl:(NSURL *)url;
@end
