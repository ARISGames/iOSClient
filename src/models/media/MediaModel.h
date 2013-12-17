//
//  MediaModel.h
//  ARIS
//
//  Created by Brian Thiel on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Media;

@interface MediaModel : NSObject

- (Media *) mediaForMediaId:(int)mediaId;
- (void) syncMediaDataToCache:(NSArray *)mediaDataToCache;
- (void) clearCache;

@end
