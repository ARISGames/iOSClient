//
//  Tag.h
//  ARIS
//
//  Created by Brian Thiel on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject{
    NSString *tagName;
    BOOL playerCreated;
    int tagId;
}
@property(readwrite) int tagId;
@property(nonatomic)NSString *tagName;
@property(readwrite,assign)BOOL playerCreated;
@end
