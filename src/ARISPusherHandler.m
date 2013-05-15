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

- (id) init
{
    if(self = [super init])
    {
        self.pusherClient = [PTPusher pusherWithKey:@"79f6a265dbb7402a49c9" delegate:self encrypted:YES];
        self.pusherClient.delegate = self;
        self.pusherClient.reconnectAutomatically = YES;

        self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://dev.arisgames.org/server/events/auths/private_auth.php"];
    }
    return self;
}

- (void) loginGame:(int)gameId
{
    self.gameChannel = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-game-channel",gameId]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGameChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:self.gameChannel];
}

- (void) loginPlayer:(int)playerId
{
    self.playerChannel = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-player-channel",playerId]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePlayerChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:self.playerChannel];
}

- (void) loginGroup:(NSString *)group
{
    self.groupChannel  = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%@-group-channel",@"group"]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveGroupChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:self.groupChannel];
}

- (void) loginWebPage:(int)webPageId
{
    self.groupChannel  = [self.pusherClient subscribeToPrivateChannelNamed:[NSString stringWithFormat:@"%d-webpage-channel",webPageId]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveWebPageChannelEventNotification:)
                                                 name:PTPusherEventReceivedNotification
                                               object:self.webPageChannel];
}

- (void) didReceiveGameChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"game"].location == NSNotFound) return;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PusherGameEventReceived" object:event]];
}

- (void) didReceivePlayerChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"player"].location == NSNotFound) return;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PusherPlayerEventReceived" object:event]];
}

- (void) didReceiveGroupChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"group"].location == NSNotFound) return;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PusherGroupEventReceived" object:event]];
}

- (void) didReceiveWebPageChannelEventNotification:(NSNotification *)notification
{
    PTPusherEvent *event = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];
    if([event.channel rangeOfString:@"webPage"].location == NSNotFound) return;
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"PusherWebPageEventReceived" object:event]];
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
