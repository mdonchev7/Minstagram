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
#import "OptionsTableViewController.h"
#import "Repository.h"

#import <KinveyKit/KinveyKit.h>

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) KCSUser *user;
@property (nonatomic) NSMutableArray *postIds;
@property (nonatomic) NSMutableArray *following;

@property (nonatomic) BackendServices *services;
@property (nonatomic) Repository *repository;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.navigationItem setTitle:self.username];
    
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
    
    [self.services userByUsername:self.username
                  completionBlock:^(KCSUser *user) {
                      self.user = user;
                      
                      self.postIds = [user getValueForAttribute:@"posts"];
                      [self.postsCountLabel setText:[NSString stringWithFormat:@"%lu", (unsigned long)[self.postIds count]]];
                      [self.fullNameLabel setText:[user getValueForAttribute:@"full name"]];
                      [self.collectionView reloadData];
                      
                      NSString *photoId = [user getValueForAttribute:@"profile photo"];
                      if ([photoId isEqualToString:@""]) {
                          [self.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
                      } else {
                          [self.services photoById:photoId
                                   completionBlock:^(UIImage *image) {
                                       [self.profilePhotoImageView setImage:image];
                                   }];
                      }
                  }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[KCSUser activeUser].username isEqualToString:self.username]) {
        [self fetchAllFollowing];
    } else {
        [self.actionButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
        [self.actionButton setEnabled:YES];
    }
    
    [self updateFollowersCount];
    [self updateFollowingCount];
}

- (IBAction)handleActionButtonTap:(UIButton *)sender {
    if ([[KCSUser activeUser].username isEqualToString:self.username]) {
        NSLog(@"present edit profile view controller");
    } else {
        [self.services relationByFollowerUsername:[KCSUser activeUser].username
                            beingFollowedUsername:self.username
                                  completionBlock:^(Relation *relation) {
                                      if (relation == nil) {
                                          Relation *relationToSave = [[Relation alloc] init];
                                          relationToSave.follower = [KCSUser activeUser].username;
                                          relationToSave.beingFollowed = self.username;
                                          
                                          [self.services saveRelation:relationToSave completionBlock:^(Relation *savedRelation) {
                                              [self.following addObject:savedRelation];
                                              [self.actionButton setTitle:@"Following" forState:UIControlStateNormal];
                                              [self updateFollowersCount];
                                          }];
                                      } else {
                                          [self.services deleteRelation:relation
                                                        completionBlock:^{
                                                            [self.following removeObject:relation];
                                                            [self.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
                                                            [self updateFollowersCount];
                                                        }];
                                      }
                                  }];
    }
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
    
    [self.repository thumbnailByPostId:self.postIds[indexPath.row]
                       completionBlock:^(UIImage *thumbnail) {
                           [cell.imageView setImage:thumbnail];
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
    [self.services followingByUsername:[KCSUser activeUser].username
                       completionBlock:^(NSArray *following) {
                           for (Relation *relation in following) {
                               [self.following addObject:relation];
                               
                               if (![self.actionButton isEnabled] &&
                                   [relation.beingFollowed isEqualToString:self.username]) {
                                   [self.actionButton setTitle:@"Following" forState:UIControlStateNormal];
                                   [self.actionButton setEnabled:YES];
                               }
                           }
                           
                           if (![self.actionButton isEnabled]) {
                               [self.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
                               [self.actionButton setEnabled:YES];
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

- (void)handleRightSwipe:(UISwipeGestureRecognizer *)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
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

- (Repository *)repository {
    if (!_repository) {
        _repository = [[Repository alloc] init];
    }
    
    return _repository;
}

@end
