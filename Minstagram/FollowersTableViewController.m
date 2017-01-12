//
//  FollowersTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 12/11/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "FollowersTableViewController.h"
#import "UserViewController.h"
#import "BackendServices.h"
#import "FollowerTableViewCell.h"
#import "Relation.h"

@interface FollowersTableViewController ()

@property (nonatomic) NSMutableArray *followers;
@property (nonatomic) NSMutableArray *following;
@property (nonatomic) BackendServices *services;

@end

@implementation FollowersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self.services followersByUsername:self.username
                       completionBlock:^(NSArray *followers) {
                           for (Relation *relation in followers) {
                               [self.services userByUsername:relation.follower
                                             completionBlock:^(KCSUser *user) {
                                                 [self.followers addObject:user];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.followers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell"
                                                                  forIndexPath:indexPath];
    
    KCSUser *user = self.followers[indexPath.row];
    
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

- (IBAction)handleActionButtonTap:(UIButton *)sender {
    NSString *followerUsername = ((FollowerTableViewCell *)[[sender superview] superview]).usernameButton.titleLabel.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beingFollowed = %@", followerUsername];
    Relation *relationToDelete = [[self.following filteredArrayUsingPredicate:predicate] firstObject];
    
    if (relationToDelete == nil) {
        Relation *relationToSave = [[Relation alloc] init];
        relationToSave.follower = [KCSUser activeUser].username;
        relationToSave.beingFollowed = followerUsername;
        
        [self.services saveRelation:relationToSave
                    completionBlock:^(Relation *savedRelation) {
                        [self.following addObject:savedRelation];
                        [sender setTitle:@"Following" forState:UIControlStateNormal];
                    }];
    } else {
        [self.services deleteRelation:relationToDelete
                      completionBlock:^() {
                          [self.following removeObject:relationToDelete];
                          [sender setTitle:@"Follow" forState:UIControlStateNormal];
                      }];
    }
}

- (IBAction)navigateToUserViewController:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = sender.titleLabel.text;
    [self showViewController:uvc sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Navigation

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)followers {
    if (!_followers) {
        _followers = [[NSMutableArray alloc] init];
    }
    
    return _followers;
}

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

- (NSMutableArray *)following {
    if (!_following) {
        _following = [[NSMutableArray alloc] init];
    }
    
    return _following;
}

@end
