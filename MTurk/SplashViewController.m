//
//  SplashViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 12/1/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "SplashViewController.h"
#import "CMDataManager.h"

@interface SplashViewController ()

@property (nonatomic) CMDataManager *dataManager;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [CMDataManager sharedManager];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([_dataManager isUserLoggedIn]) {
        [self performSegueWithIdentifier:@"loggedin" sender:self];
    } else {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
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

@end
