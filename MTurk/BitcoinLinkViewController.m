//
//  BitcoinLinkViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 12/2/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "BitcoinLinkViewController.h"
#import <Parse/Parse.h>
#import "CMDataManager.h"
#import "SettingsViewController.h"

@interface BitcoinLinkViewController ()
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *createButton;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *guidLabel;
@property (strong, nonatomic) IBOutlet UITextView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *addressTag;
@property (strong, nonatomic) IBOutlet UILabel *guidTag;

@property (nonatomic) CMDataManager *dataManager;

@end

@implementation BitcoinLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Create a Wallet";
    self.dataManager = [CMDataManager sharedManager];
    [_addressLabel setHidden:YES];
    [_guidLabel setHidden:YES];
    [_guidTag setHidden:YES];
    [_infoView setHidden:YES];
    [_addressTag setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createPressed:(id)sender {
    if (_passwordField.text.length >= 10) {
        [_dataManager createWallet:_passwordField.text completion:^(NSString *address, NSString *guid) {
            [_addressLabel setHidden:NO];
            [_guidLabel setHidden:NO];
            [_guidTag setHidden:NO];
            [_infoView setHidden:NO];
            [_addressTag setHidden:NO];
            _addressLabel.text = address;
            _guidLabel.text = guid;
            _passwordField.text = @"";
            [_passwordField setEnabled:NO];
            [_createButton setEnabled:NO];
        }];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Password No Good"
                                                                       message:@"You're password must be atleast 10 characters long"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_passwordField resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
