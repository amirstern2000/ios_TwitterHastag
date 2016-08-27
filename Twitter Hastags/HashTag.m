//
//  HashTag.m
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "HashTag.h"

@implementation HashTag{
    BOOL isSearchOld;
}
@synthesize hasTags,hasTagTimer,delegate;


#pragma mark - initlize
-(id)initWithDelegate:(id)_delegate{
    self = [super init];
    if (self){
        delegate = _delegate;
    }
    
    return self;
}

# pragma mark - Twitter API

static STTwitterAPI *shareTwitterAPI = nil;

+(STTwitterAPI *)shareTwitterAPI{
    if (shareTwitterAPI == nil){
        NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *oauthToken = [userDefaults stringForKey:OAUTH_TOKEN_KEY];
        NSString *oauthTokenSecret = [userDefaults stringForKey:OAUTH_TOKEN_SECRET_KEY];
        if (oauthTokenSecret == nil && oauthToken == nil){
            // user not login
            shareTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY
                                                            consumerSecret:CONSUMER_SECRET];
        } else {
            shareTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET oauthToken:oauthToken oauthTokenSecret:oauthTokenSecret];
        }
        
    }
    return shareTwitterAPI;
}

+(void)resetShareTwitterAPI{
    shareTwitterAPI = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:OAUTH_TOKEN_KEY];
    [userDefaults removeObjectForKey:OAUTH_TOKEN_SECRET_KEY];
    [userDefaults synchronize];
}

+(void)saveoOuthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oauthToken forKey:OAUTH_TOKEN_KEY];
    [userDefaults setObject:oauthTokenSecret forKey:OAUTH_TOKEN_SECRET_KEY];
    [userDefaults synchronize];
}

+(void)saveRefrasheRate:(NSInteger)refreshRate{
    if (refreshRate > 0){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setInteger:refreshRate forKey:REFRESH_RATE_KEY];
        [userDefaults synchronize];
    }
}

#pragma mark - public methods
-(void)searchHasTag:(NSString *)hashTag{
    self.hashTag = hashTag;
    [self stopTimer];
    
    [[HashTag shareTwitterAPI] getSearchTweetsWithQuery:self.hashTag
    successBlock:^(NSDictionary *searchMetadata, NSArray *statuses)
    {
        if (statuses.count == 0){
            // search fail
            [delegate onSearchFail:[NSString stringWithFormat:@"Didn't find any tweets for %@",self.hashTag]];
     
        } else {
            // search succesd
            NSLog(@"id_str: %@",statuses[statuses.count-1][@"id_str"]);
            if (hasTags == nil){
                hasTags = [[NSMutableArray alloc] initWithArray:statuses copyItems:YES];
            } else {
                [hasTags removeAllObjects];
                [hasTags insertObjects:statuses atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statuses.count)]];
            }
     
     
        [self startTimer];
        [delegate onSearchSucces];
     
      }
     
     
  } errorBlock:^(NSError *error) {
      // search fail
      [delegate onSearchFail:error.localizedDescription];
     
     }];
    
    
}

-(void)searchForOldTweets{
    if (!isSearchOld){
        NSLog(@"search old tweets");
        isSearchOld = YES;
        [self stopTimer];
        [[HashTag shareTwitterAPI] getSearchTweetsWithQuery:self.hashTag
                                                    geocode:nil lang:nil
                                                     locale:nil
                                                 resultType:@"recent"
                                                      count:@"15"
                                                      until:nil
                                                    sinceID:nil
                                                      maxID:hasTags[hasTags.count-1][@"id_str"]
          includeEntities:@YES callback:nil successBlock:^(NSDictionary *searchMetadata, NSArray *statuses)
        {
           
            if (statuses.count > 1){
                [hasTags removeLastObject];
                [hasTags addObjectsFromArray:statuses];
                [self.delegate onSearchOldTweets:statuses.count-1 position:hasTags.count-statuses.count+1];
            }
            [self startTimer];
            isSearchOld = NO;
           // [hasTags removeLastObject];
            //[hasTags addObjectsFromArray:statuses];
            //hasTags addObjectsFromArray:<#(nonnull NSArray *)#>
            //self.delegate onSearchOldTweets:statuses.count position:<#(NSInteger)#>
            
        } errorBlock:^(NSError *error) {
            [self startTimer];
            isSearchOld = NO;
        }];
    }
    
}

-(void)startTimer{
    if (hasTagTimer == nil){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger refreshRate = [userDefaults integerForKey:REFRESH_RATE_KEY];
        hasTagTimer = [NSTimer
                       scheduledTimerWithTimeInterval: (refreshRate == 0 ? DEFAULT_REFRESH_RATE : refreshRate)
                       target:self selector:@selector(refreshHasTags) userInfo:nil repeats:YES];
    }
}

-(void)stopTimer{
    if (hasTagTimer != nil){
        [hasTagTimer invalidate];
        hasTagTimer = nil;
    }
}

#pragma mark - timer triger
-(void)refreshHasTags{
    NSLog(@"refresh tweets");
    
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
                                                       [delegate onSearchUpdate:statuses.count];
                                                   }
                                                   
                                                   
                                               } errorBlock:^(NSError *error) {
                                                   NSLog(@"%@",error);
                                               }];
    
    
    
}

# pragma mark - input validation
-(BOOL) isSearchEmpty:(NSString *)search{
    return [[search stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""];
}

-(BOOL) isSearchIsHastag:(NSString *)search{
    return [search hasPrefix:@"#"];
}

+(BOOL) isSearchRateIsValid:(NSString *)rate{
    
    if ([rate isEqualToString:@""]) // will use DEFAULT_REFRESH_RATE 30
        return YES;
    NSInteger rateInt = rate.integerValue;
    return (rateInt > 0 && rateInt <= 60);
    
}


@end
