//
//  WebLoginViewController.m
//  Twitter Hastags
//
//  Created by MediaHosting LTD on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import "WebLoginViewController.h"

@interface WebLoginViewController ()

@end

@implementation WebLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}
@end
