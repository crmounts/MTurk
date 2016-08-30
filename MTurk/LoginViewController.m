//
//  LoginViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 11/30/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "LoginViewController.h"
#import "CMDataManager.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) IBOutlet UITextField *emailField;

@property(nonatomic) CMDataManager *dataManager;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UIButton *signInButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataManager =[CMDataManager sharedManager];
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

- (IBAction)signUpPressed:(id)sender {
    [self buttonToggle];
    [_dataManager userSignUp:_usernameField.text withPass:_passwordField.text withEmail:_emailField.text completion:^(NSString *result) {
        if (result) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sign Up Error"
                                                                           message:result.capitalizedString
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self buttonToggle];
            
        } else {
            [self buttonToggle];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (IBAction)signInPressed:(id)sender {
    [self buttonToggle];
    [_dataManager userSignIn:_usernameField.text withPass:_passwordField.text completion:^(NSString *result) {
        if (result) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Sign In Error"
                                                                           message:result.capitalizedString
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            [self buttonToggle];
        } else {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            [self buttonToggle];
        }
    }];

}

- (void)buttonToggle {
    [_signInButton setEnabled:![_signUpButton isEnabled]];
    [_signUpButton setEnabled:![_signUpButton isEnabled]];
    if (_activityIndicator.isAnimating) {
        [_activityIndicator stopAnimating];
    } else {
        [_activityIndicator startAnimating];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
    [_emailField resignFirstResponder];
}


@end
