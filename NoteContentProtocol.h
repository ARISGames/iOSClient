//
//  NoteContentProtocol.h
//  ARIS
//
//  Created by Philip Dougherty on 2/6/12.
//  Copyright (c) 2012 UW Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteContentProtocol <NSObject>
@required
- (NSData *) getMedia;
- (NSString *) getText;
@end
