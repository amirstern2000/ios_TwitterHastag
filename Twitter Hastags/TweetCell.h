//
//  TweetCell.h
//  Twitter Hastags
//
//  Created by MediaHosting LTD on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tweetImageView;

-(void)setTweetCell:(NSDictionary *)tweetDic;
@end
