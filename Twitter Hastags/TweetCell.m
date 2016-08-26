//
//  TweetCell.m
//  Twitter Hastags
//
//  Created by MediaHosting LTD on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTweetCell:(NSDictionary *)tweetDic{
    
    // set user image
    NSURL *userImageUrl = [NSURL URLWithString:tweetDic[@"user"][@"profile_image_url_https"]];
    [self.userImageView sd_setImageWithURL:userImageUrl placeholderImage:nil];
    
    // set user name
    self.usernameLabel.text = [NSString stringWithFormat:@"by @%@",tweetDic[@"user"][@"screen_name"]];
    
    // set tweet
    NSMutableAttributedString *tweetString = [[NSMutableAttributedString alloc] initWithString:tweetDic[@"text"]];
    [tweetString beginEditing];
    for (NSDictionary *hashRange in tweetDic[@"entities"][@"hashtags"]) {
        NSNumber *startHash = hashRange[@"indices"][0];
        NSNumber *endHash = hashRange[@"indices"][1];
        NSRange range = NSMakeRange(startHash.integerValue, endHash.integerValue - startHash.integerValue);
        [tweetString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.tweetLabel.font.pointSize] range:range];
    }
    [tweetString endEditing];
    self.tweetLabel.attributedText = tweetString;
    
    // set tweet date
    self.dateLabel.text = tweetDic[@"created_at"];
    
    if (self.tweetImageView != nil){
        // set tweet image
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:small",tweetDic[@"extended_entities"][@"media"][0][@"media_url_https"]]];
        [self.tweetImageView sd_setImageWithURL:imageUrl placeholderImage:nil];
    }
}

@end
