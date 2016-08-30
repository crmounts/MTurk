//
//  ImageLabelingViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 11/30/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "ImageLabelingViewController.h"
#import <Parse/Parse.h>
#import "CMDataManager.h"


@interface ImageLabelingViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *imageLableField;
@property (strong, nonatomic) IBOutlet UILabel *taskProgressLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionView;
@property NSNumber *completed;
@property NSNumber *required;
@property (nonatomic) PFObject *progReport;
@property (nonatomic) PFUser *user;
@property (strong, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) IBOutlet UIButton *choosePhotoButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) CMDataManager *dataManager;


@end

@implementation ImageLabelingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataManager = [CMDataManager sharedManager];
    self.navigationItem.title = [_object objectForKey:@"title"];
    _descriptionView.text = [_object objectForKey:@"description"];
    
    _user = [PFUser currentUser];
    _completed = @0;
    _required = [_object objectForKey:@"numToComplete"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ProgReport"];
    [query whereKey:@"user" equalTo:_user.username];
    [query whereKey:@"taskID" equalTo:[_object objectId]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            _progReport = object;
            _completed = [_progReport objectForKey:@"completed"];
            _taskProgressLabel.text = [NSString stringWithFormat:@"%@/%@",_completed,_required];
            if ([_completed isEqualToNumber:_required]) {
                _taskProgressLabel.text = @"Completed!";
                [_uploadButton setEnabled:NO];
                [_takePhotoButton setEnabled:NO];
                [_choosePhotoButton setEnabled:NO];
                [_imageLableField setEnabled:NO];
            }
        } else {
            _taskProgressLabel.text = [NSString stringWithFormat:@"%@/%@",_completed,_required];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)choosePhoto:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}


- (IBAction)takePhoto:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_imageLableField resignFirstResponder];
}

- (IBAction)uploadImage:(id)sender {
    if (_imageView.image == NULL || [_imageLableField.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Incomplete Info"
                                                                       message:@"You need to have an image and label to upload"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if (_progReport == NULL) {
            [_activityIndicator startAnimating];
            [_uploadButton setEnabled:NO];
            [_takePhotoButton setEnabled:NO];
            [_choosePhotoButton setEnabled:NO];
            [_imageLableField setEnabled:NO];
            _progReport = [PFObject objectWithClassName:@"ProgReport"];
            _progReport[@"completed"] = @0;
            _progReport[@"taskID"] = [_object objectId];
            _progReport[@"user"] = _user.username;
            _progReport[@"complete"] = @NO;
            [_progReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [self imageUploadHelper];
                } else {
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Problem Uploading"
                                                                                   message:[error userInfo][@"error"]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }

            }];
        } else {
            [self imageUploadHelper];
        }
    }
}

- (void)imageUploadHelper {
    [_activityIndicator startAnimating];
    [_uploadButton setEnabled:NO];
    [_takePhotoButton setEnabled:NO];
    [_choosePhotoButton setEnabled:NO];
    [_imageLableField setEnabled:NO];
    NSData* data = UIImageJPEGRepresentation(_imageView.image, 0.95f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    PFObject *labeledImage = [PFObject objectWithClassName:@"LabeledImage"];
    labeledImage[@"image"] = imageFile;
    labeledImage[@"label"] = _imageLableField.text;
    labeledImage[@"tag"] = [_object objectForKey:@"tag"];
    [labeledImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [_progReport setObject:[NSNumber numberWithInt:([[_progReport objectForKey:@"completed"] intValue] + 1)] forKey:@"completed"];
            [_progReport save];
            _completed = [_progReport objectForKey:@"completed"];
            NSString *progress = [NSString stringWithFormat:@"%@/%@",_completed,_required];
            if ([_completed isEqualToNumber:_required]) {
                _progReport[@"complete"] = @YES;
                [_progReport save];
                progress = @"Task Complete - Funds Transferred";
                [_uploadButton setEnabled:NO];
                [_dataManager transfer:_object[@"payout"] completion:^(NSString *result) {
                    [_activityIndicator stopAnimating];
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Successful Upload"
                                                                                   message:progress
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    _taskProgressLabel.text = progress;
                    _imageView.image = nil;
                    _imageLableField.text = @"";
                }];
            } else {
                [_activityIndicator stopAnimating];
                [_uploadButton setEnabled:YES];
                [_takePhotoButton setEnabled:YES];
                [_choosePhotoButton setEnabled:YES];
                [_imageLableField setEnabled:YES];
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Successful Upload"
                                                                               message:progress
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                _taskProgressLabel.text = progress;
                _imageView.image = nil;
                _imageLableField.text = @"";
            }
        } else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Problem Uploading"
                                                                           message:[error userInfo][@"error"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:^(void){}];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:^(void) {}];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated: YES completion:^{
    }];
    return YES;
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
