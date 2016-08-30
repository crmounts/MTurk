//
//  ImageLabelingViewController.h
//  MTurk
//
//  Created by Connor R Mounts on 11/30/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageLabelingViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) PFObject *object;


@end
