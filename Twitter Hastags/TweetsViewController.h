//
//  TweetsViewController.h
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HashTag.h"

@interface TweetsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) HashTag *hashTag;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;

- (IBAction)logout:(id)sender;
@end
