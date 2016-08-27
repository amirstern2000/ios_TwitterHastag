//
//  TweetCell.m
//  Twitter Hastags
//
//  Created by MediaHosting LTD on 25/08/2016.
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
    NSDate *tweetDate = [[TweetCell twitterDateFormattor] dateFromString:tweetDic[@"created_at"]];
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSinceDate:tweetDate];
     NSUInteger unitFlags  = NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitHour;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:tweetDate toDate:date options:0];
    NSInteger year = components.year;
    
    
    if (time < SECONDS_IN_MINUTE){
        // just now
        self.dateLabel.text = @"Just now";
    } else if (time <  SECONDS_IN_HOUR){
        // 5 min
        self.dateLabel.text = [NSString stringWithFormat:@"%d min",(int)(time/SECONDS_IN_MINUTE)];
    } else if (time < SECONDS_IN_DAY){
        // 2 hour/s
        int hours = (int)(time/(SECONDS_IN_HOUR));
        self.dateLabel.text = [NSString stringWithFormat:@"%d %@",hours,hours == 1 ? @"hour" : @"hours"];
    } else if (year < 1) {
        // Agoust 21
        self.dateLabel.text = [[TweetCell monthDateFormatter] stringFromDate:tweetDate];
    } else {
        // Agoust 21, 2016
        self.dateLabel.text = [[TweetCell yearDateFormatter] stringFromDate:tweetDate];
    }
    //self.dateLabel.text = tweetDic[@"created_at"];
    
    if (self.tweetImageView != nil){
        // set tweet image
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@:small",tweetDic[@"extended_entities"][@"media"][0][@"media_url_https"]]];
        [self.tweetImageView sd_setImageWithURL:imageUrl placeholderImage:nil];
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
