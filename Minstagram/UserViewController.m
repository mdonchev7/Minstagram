//
//  UserViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 11/23/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "UserViewController.h"
#import "Relation.h"
#import "UserProfileCollectionViewCell.h"
#import "DetailedPhotoViewController.h"
#import "FollowersTableViewController.h"
#import "FollowingTableViewController.h"
#import "BackendServices.h"

#import <KinveyKit/KinveyKit.h>

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followFollowingButton;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) KCSUser *user;
@property (nonatomic) NSMutableArray *postIds;
@property (nonatomic) NSMutableArray *following;
@property (nonatomic) BackendServices *services;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.navigationItem setTitle:self.username];
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
    
    [self.services userByUsername:self.username completionBlock:^(KCSUser *user) {
        self.user = user;
        self.postIds = [user getValueForAttribute:@"posts"];
        [self.fullNameLabel setText:[user getValueForAttribute:@"full name"]];
        [self.collectionView reloadData];
        
        [self.services photoById:[user getValueForAttribute:@"profile photo"]
                 completionBlock:^(UIImage *image) {
                     [self.profilePhotoImageView setImage:image];
                 }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self fetchAllFollowing];
    
    if ([[[KCSUser activeUser] username] isEqualToString:self.username]) {
        [self.followFollowingButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    }
    
    [self updateFollowersCount];
    [self updateFollowingCount];
}

- (IBAction)followUnfollowUser:(UIButton *)sender {
    [self.services relationByFollowerUsername:[KCSUser activeUser].username beingFollowedUsername:self.username completionBlock:^(Relation *relation) {
        if (relation == nil) {
            Relation *relationToSave = [[Relation alloc] init];
            relationToSave.follower = [KCSUser activeUser].username;
            relationToSave.beingFollowed = self.username;
            
            [self.services saveRelation:relationToSave completionBlock:^(Relation *savedRelation) {
                [self.following addObject:savedRelation];
                [self.followFollowingButton setTitle:@"Following" forState:UIControlStateNormal];
                [self updateFollowersCount];
            }];
        } else {
            [self.services deleteRelation:relation
                          completionBlock:^{
                              [self.following removeObject:relation];
                              [self.followFollowingButton setTitle:@"Follow" forState:UIControlStateNormal];
                              [self updateFollowersCount];
                          }];
        }
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.postIds count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserProfileCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    cell.postId = self.postIds[indexPath.row];
    
    [self.services postById:self.postIds[indexPath.row] completionBlock:^(Post *post) {
        [self.services photoById:post.photoId
                 completionBlock:^(UIImage *image) {
                     [cell.imageView setImage:image];
                 }];
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(screenWidth / 3 - 1, screenWidth / 3 - 1);
    
    return size;
}

- (void)fetchAllFollowing {
    [self.services followingByUsername:[KCSUser activeUser].username completionBlock:^(NSArray *following) {
        for (Relation *relation in following) {
            [self.following addObject:relation];
            
            if (![self.followFollowingButton isEnabled] && [relation.beingFollowed isEqualToString:self.username]) {
                [self.followFollowingButton setTitle:@"Following" forState:UIControlStateNormal];
                [self.followFollowingButton setEnabled:YES];
            }
        }
        
        if (![self.followFollowingButton isEnabled]) {
            [self.followFollowingButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.followFollowingButton setEnabled:YES];
        }
    }];
}

- (void)updateFollowersCount {
    [self.services followersByUsername:self.username
                       completionBlock:^(NSArray *followers) {
                           self.followersCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[followers count]];
                       }];
}

- (void)updateFollowingCount {
    [self.services followingByUsername:self.username
                       completionBlock:^(NSArray *following) {
                           self.followingCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[following count]];
                       }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Navigate To Detailed Photo View Controller From User View Controller"]) {
        DetailedPhotoViewController *dpvc = [segue destinationViewController];
        dpvc.postId = ((UserProfileCollectionViewCell *)sender).postId;
        dpvc.username = self.username;
    }
}

- (IBAction)navigateToFollowersTableViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowersTableViewController *ftvc = [sb instantiateViewControllerWithIdentifier:@"Followers Table View Controller"];
    
    ftvc.username = self.username;
    
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (IBAction)navigateToFollowingTableViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowingTableViewController *ftvc = [sb instantiateViewControllerWithIdentifier:@"Following Table View Controller"];
    
    ftvc.username = self.username;
    
    [self.navigationController pushViewController:ftvc animated:YES];
}

#pragma Mark - Lazy Instantiation

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

@end
