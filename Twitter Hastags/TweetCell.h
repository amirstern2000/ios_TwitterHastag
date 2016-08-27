//
//  TweetCell.h
//  Twitter Hastags
//
//  Created by AmirStern on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
# define SECONDS_IN_MINUTE 60
# define SECONDS_IN_HOUR SECONDS_IN_MINUTE*SECONDS_IN_MINUTE
# define SECONDS_IN_DAY SECONDS_IN_HOUR*24

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tweetImageView;

-(void)setTweetCell:(NSDictionary *)tweetDic;
@end


