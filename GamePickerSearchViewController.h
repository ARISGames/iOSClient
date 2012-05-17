//
//  GamePickerRecentViewController.h
//  ARIS
//
//  Created by David J Gagnon on 6/7/11.
//  Copyright 2011 University of Wisconsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"

@interface GamePickerSearchViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>{
    
	NSArray *gameList;
    UISearchBar *theSearchBar;
    UIView *disableViewOverlay;
	UITableView *gameTable;
    UIBarButtonItem *refreshButton;
    NSString *searchText;
    int currentPage;
    BOOL currentlyFetchingNextPage;
    BOOL allResultsFound;
}

-(void)refresh;
-(void)showLoadingIndicator;
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;

@property UIView *disableViewOverlay;
@property (nonatomic, copy) NSArray *gameList;
@property (nonatomic) NSString *searchText;
@property (nonatomic) IBOutlet UITableView *gameTable;
@property (nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic) IBOutlet UISearchBar *theSearchBar;
@property (nonatomic) int currentPage;
@property (nonatomic) BOOL currentlyFetchingNextPage;
@property (nonatomic) BOOL allResultsFound;

@end
