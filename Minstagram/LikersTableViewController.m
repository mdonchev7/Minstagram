//
//  LikersTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/22/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "LikersTableViewController.h"
#import "LikerTableViewCell.h"
#import "Relation.h"
#import "UserViewController.h"
#import "BackendServices.h"

@interface LikersTableViewController ()

@property (nonatomic) NSMutableArray *likers;
@property (nonatomic) NSMutableArray *following;

@property (nonatomic) BackendServices *services;

@end

@implementation LikersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (NSString *username in self.post.likers) {
        [self.services userByUsername:username
                      completionBlock:^(KCSUser *user) {
            [self.likers addObject:user];
            [self.tableView reloadData];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.following removeAllObjects];
    [self fetchAllFollowing];
}

- (IBAction)followUnfollowUser:(UIButton *)sender {
    NSString *action = sender.titleLabel.text;
    
    if ([action isEqualToString:@"Follow"]) {
        Relation *relationToSave = [[Relation alloc] init];
        relationToSave.follower = [KCSUser activeUser].username;
        relationToSave.beingFollowed = ((LikerTableViewCell *)[[sender superview] superview]).usernameButton.titleLabel.text;
        
        [self.services saveRelation:relationToSave completionBlock:^(Relation *savedRelation) {
            [self.following addObject:relationToSave];
            [self.tableView reloadData];
        }];
    } else if ([action isEqualToString:@"Following"]) {
        NSString *userToUnfollow = ((LikerTableViewCell *)[[sender superview] superview]).usernameButton.titleLabel.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"follower = %@ AND beingFollowed = %@", [KCSUser activeUser].username, userToUnfollow];
        Relation *relationToDelete = [[self.following filteredArrayUsingPredicate:predicate] firstObject];
        
        [self.services deleteRelation:relationToDelete completionBlock:^{
            [self.following removeObject:relationToDelete];
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.likers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    KCSUser *user = self.likers[indexPath.row];
    [cell.usernameButton setTitle:user.username forState:UIControlStateNormal];
    [cell.fullNameLabel setText:[user getValueForAttribute:@"full name"]];
    [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
    cell.profilePhotoImageView.image = [UIImage imageNamed:@"user-default"];
    cell.profilePhotoImageView.layer.cornerRadius = cell.profilePhotoImageView.frame.size.height / 2;
    cell.profilePhotoImageView.layer.masksToBounds = YES;
    cell.profilePhotoImageView.layer.borderWidth = 0;
    
    cell.usernameButton.userInteractionEnabled = YES;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"beingFollowed = %@", user.username];
    NSArray *arr = [self.following filteredArrayUsingPredicate:predicate];
    
    if ([[KCSUser activeUser].username isEqualToString:user.username]) {
        [cell.followUnfollowButton setHidden:YES];
    } else if ([arr count] == 1) {
        [cell.followUnfollowButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [cell.followUnfollowButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helper Methods

- (void)fetchAllFollowing {
    [self.services followingByUsername:[KCSUser activeUser].username
                       completionBlock:^(NSArray *following) {
                           for (Relation *relation in following) {
                               [self.following addObject:relation];
                               [self.tableView reloadData];
                           }
    }];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)likers {
    if (!_likers) {
        _likers = [[NSMutableArray alloc] init];
    }
    
    return _likers;
}

- (NSMutableArray *)following {
    if (!_following) {
        _following = [[NSMutableArray alloc] init];
    }
    
    return _following;
}

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

#pragma mark - Navigation
- (IBAction)navigateToUserViewController:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = sender.titleLabel.text;
    
    [self.navigationController pushViewController:uvc animated:YES];
}

@end
