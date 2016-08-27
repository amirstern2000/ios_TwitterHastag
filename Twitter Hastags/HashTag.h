//
//  HashTag.h
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <STTwitter.h>
# define OAUTH_TOKEN_KEY @"OAUTH_TOKEN_KEY"
# define OAUTH_TOKEN_SECRET_KEY @"OAUTH_TOKEN_SECRET_KEY"
# define CONSUMER_KEY @"HfUz3HXg7OUE4JcdktTGDi030"
# define CONSUMER_SECRET @"n0p5inm0FfAN2KDJ3WiKSbuNAtJEN0gwvnrUwUcBJXdmuZflNO"
# define DEFAULT_REFRESH_RATE 30
# define REFRESH_RATE_KEY @"REFRESH_RATE_KEY"

@interface HashTag : NSObject

#pragma mark - properties
@property (nonatomic, copy) NSString *hashTag;
@property (nonatomic, strong) NSMutableArray *hasTags;
@property (nonatomic, strong) NSTimer *hasTagTimer;
@property (nonatomic, weak) id delegate;

#pragma mark - methods
-(id)initWithDelegate:(id)_delegate;
+(STTwitterAPI *)shareTwitterAPI;
+(void)resetShareTwitterAPI;
+(void)saveoOuthToken:(NSString *)oauthToken andOauthTokenSecret:(NSString *)oauthTokenSecret;
+(void)saveRefrasheRate:(NSInteger)refreshRate;
-(void)searchHasTag:(NSString *)hashTag;
-(void)searchForOldTweets;
-(void)startTimer;
-(void)stopTimer;

-(BOOL) isSearchEmpty:(NSString *)search;
-(BOOL) isSearchIsHastag:(NSString *)search;
+(BOOL) isSearchRateIsValid:(NSString *)rate;



@end
#pragma mark

@protocol HashTagDelegate <NSObject>

-(void)onSearchSucces;
-(void)onSearchFail:(NSString *)error;
-(void)onSearchUpdate:(NSInteger)addedTweets;
-(void)onSearchOldTweets:(NSInteger)addedTweets position:(NSInteger)position;
@end
