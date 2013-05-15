//
//  GamePickerRecentViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePickerViewController.h"

@interface GamePickerSearchViewController : GamePickerViewController <UISearchDisplayDelegate, UISearchBarDelegate>
{    
    UISearchBar *theSearchBar;
    UIView *disableViewOverlay;
    NSString *searchText;
    int currentPage;
    BOOL currentlyFetchingNextPage;
    BOOL allResultsFound;
}

- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@property UIView *disableViewOverlay;
@property (nonatomic, strong) IBOutlet UISearchBar *theSearchBar;

@end
