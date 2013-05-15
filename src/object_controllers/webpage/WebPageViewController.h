//
//  WebPageViewController.h
//  ARIS
//
//  Created by Brian Thiel on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameObjectViewController.h"
#import "WebPage.h"
#import "ARISMoviePlayerViewController.h"
#import "BumpClient.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WebPageViewController : GameObjectViewController <AVAudioPlayerDelegate, UIWebViewDelegate>{
    IBOutlet	UIWebView	*webView;
    WebPage     *webPage;
    IBOutlet    UIView  *blackView;
    UIActivityIndicatorView *activityIndicator;
    NSMutableDictionary *avPlayers;
    AVPlayer *localPlayer;
    NSString *bumpSendString;
    bool isConnectedToBump;
    bool loaded;
}

@property(nonatomic) IBOutlet UIWebView	*webView;
@property(nonatomic) WebPage *webPage;
@property(nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic) IBOutlet UIView *blackView;
@property(nonatomic, strong) NSMutableDictionary *audioPlayers;
@property(nonatomic) NSString *bumpSendString;
@property(nonatomic) bool isConnectedToBump;
@property(nonatomic) bool loaded;

- (id) initWithWebPage:(WebPage *)w delegate:(NSObject<GameObjectViewControllerDelegate> *)d;

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest: (NSURLRequest*)req navigationType:(UIWebViewNavigationType)navigationType;
- (void) showWaitingIndicator;
- (void) dismissWaitingIndicator;
- (void) refreshConvos;
- (void) loadAudioFromMediaId:(int)mediaId;
- (void) playAudioFromMediaId:(int)mediaId;
- (void) stopAudioFromMediaId:(int)mediaId;

@end
