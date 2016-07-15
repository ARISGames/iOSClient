//
//  ARISPusherHandler.m
//  ARIS
//
//  Created by Phil Dougherty on 5/3/13.
//
//

#import "ARISPusherHandler.h"

#import "PTPusher.h"
#import "PTPusherDelegate.h"
#import "PTPusherChannel.h"
#import "PTPusherEvent.h"

#import "ARISAlertHandler.h" //HACK BECAUSE ONLY FUNCTIONALITY IS TO DISPLAY ALERT

@interface ARISPusherHandler () <PTPusherDelegate>
{
    PTPusher *pusherClient;
    PTPusherPrivateChannel *playerChannel;
    PTPusherPrivateChannel *groupChannel;
    PTPusherPrivateChannel *gameChannel;
    PTPusherPrivateChannel *webPageChannel;
}

@property (nonatomic, strong) PTPusher *pusherClient;
@property (nonatomic, strong) PTPusherPrivateChannel *playerChannel;
@property (nonatomic, strong) PTPusherPrivateChannel *groupChannel;
@property (nonatomic, strong) PTPusherPrivateChannel *gameChannel;
@property (nonatomic, strong) PTPusherPrivateChannel *webPageChannel;

@end

@implementation ARISPusherHandler

@synthesize pusherClient;
@synthesize playerChannel;
@synthesize groupChannel;
@synthesize gameChannel;
@synthesize webPageChannel;

+ (id) sharedPusherHandler
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id) init
{
    if(self = [super init])
    {
        self.pusherClient = [PTPusher pusherWithKey:@"79f6a265dbb7402a49c9" delegate:self encrypted:YES];
        self.pusherClient.authorizationURL = [NSURL URLWithString:@"https://arisgames.org/server/events/auths/private_auth.php"];
        [self.pusherClient connect];
    }
    return self;
}

- (void) loginGame:(long)game_id
{
    self.gameChannel = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%ld-game-channel",game_id]];
  _ARIS_NOTIF_LISTEN_(PTPusherEventReceivedNotification, self ,@selector(didReceiveGameChannelEventNotification:) ,self.gameChannel);
}

- (void) loginPlayer:(long)user_id
{
    if (self.playerChannel) return;
    self.playerChannel = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%ld-player-channel",user_id]];
  _ARIS_NOTIF_LISTEN_(PTPusherEventReceivedNotification, self ,@selector(didReceivePlayerChannelEventNotification:) ,self.playerChannel);
}

- (void) loginGroup:(NSString *)group
{
    self.groupChannel  = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%@-group-channel",@"group"]];
  _ARIS_NOTIF_LISTEN_(PTPusherEventReceivedNotification, self ,@selector(didReceiveGroupChannelEventNotification:) ,self.groupChannel);
}

- (void) loginWebPage:(long)web_page_id
{
    self.groupChannel  = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%ld-webpage-channel",web_page_id]];
  _ARIS_NOTIF_LISTEN_(PTPusherEventReceivedNotification, self ,@selector(didReceiveWebPageChannelEventNotification:) ,self.webPageChannel);
}

- (void) didReceiveGameChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"game"].location == NSNotFound) return;

    if([event.name isEqualToString:@"alert"])
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"GameNoticeKey", @"") message:event.data];
    _ARIS_NOTIF_SEND_(@"PusherGameEventReceived",event,nil);
}

- (void) didReceivePlayerChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"player"].location == NSNotFound) return;

    if([event.name isEqualToString:@"alert"])
        [[ARISAlertHandler sharedAlertHandler] showAlertWithTitle:NSLocalizedString(@"PlayerNoticeKey", @"") message:event.data];
    _ARIS_NOTIF_SEND_(@"PusherPlayerEventReceived",event,nil);
}

- (void) didReceiveGroupChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"group"].location == NSNotFound) return;
    _ARIS_NOTIF_SEND_(@"PusherGroupEventReceived",event,nil);
}

- (void) didReceiveWebPageChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"webPage"].location == NSNotFound) return;
    _ARIS_NOTIF_SEND_(@"PusherWebPageEventReceived",event,nil);
}

- (void) logoutGame
{
    if(self.gameChannel)    [(PTPusherChannel *)self.gameChannel    unsubscribe];
    self.gameChannel    = nil;
}
- (void) logoutPlayer
{
    if(self.playerChannel)  [(PTPusherChannel *)self.playerChannel  unsubscribe];
    self.playerChannel  = nil;
}
- (void) logoutGroup
{
    if(self.groupChannel)   [(PTPusherChannel *)self.groupChannel   unsubscribe];
    self.groupChannel   = nil;
}
- (void) logoutWebPage
{
    if(self.webPageChannel) [(PTPusherChannel *)self.webPageChannel unsubscribe];
    self.webPageChannel = nil;
}

@end
