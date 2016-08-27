//
//  ViewController.m
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "ViewController.h"


@interface ViewController (){
    
}

@end

@implementation ViewController
@synthesize activityIndicator,tweetsViewController,refreshRateTextField;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.webLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebLoginViewController"];
    tweetsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TweetsViewController"];
    // Do any additional setup after loading the view, typically from a nib.
    [self resoteLogin];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - event methods
- (IBAction)loginTwitter:(id)sender {
    
    if ([HashTag isSearchRateIsValid:refreshRateTextField.text]){
        // valid refresh rate enter or not at all - user defaul
        [HashTag saveRefrasheRate:refreshRateTextField.text.integerValue];
        
        // request access token from twitter to login
        [[HashTag shareTwitterAPI] postTokenRequest:^(NSURL *url, NSString *oauthToken) {
            
            // open Twitter Login in WebView - callback are handle back by URL scheme in AppDelegate
            [self presentViewController:self.webLoginVC animated:YES completion:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.webLoginVC.webView loadRequest:request];
            }];
            
        }
                     authenticateInsteadOfAuthorize:NO
                                         forceLogin:@YES
                                         screenName:nil
                                      oauthCallback:@"twitterhastags://twitter_access_tokens/"
                                         errorBlock:^(NSError *error) {
                                             NSLog(@"-- error: %@", error);
                                             [self createAlertView:error.localizedDescription];
                                             
                                         }];

    } else {
        [self createAlertView:@"Refresh rate invalid"];
    }
    
    
   
}

- (IBAction)clearKeyboard:(id)sender {
    [refreshRateTextField resignFirstResponder];
}

-(void)displaySearchTweetViewControll{
    NSLog(@"display twitter search tweet by hastags");
    [self presentViewController:tweetsViewController animated:YES completion:^{
        [tweetsViewController.tweetsTableView setHidden:YES];
    }];
  
    
}

#pragma mark - Twitter Login Verification
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // dismiss the Login WebView
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [[HashTag shareTwitterAPI] postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        [HashTag saveoOuthToken:oauthToken andOauthTokenSecret:oauthTokenSecret];
        [self displaySearchTweetViewControll];
        
        
    } errorBlock:^(NSError *error) {
        
        
        NSLog(@"-- %@", [error localizedDescription]);
        [self createAlertView:error.localizedDescription];
    }];
}

-(void)resoteLogin{
    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oauthToken = [userDefaults stringForKey:OAUTH_TOKEN_KEY];
    NSString *oauthTokenSecret = [userDefaults stringForKey:OAUTH_TOKEN_SECRET_KEY];
    if (oauthTokenSecret == nil && oauthToken == nil){
         //user oauthToken & oauthTokenSecret are not in NSUserDefaults
    } else {
       
         //user oauthToken & oauthTokenSecret are in NSUserDefaults
        [[HashTag shareTwitterAPI] verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            // user is sing in - move to tweets page
            NSLog(@"username: %@,\nuserId: %@",username,userID);
            [self displaySearchTweetViewControll];
        } errorBlock:^(NSError *error) {
            // /user oauthToken & oauthToken are not valid or Internet connection problem
            NSLog(@"verifiy aouth error: %@",error);
            [self createAlertView:error.localizedDescription];
        }];
        
        
   }
    
 
}

-(void)createAlertView:(NSString *) message{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Twitter Hashtags" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

@end
