//
//  Comment.h
//  ARIS
//
//  Created by Philip Dougherty on 6/7/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Comment : NSObject {
    NSString *text;
    NSString *playerName;
    int rating;
}

@property(copy, readwrite) NSString *text;
@property(copy, readwrite) NSString *playerName;  
@property(readwrite) int rating;

@end
