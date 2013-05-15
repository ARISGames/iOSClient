//
//  NewUIExampleViewController.h
//  ARIS
//
//  Created by Jacob Hanshaw on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#import "PopOverContentView.h"
#import "AsyncMediaImageView.h"
#import "ARISMoviePlayerViewController.h"
#import "Media.h"

@protocol PopOverViewDelegate
- (void) popOverContinueButtonPressed;
@end

@interface PopOverViewController : UIViewController<AsyncMediaImageViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate>
{    
    IBOutlet PopOverContentView *mainViewNoMedia;
    IBOutlet PopOverContentView *mainViewMedia;
    IBOutlet UIView *mainViewNoMediaContentView;
    IBOutlet UIView *mainViewMediaContentView;
    UIView *mainView;
    
    IBOutlet UILabel *lbl_popOverTitleNoMedia;
    IBOutlet UILabel *lbl_popOverTitleMedia;
    UILabel *lbl_popOverTitle;
    
    IBOutlet UILabel *lbl_popOverDescriptionNoMedia;
    IBOutlet UILabel *lbl_popOverDescriptionMedia;
    UILabel *lbl_popOverDescription;
    
    IBOutlet UIWebView *popOverWebViewNoMedia;
    IBOutlet UIWebView *popOverWebViewMedia;
    UIWebView *popOverWebView;
    
    IBOutlet UIButton *continueButtonNoMedia;
    IBOutlet UIButton *continueButtonMedia;
    UIButton *continueButton;
    
    IBOutlet UIView *mediaView;
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    UIImageView *backgroundImage;
    UIView *semiTransparentView;
    
    AVAudioPlayer *player;
    ARISMoviePlayerViewController *ARISMoviePlayer;
    AsyncMediaImageView	*imageView;
}

- (id) initWithDelegate:(id <PopOverViewDelegate>)poDelegate;
- (void) setTitle:(NSString *)title description:(NSString *)description webViewText: (NSString *)text andMediaId: (int) mediaId;
- (IBAction) continuePressed:(id)sender;

@end
