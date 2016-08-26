//
//  HashTag.m
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "HashTag.h"
#import <FHSTwitterEngine.h>

@implementation HashTag
@synthesize hasTags,hasTagTimer,delegate;

#pragma mark - initlize
-(id)initWithDelegate:(id)_delegate{
    self = [super init];
    if (self){
        delegate = _delegate;
    }
    
    return self;
}

+(STTwitterAPI *)shareTwitterAPI{
    static STTwitterAPI *twitterAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *oauthToken = [userDefaults stringForKey:OAUTH_TOKEN_KEY];
        NSString *oauthTokenSecret = [userDefaults stringForKey:OAUTH_TOKEN_SECRET_KEY];
        if (oauthTokenSecret == nil && oauthToken == nil){
            // user not login
            twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                       consumerSecret:CONSUMER_SECRET];
        } else {
            twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];
        }
    });
    return twitterAPI;
}

+(void)saveoOuthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oauthToken forKey:OAUTH_TOKEN_KEY];
    [userDefaults setObject:oauthTokenSecret forKey:OAUTH_TOKEN_SECRET_KEY];
    [userDefaults synchronize];
}

#pragma mark - public methods
-(void)searchHasTag:(NSString *)hashTag{
    self.hashTag = hashTag;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
        [[HashTag shareTwitterAPI] getSearchTweetsWithQuery:self.hashTag successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
            // search succesd
            hasTags = [[NSMutableArray alloc] initWithArray:statuses copyItems:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startTimer];
                [delegate onSearchSucces];
            });
            
        } errorBlock:^(NSError *error) {
            // search fail
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate onSearchFail];
            });
        }];
        
    });
}

-(void)startTimer{
    if (hasTagTimer == nil)
        hasTagTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(refreshHasTags) userInfo:nil repeats:YES];
}

-(void)stopTimer{
    if (hasTagTimer != nil){
        [hasTagTimer invalidate];
        hasTagTimer = nil;
    }
}

#pragma mark - private methods
-(void)refreshHasTags{
    NSLog(@"refresh tweets");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        [[HashTag shareTwitterAPI] getSearchTweetsWithQuery:self.hashTag
                                                    geocode:@""
                                                       lang:@""
                                                     locale:@""
                                                 resultType:@"recent"
                                                      count:@"15"
                                                      until:@""
                                                    sinceID:hasTags[0][@"id_str"]
                                                      maxID:@""
                                            includeEntities:@YES
          callback:nil successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
              
              if (statuses.count > 0){
                  NSLog(@"new tweets");
                  [hasTags insertObjects:statuses atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)]];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [delegate onSearchUpdate:statuses.count];
                  });
              }
              
            
        } errorBlock:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
    });
    
}
@end
