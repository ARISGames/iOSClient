//
//  ScriptElement.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/18.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScriptElement : NSObject
{
	NSString *type;
    int       typeId;
    
    NSString *title;
	NSString *text;
    
    int media_id;
    
    CGRect imageRect;
    float  zoomTime;
    
    BOOL      vibrate;
    NSString *notification;
}

@property (nonatomic,strong) NSString *type;
@property (nonatomic,assign) int       typeId;

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *text;

@property (nonatomic,assign) int media_id;

@property (nonatomic,assign) CGRect imageRect;
@property (nonatomic,assign) float  zoomTime;

@property (nonatomic,assign) BOOL      vibrate;
@property (nonatomic,strong) NSString *notification;

- (id) init;

@end
