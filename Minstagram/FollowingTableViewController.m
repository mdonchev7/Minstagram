//
//  FollowingTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/11/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "FollowingTableViewController.h"
#import "BackendServices.h"
#import "Relation.h"
#import "FollowingTableViewCell.h"
#import "UserViewController.h"

@interface FollowingTableViewController ()

@property (nonatomic) BackendServices *services;
@property (nonatomic) NSMutableArray *users;
@property (nonatomic) NSMutableArray *following;

@end

@implementation FollowingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self.services followingByUsername:self.username
                       completionBlock:^(NSArray *following) {
                           for (Relation *relation in following) {
                               [self.services userByUsername:relation.beingFollowed
                                             completionBlock:^(KCSUser *user) {
                                                 [self.users addObject:user];
                                                 [self.tableView reloadData];
                                             }];
                           }
                       }];
    
    [self.services followingByUsername:[KCSUser activeUser].username
                       completionBlock:^(NSArray *following) {
                           for (Relation *relation in following) {
                               [self.following addObject:relation];
                           }
                       }];
}

- (IBAction)handleActionButtonTap:(UIButton *)sender {
    NSString *user = ((FollowingTableViewCell *)[[sender superview] superview]).usernameButton.titleLabel.text;
    
    [self.services relationByFollowerUsername:[KCSUser activeUser].username
                        beingFollowedUsername:user completionBlock:^(Relation *relation) {
                            if (relation == nil) {
                                Relation *relationToSave = [[Relation alloc] init];
                                relationToSave.follower = [KCSUser activeUser].username;
                                relationToSave.beingFollowed = user;
                                
                                [self.services saveRelation:relationToSave
                                            completionBlock:^(Relation *savedRelation) {
                                                [self.users addObject:savedRelation];
                                                [sender setTitle:@"Following" forState:UIControlStateNormal];
                                            }];
                            } else {
                                [self.services deleteRelation:relation
                                              completionBlock:^() {
                                                  [self.users removeObject:relation];
                                                  [sender setTitle:@"Follow" forState:UIControlStateNormal];
                                              }];
                            }
                        }];
}

- (IBAction)navigateToUserViewController:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = sender.titleLabel.text;
    [self showViewController:uvc sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    KCSUser *user = self.users[indexPath.row];
    
    [cell.usernameButton setTitle:user.username forState:UIControlStateNormal];
    [cell.fullNameLabel setText:[user getValueForAttribute:@"full name"]];
    
    cell.profilePhotoImageView.layer.cornerRadius = cell.profilePhotoImageView.frame.size.height / 2;
    cell.profilePhotoImageView.layer.masksToBounds = YES;
    cell.profilePhotoImageView.layer.borderWidth = 0;
    
    if (![[user getValueForAttribute:@"profile photo"] isEqualToString:@""]) {
        [self.services photoById:[user getValueForAttribute:@"profile photo"]
                 completionBlock:^(UIImage *image) {
                     [cell.profilePhotoImageView setImage:image];
                 }];
    } else {
        [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
    }
    
    if ([user.username isEqualToString:[KCSUser activeUser].username]) {
        [cell.actionButton setHidden:YES];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beingFollowed = %@", user.username];
        
        NSArray *arr = [self.following filteredArrayUsingPredicate:predicate];
        
        if ([arr count] == 1) {
            [cell.actionButton setTitle:@"Following" forState:UIControlStateNormal];
        } else {
            [cell.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    FollowingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = cell.usernameButton.titleLabel.text;
    
    [self.navigationController pushViewController:uvc animated:YES];
}

#pragma mark - Lazy Instantiation

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

- (NSMutableArray *)users {
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    
    return _users;
}

- (NSMutableArray *)following {
    if (!_following) {
        _following = [[NSMutableArray alloc] init];
    }
    
    return _following;
}

@end
