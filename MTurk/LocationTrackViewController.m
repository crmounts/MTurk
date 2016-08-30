//
//  LocationTrackViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 12/2/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "LocationTrackViewController.h"
#import <MapKit/Mapkit.h>
#import "CMDataManager.h"

@interface LocationTrackViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSMutableArray *locations;

@property CMDataManager *dataManager;
@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *trackingButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation LocationTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [CMDataManager sharedManager];
    _locationManager = [[CLLocationManager alloc] init];
    _locations = [[NSMutableArray alloc] init];
    [_locationManager requestAlwaysAuthorization];
    self.navigationItem.title = [_object objectForKey:@"title"];
    _descriptionView.text = [_object objectForKey:@"description"];
    MKCoordinateRegion region = MKCoordinateRegionMake([_locationManager location].coordinate, MKCoordinateSpanMake(.005f, .005f));
    [_mapView setRegion:region];
    [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [_timer invalidate];
    _startDate = nil;
    _endDate = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startTrackingPressed:(id)sender {
    [_activityIndicator startAnimating];
    [_trackingButton setEnabled:NO];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                              target:self selector:@selector(checkCompletion) userInfo:nil repeats:YES];
    _startDate = [NSDate date];
    _endDate = [NSDate dateWithTimeInterval:[_object[@"numToComplete"] doubleValue] * 60.0 sinceDate:_startDate];
}

- (void)checkCompletion {
    NSDate *current = [NSDate date];
    if ([current compare:_endDate] == NSOrderedDescending) {
        [_activityIndicator stopAnimating];
        [_timer invalidate];
        _progressLabel.text = @"%100";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Task Complete"
                                                                       message:@"Upload Data to Receive Funds"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Upload" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self uploadData];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        CLLocation *currentLoc = [_locationManager location];
        [_locations addObject:currentLoc];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:currentLoc.coordinate];
        [self.mapView addAnnotation:annotation];
        NSString *string = @"%";
        double percent = ([current timeIntervalSince1970] - [_startDate timeIntervalSince1970]) / ([_endDate timeIntervalSince1970] - [_startDate timeIntervalSince1970]) * 100;
        _progressLabel.text = [string stringByAppendingString:[NSString stringWithFormat:@"%.2f",percent]];
    }
}

- (void)uploadData {
    [_activityIndicator startAnimating];
    PFObject *track = [PFObject objectWithClassName:@"LocationTrack"];
    
    for (CLLocation *loc in _locations) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSNumber numberWithDouble:loc.coordinate.latitude] forKey:@"latitude"];
        [dict setValue:[NSNumber numberWithDouble:loc.coordinate.longitude] forKey:@"longitude"];
        [dict setValue:[NSNumber numberWithDouble:loc.altitude] forKey:@"altitude"];
        [dict setValue:[NSNumber numberWithDouble:[loc.timestamp timeIntervalSince1970]] forKey:@"time"];
        [dict setValue:[NSNumber numberWithDouble:loc.speed] forKey:@"speed"];         
        [track addObject:dict forKey:@"locations"];
    }
    
    [track saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [_trackingButton setEnabled:YES];
        [_activityIndicator stopAnimating];
        [_locations removeAllObjects];
        [_mapView removeAnnotations:_mapView.annotations];
        _progressLabel.text = @"";
        if (!error) {
            [_dataManager transfer:_object[@"payout"] completion:^(NSString *result) {
                [_activityIndicator stopAnimating];
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Successful Upload!"
                                                                               message:@"Funds have been transferred!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }];
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Upload Error"
                                                                           message:@"There was a problem uploading your location data."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                  }];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
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
