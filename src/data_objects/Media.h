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
    NSData *data; 
}

@property (readonly, assign) int media_id;
@property (readonly, assign) int game_id;
@property (readonly, assign) int user_id;
@property (nonatomic, strong, readonly) NSURL *localURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSData *data;

- (id) initWithMediaCD:(MediaCD *)mcd;
- (void) setPartialLocalURL:(NSString *)partLocalURL;
- (NSString *) fileExtension;
- (NSString *) type;

@end
