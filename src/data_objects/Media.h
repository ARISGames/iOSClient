//
//  Media.h
//  ARIS
//
//  Created by Phil Dougherty on 12/17/13.
//
//

#import <Foundation/Foundation.h>

//oh my gosh this hack is terrible I should be ashamed
#define DEFAULT_PLAQUE_ICON_MEDIA_ID -1
#define DEFAULT_ITEM_ICON_MEDIA_ID -2
#define DEFAULT_DIALOG_ICON_MEDIA_ID -3
#define DEFAULT_WEB_PAGE_ICON_MEDIA_ID -4
#define LOGO_ICON_MEDIA_ID -5
#define DEFAULT_NOTE_ICON_MEDIA_ID -6

@class MediaCD;

@interface Media : NSObject
{
  NSData *data;
  NSData *thumb;
}

@property (readonly, assign) long media_id;
@property (readonly, assign) long game_id;
@property (readonly, assign) long user_id;
@property (readonly, assign) BOOL autoplay;
@property (nonatomic, strong, readonly) NSURL *localURL;
@property (nonatomic, strong) NSURL *remoteURL;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSData *thumb;

- (id) initWithMediaCD:(MediaCD *)mcd;
- (void) setPartialLocalURL:(NSString *)partLocalURL;
- (NSString *) fileExtension;
- (NSString *) type;

@end

