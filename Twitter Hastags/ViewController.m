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
@synthesize activityIndicator,tweetsViewController;
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
    
    [[HashTag shareTwitterAPI] postTokenRequest:^(NSURL *url, NSString *oauthToken) {
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
        
    }];
    
   
}

-(void)displaySearchTweetViewControll{
    NSLog(@"display twitter search tweet by hastags");
    [self.navigationController pushViewController:tweetsViewController animated:YES];
    
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [[HashTag shareTwitterAPI] postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        [HashTag saveoOuthToken:oauthToken andOauthTokenSecret:oauthTokenSecret];
        [self displaySearchTweetViewControll];
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        
        
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

-(void)saveoOuthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oauthToken forKey:OAUTH_TOKEN_KEY];
    [userDefaults setObject:oauthTokenSecret forKey:OAUTH_TOKEN_SECRET_KEY];
    [userDefaults synchronize];
}

-(void)resoteLogin{
    /*NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oauthToken = [userDefaults stringForKey:OAUTH_TOKEN_KEY];
    NSString *oauthTokenSecret = [userDefaults stringForKey:OAUTH_TOKEN_SECRET_KEY];
    if (oauthTokenSecret == nil && oauthToken == nil){
        // user not login
    } else {*/
       
        [[HashTag shareTwitterAPI] verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
            // user is sing in - move to tweets page
            NSLog(@"username: %@,\nuserId: %@",username,userID);
            [self displaySearchTweetViewControll];
        } errorBlock:^(NSError *error) {
            // user is not login
            NSLog(@"verifiy aouth error: %@",error);
        }];
        
        
   // }
    
 
}

@end
