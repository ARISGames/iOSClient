//
//  BumpTestViewController.h
//  ARIS
//
//  Created by Phil Dougherty on 2/27/13.
//
//

#import <UIKit/UIKit.h>

@interface BumpTestViewController : UIViewController
{
    id __unsafe_unretained delegate;
    IBOutlet UIScrollView *debugView;
    int messageNumber;
}

@property (nonatomic, strong) IBOutlet UIScrollView *debugView;

@end
