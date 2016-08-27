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
#pragma mark - Logut Button

- (IBAction)logout:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure you want to logout?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
            [HashTag resetShareTwitterAPI];
        }];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDestructive handler:nil];
    [alertController addAction:yesAction];
    [alertController addAction:noAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

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
    [searchBar setShowsCancelButton:YES];
    [searchBar resignFirstResponder];
    if ([hashTag isSearchEmpty:searchBar.text]){
        [self createAlertView:@"Search is empty"];
        return;
    }
    
    if (![hashTag isSearchIsHastag:searchBar.text]){
        [self createAlertView:@"hashtag need to start with '#'"];
        return;
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [hashTag searchHasTag:[searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [activityIndicator startAnimating];
        
        
    
    
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == hashTag.hasTags.count - 1){
        
        [hashTag searchForOldTweets];
    }
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
    [tweetsTableView setHidden:NO];
    [activityIndicator stopAnimating];
    [tweetsTableView reloadData];
    NSLog(@"search success");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

-(void)onSearchFail:(NSString *)error{
    [activityIndicator stopAnimating];
    NSLog(@"shearch fail");
    [self createAlertView:error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)onSearchUpdate:(NSInteger)addedTweets{
    
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:addedTweets];
    for (NSInteger i = 0; i < addedTweets; i++) {
        indexPathes[i] = [NSIndexPath indexPathForRow:i inSection:0];
    }
    [tweetsTableView insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationFade];
}

-(void)onSearchOldTweets:(NSInteger)addedTweets position:(NSInteger)position{
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:addedTweets];
    for (NSInteger i = 0; i < addedTweets; i++){
        indexPathes[i] = [NSIndexPath indexPathForRow:position inSection:0];
        position++;
    }
    [tweetsTableView insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationFade];
    
}



-(void)createAlertView:(NSString *) message{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Twitter Hashtags" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertView addAction:okAction];
    [self presentViewController:alertView animated:YES completion:nil];
}
@end
