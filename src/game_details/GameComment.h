//
//  GameComment.h
//  ARIS
//
//  Created by Philip Dougherty on 6/7/11.
//  Copyright 2011 UW Madison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameComment : NSObject
{
    NSString *title; 
    NSString *text;
    NSString *playerName;
    NSDate *date;
    long rating;
}

@property(copy, readwrite) NSString *title;
@property(copy, readwrite) NSString *text;
@property(copy, readwrite) NSString *playerName;  
@property(copy, readwrite) NSDate *date;
@property(readwrite) long rating;

@end
