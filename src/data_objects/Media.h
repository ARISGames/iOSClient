//
//  Media.h
//  ARIS
//
//  Created by Phil Dougherty on 12/17/13.
//
//

#import <Foundation/Foundation.h>
@class MediaCD;

@interface Media : NSObject
{
    int game_id;
    int media_id;
    NSURL *localURL;
    NSURL *remoteURL;
    NSData *data; 
}

@property (readonly, assign) int game_id;
@property (readonly, assign) int media_id;
@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSData *data;

- (id) initWithMediaCD:(MediaCD *)mcd;
- (NSString *) fileExtension;
- (NSString *) type;

@end
