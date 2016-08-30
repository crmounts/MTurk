//
//  TableViewController.m
//  MTurk
//
//  Created by Connor R Mounts on 11/30/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "TableViewController.h"
#import "CMDataManager.h"
#import <Parse/Parse.h>
#import "ImageLabelingViewController.h"
#import "LocationTrackViewController.h"

@interface TableViewController ()

@property(nonatomic) CMDataManager *dataManager;
@property(nonatomic) NSMutableArray *tasks;
@property(nonatomic) PFObject *currentlySelected;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dataManager = [CMDataManager sharedManager];
    self.tableView.contentInset = UIEdgeInsetsMake(65,0,0,0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _tasks = [[NSMutableArray alloc] init];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![_dataManager isUserLoggedIn]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _currentlySelected = [_tasks objectAtIndex:indexPath.row];
    NSString *identifier = [_currentlySelected objectForKey:@"type"];
    [self performSegueWithIdentifier:identifier sender:self];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasks.count;
}

-(void)loadData {
    PFQuery *query = [PFQuery queryWithClassName:@"Task"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *task in objects) {
                if (![self.tasks containsObject:task]) {
                    [self.tasks addObject:task];
                }
            }
            [self.tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:0];
    PFObject *task = [self.tasks objectAtIndex:indexPath.row];
    label.text = [task objectForKey:@"title"];
    
    return cell;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imageLabeling"]) {
        ImageLabelingViewController *view = (ImageLabelingViewController *)segue.destinationViewController;
        view.object = _currentlySelected;
    } else if ([segue.identifier isEqualToString:@"locationTracking"]) {
        LocationTrackViewController *view = (LocationTrackViewController *)segue.destinationViewController;
        view.object = _currentlySelected;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
