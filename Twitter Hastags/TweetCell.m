//
//  TweetCell.m
//  Twitter Hastags
//
//  Created by AmirStern on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "TweetCell.h"
#import <NSDateFormatter+STTwitter.h>

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
    NSURL *userImageUrl = [NSURL URLWithString:[tweetDic[@"user"][@"profile_image_url_https"] stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"]];
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
    self.dateLabel.text = [self checkDateType:[[TweetCell twitterDateFormattor] dateFromString:tweetDic[@"created_at"]]nowDate:[NSDate date]];
    
    if (self.tweetImageView != nil){
        // set tweet image
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:small",tweetDic[@"extended_entities"][@"media"][0][@"media_url_https"]]];
        [self.tweetImageView sd_setImageWithURL:imageUrl placeholderImage:nil];
    }
}

-(NSString *) checkDateType:(NSDate *)tweetDate nowDate:(NSDate *) date{
    
    NSTimeInterval time = [date timeIntervalSinceDate:tweetDate];
    NSUInteger unitFlags  = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *tweetsComponents = [calendar components:unitFlags fromDate:tweetDate];
    NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:date];
    
    if (tweetsComponents.year < nowComponents.year){
        // e.g. Aug 21, 2016
        return [[TweetCell yearDateFormatter] stringFromDate:tweetDate];
    } else if (tweetsComponents.day < nowComponents.day || tweetsComponents.month < nowComponents.month){
        // e.g. Aug 21
        return [[TweetCell monthDateFormatter] stringFromDate:tweetDate];
    } else {
        if (time < SECONDS_IN_MINUTE){
            // e.g. just now
            return @"Just now";
        } else if (time <  SECONDS_IN_HOUR){
            // e.g. 5 min
            return [NSString stringWithFormat:@"%d min",(int)(time/SECONDS_IN_MINUTE)];
        } else {
            // e.g. 2 hours
            int hours = (int)(time/(SECONDS_IN_HOUR));
            return [NSString stringWithFormat:@"%d %@",hours,hours == 1 ? @"hour" : @"hours"];
        }
    }

}

+(NSDateFormatter *)twitterDateFormattor{
    static NSDateFormatter *twitterDateFormattor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        twitterDateFormattor = [[NSDateFormatter alloc] init];
        [twitterDateFormattor setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    });
    
    return twitterDateFormattor;
}

+(NSDateFormatter *) yearDateFormatter{
    static NSDateFormatter *yearDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yearDateFormatter = [[NSDateFormatter alloc] init];
        [yearDateFormatter setDateFormat:@"MMM dd, yyyy"];
    });
    
    return yearDateFormatter;
}

+(NSDateFormatter *) monthDateFormatter{
    static NSDateFormatter *monthDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monthDateFormatter = [[NSDateFormatter alloc] init];
        [monthDateFormatter setDateFormat:@"MMM dd"];
    });
    
    return monthDateFormatter;
}

@end
