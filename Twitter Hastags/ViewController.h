//
//  ViewController.h
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetsViewController.h"
#import "WebLoginViewController.h"

# define OAUTH_TOKEN_KEY @"OAUTH_TOKEN_KEY"
# define OAUTH_TOKEN_SECRET_KEY @"OAUTH_TOKEN_SECRET_KEY"
# define CONSUMER_KEY @"HfUz3HXg7OUE4JcdktTGDi030"
# define CONSUMER_SECRET @"n0p5inm0FfAN2KDJ3WiKSbuNAtJEN0gwvnrUwUcBJXdmuZflNO"
@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *refreshRateTextField;
@property (strong, nonatomic) TweetsViewController *tweetsViewController;
@property (strong, nonatomic) WebLoginViewController *webLoginVC;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)loginTwitter:(id)sender;
- (IBAction)clearKeyboard:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;
@end

