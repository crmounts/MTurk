//
//  LocationTrackViewController.h
//  MTurk
//
//  Created by Connor R Mounts on 12/2/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface LocationTrackViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate>

@property(nonatomic) PFObject *object;

@end
