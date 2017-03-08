//
//  SearchTableViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/23/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SearchTableViewCell.h"
#import "UserViewController.h"
#import "BackendServices.h"

@interface SearchTableViewController ()

@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic) NSMutableArray *users;
@property (nonatomic) BackendServices *services;

@end

@implementation SearchTableViewController

#pragma Mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [self.searchController.searchBar setHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *username = searchController.searchBar.text;
    
    [self.services userByUsername:username completionBlock:^(KCSUser *user) {
        if (user != nil) {
            self.users = [NSMutableArray arrayWithObject:user];
        }
        
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    KCSUser *user = self.users[indexPath.row];
    [cell.usernameButton setTitle:user.username forState:UIControlStateNormal];
    [cell.fullNameLabel setText:[user getValueForAttribute:@"full name"]];
    
    NSString *profileImageId = [user getValueForAttribute:@"profile photo"];
    if (profileImageId) {
        [self.services photoById:profileImageId
                 completionBlock:^(UIImage *image) {
                     [cell.profilePhotoImageView setImage:image];
                 }];
    } else {
        [cell.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
    }
    
    cell.profilePhotoImageView.layer.cornerRadius = cell.profilePhotoImageView.frame.size.height / 2;
    cell.profilePhotoImageView.layer.masksToBounds = YES;
    cell.profilePhotoImageView.layer.borderWidth = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchController.searchBar setHidden:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SearchTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserViewController *uvc = [sb instantiateViewControllerWithIdentifier:@"User View Controller"];
    uvc.username = cell.usernameButton.titleLabel.text;
    
    [self.navigationController pushViewController:uvc animated:YES];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)users {
    if (!_users) {
        _users = [[NSMutableArray alloc] init];
    }
    
    return _users;
}

- (BackendServices *)services {
    if (!_services) {
        _services = [[BackendServices alloc] init];
    }
    
    return _services;
}

@end
