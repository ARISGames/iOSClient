//
//  PanoramicMedia.h
//  ARIS
//
//  Created by David Gagnon on 7/26/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PanoramicMedia : NSObject {
    NSString *text;
    int mediaId;
}

@property(nonatomic) NSString *text;
@property(readwrite, assign) int mediaId;

@end
