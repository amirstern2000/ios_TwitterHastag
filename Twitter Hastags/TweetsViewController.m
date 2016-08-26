//
//  TweetsViewController.m
//  Twitter Hastags
//
//  Created by AmirStern on 23/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "TweetsViewController.h"
#import "TweetCell.h"

@interface TweetsViewController ()<UISearchBarDelegate,HashTagDelegate>{
    
}

@end

@implementation TweetsViewController
@synthesize hashTag,activityIndicator,tweetsTableView;


- (void)viewDidLoad {
    [super viewDidLoad];
    [activityIndicator setHidesWhenStopped:YES];
    hashTag = [[HashTag alloc] initWithDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [hashTag stopTimer];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchBarDelegate
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if ([searchBar.text isEqualToString:@""])
        [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""])
        [searchBar resignFirstResponder];
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    if (![searchBar.text isEqualToString:@""]){
        [searchBar setShowsCancelButton:YES];
        [hashTag searchHasTag:searchBar.text];
        [activityIndicator startAnimating];
        
        
    }
    
}

#pragma mark - UITableView delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return hashTag.hasTags == nil ? 0 : hashTag.hasTags.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TweetCell *cell;
    NSDictionary *tweetDic = hashTag.hasTags[indexPath.row];
    if (tweetDic[@"extended_entities"] && [tweetDic[@"extended_entities"][@"media"][0][@"type"] isEqualToString:@"photo"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCellWithImage" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    }
    [cell setTweetCell:tweetDic];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static TweetCell *sizingCell = nil;
    static TweetCell *sizingImageCell = nil;
    static dispatch_once_t cellToken;
    static dispatch_once_t imageCellToken;
    dispatch_once(&cellToken, ^{
        sizingCell = [tweetsTableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    });
    
    dispatch_once(&imageCellToken, ^{
        sizingImageCell = [tweetsTableView dequeueReusableCellWithIdentifier:@"TweetCellWithImage"];
    });
    NSDictionary *tweetDic = hashTag.hasTags[indexPath.row];
    
    if (tweetDic[@"extended_entities"] && [tweetDic[@"extended_entities"][@"media"][0][@"type"] isEqualToString:@"photo"]){
        [sizingImageCell setTweetCell:tweetDic];
        return [self calculateHeightForConfiguredSizingCell:sizingImageCell];
    } else {
        [sizingCell setTweetCell:tweetDic];
        return [self calculateHeightForConfiguredSizingCell:sizingCell];
    }
    
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    //[sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - HastTag delegate
-(void)onSearchSucces{
    [activityIndicator stopAnimating];
    [tweetsTableView reloadData];
    NSLog(@"search success");
    
}

-(void)onSearchFail{
    [activityIndicator stopAnimating];
    NSLog(@"shearch fail");
}

-(void)onSearchUpdate:(NSInteger)addedTweets{
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:addedTweets];
    for (NSInteger i = 0; i < addedTweets; i++) {
        indexPathes[i] = [NSIndexPath indexPathForRow:i inSection:0];
    }
    [tweetsTableView insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationFade];
}

@end
