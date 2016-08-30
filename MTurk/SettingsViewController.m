//
//  SettingsViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 11/30/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "SettingsViewController.h"
#import "CMDataManager.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@property (nonatomic) CMDataManager *dataManager;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UIButton *linkedButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;
@property (strong, nonatomic) IBOutlet UIButton *balanceButton;
@property (nonatomic) NSTimer *timer;


@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [CMDataManager sharedManager];
    _userLabel.text = [@"u: " stringByAppendingString:[[PFUser currentUser] username]];
    if ([PFUser currentUser][@"address"] == NULL) {
        [_linkedButton setTitleColor:[UIColor redColor] forState:normal];
        [_balanceButton setEnabled:NO];
    } else {
        [self balanceUpdate];
    }
}

- (void)refresh {
    if ([PFUser currentUser][@"address"] == NULL) {
    } else {
        [_timer invalidate];
        [_linkedButton setTitleColor:[UIColor greenColor] forState:normal];
        [_balanceButton setEnabled:YES];
        [self balanceUpdate];
    }
}


- (IBAction)updateBalance:(id)sender {
    [self balanceUpdate];
}

-(void)balanceUpdate {
    [_activityIndicator startAnimating];
    [_balanceButton setEnabled:NO];
    [_dataManager getBalance:^(NSString *address,NSString *balance) {
        [_activityIndicator stopAnimating];
        [_balanceButton setEnabled:YES];
        _addressLabel.text = address;
        _balanceLabel.text = balance;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userLogOut:(id)sender {
    [_dataManager logOutUser];
    [self performSegueWithIdentifier:@"signout" sender:self];
}

- (IBAction)linkedButtonPressed:(id)sender {
    if ([_addressLabel.text isEqualToString:@""]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self selector:@selector(refresh) userInfo:nil repeats:YES];
        [self performSegueWithIdentifier:@"createWallet" sender:self];
    }
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
