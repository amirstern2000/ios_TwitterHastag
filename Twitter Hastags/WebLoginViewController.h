//
//  WebLoginViewController.h
//  Twitter Hastags
//
//  Created by AmirStern on 25/08/2016.
//  Copyright © 2016 AmirStern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)cancel:(id)sender;
@end
