//
//  Scene.h
//  aris-conversation
//
//  Created by Kevin Harris on 09/11/18.
//  Copyright 2009 Studio Tectorum. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scene : NSObject
{
	NSString *sceneType;
    int       typeId;
    
    NSString *title;
	NSString *text;
    
    int mediaId;
    
    NSString *adjustTextArea;
    
    CGRect imageRect;
    float  zoomTime;
    
    BOOL      vibrate;
    NSString *notification;
}

@property (nonatomic,strong) NSString *sceneType;
@property (nonatomic,assign) int       typeId;

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *text;

@property (nonatomic,assign) int mediaId;

@property (nonatomic,strong) NSString *adjustTextArea;

@property (nonatomic,assign) CGRect imageRect;
@property (nonatomic,assign) float  zoomTime;

@property (nonatomic,assign) BOOL      vibrate;
@property (nonatomic,strong) NSString *notification;

- (id) init;

@end
