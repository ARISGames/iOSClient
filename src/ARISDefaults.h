//
//  ARISDefaults.h
//  ARIS
//
//  Created by Phil Dougherty on 5/24/14.
//
//

#import <Foundation/Foundation.h>

#define _DEFAULTS_ [ARISDefaults sharedDefaults]

@class User;

@interface ARISDefaults : NSObject
{
    int fallbackGameId;
    User *fallbackUser;
    NSString *version;
    NSString *serverURL;  
    
    BOOL showPlayerOnMap;  
}

@property (nonatomic, assign) int fallbackGameId;
@property (nonatomic, strong) User *fallbackUser;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *serverURL;  
    
@property (nonatomic, assign) BOOL showPlayerOnMap;  

+ (ARISDefaults *) sharedDefaults;

- (void) saveUserDefaults;
- (void) loadUserDefaults;

@end
