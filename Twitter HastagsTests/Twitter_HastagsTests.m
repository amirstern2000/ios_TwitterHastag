//
//  Twitter_HastagsTests.m
//  Twitter HastagsTests
//
//  Created by MediaHosting LTD on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HashTag.h"
#import "TweetCell.h"

@interface Twitter_HastagsTests : XCTestCase
@property (nonatomic) HashTag *hasTag;
@property (nonatomic) TweetCell *cell;

@end

@interface TweetCell (Test)
-(NSString *) checkDateType:(NSDate *)tweetDate nowDate:(NSDate *) date;
+(NSDateFormatter *)twitterDateFormattor;
+(NSDateFormatter *) yearDateFormatter;
+(NSDateFormatter *) monthDateFormatter;
@end

@implementation Twitter_HastagsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.hasTag = [[HashTag alloc] init];
    self.cell = [[TweetCell alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testSearch{
    // test search input
    BOOL emptyResult = [self.hasTag isSearchEmpty:@""];
    BOOL notEmptyResult = [self.hasTag isSearchEmpty:@"Somthing to search for"];
    BOOL hastTagResult = [self.hasTag isSearchIsHastag:@"#hashtag"];
    BOOL notHashTagresult = [self.hasTag isSearchIsHastag:@"hashtag"];
    
    XCTAssertEqual(emptyResult, YES); // search is empty
    XCTAssertEqual(notEmptyResult, NO); // search is not empty
    XCTAssertEqual(hastTagResult, YES); // search start with '#'
    XCTAssertEqual(notHashTagresult, NO); // search don't start with '#'
}

-(void)testSearchRate{
    // test search rate input
    BOOL textResult = [HashTag isSearchRateIsValid:@"some text"];
    BOOL zeroResult = [HashTag isSearchRateIsValid:@"0"];
    BOOL inRangeResult = [HashTag isSearchRateIsValid:@"15"];
    BOOL outOfRangeResult1 = [HashTag isSearchRateIsValid:@"124"];
    BOOL outOfRangeResult2 = [HashTag isSearchRateIsValid:@"-124"];
    
    XCTAssertEqual(textResult, NO); // rate is text and not number
    XCTAssertEqual(zeroResult, NO); // rate is 0
    XCTAssertEqual(inRangeResult, YES); // rate is in range (1 - 60)
    XCTAssertEqual(outOfRangeResult1, NO); // rate is over 60
    XCTAssertEqual(outOfRangeResult2, NO); // rate is below 0
}

-(void)testDateType{
    // test NSDate parsing Teand
    NSString *nowDate = @"Thu Aug 24 23:23:36 +0000 2016";
   [[TweetCell twitterDateFormattor] setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
   [[TweetCell monthDateFormatter] setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
   [[TweetCell yearDateFormatter] setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *justNowDate1 = [self.cell
                             checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 23:23:36 +0000 2016"]
                             nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate2 = [self.cell
                             checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 23:22:58 +0000 2016"]
                             nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate3 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 23:22:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate4 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 23:10:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    
    NSString *justNowDate5 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 23 23:30:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate6 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 22:30:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate7 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 21:20:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate8 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Aug 24 22:20:25 +0000 2016"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    NSString *justNowDate9 = [self.cell
                              checkDateType:[[TweetCell twitterDateFormattor] dateFromString:@"Thu Dec 24 22:20:25 +0000 2015"]
                              nowDate:[[TweetCell twitterDateFormattor] dateFromString:nowDate]];
    
    XCTAssertEqualObjects(justNowDate1,@"Just now");
    XCTAssertEqualObjects(justNowDate2,@"Just now");
    XCTAssertEqualObjects(justNowDate3,@"1 min");
    XCTAssertEqualObjects(justNowDate4,@"13 min");
    XCTAssertEqualObjects(justNowDate5,@"Aug 23");
    XCTAssertEqualObjects(justNowDate6,@"53 min");
    XCTAssertEqualObjects(justNowDate7,@"2 hours");
    XCTAssertEqualObjects(justNowDate8,@"1 hour");
    XCTAssertEqualObjects(justNowDate9,@"Dec 24, 2015");
}



@end
