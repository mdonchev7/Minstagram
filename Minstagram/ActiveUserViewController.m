//
//  MyProfileViewController.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 10/10/16.
//  Copyright © 2016 Mincho Dzhagalov. All rights reserved.
//

#import "ActiveUserViewController.h"
#import "NSString+FontAwesome.h"
#import "ActiveUserProfileCollectionViewCell.h"
#import "Relation.h"
#import "DetailedPhotoViewController.h"
#import "FollowersTableViewController.h"
#import "FollowingTableViewController.h"
#import "UIImage+Resize.h"
#import "BackendServices.h"
#import "Minstagram-Swift.h"
#import "Repository.h"

@interface ActiveUserViewController () <FusumaDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) NSMutableArray *postIds;
@property (weak, nonatomic) NSMutableArray *posts;

@property (nonatomic) BackendServices *services;
@property (nonatomic) Repository *repository;

@end

@implementation ActiveUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightBarButtonItemIcon];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.navigationItem setTitle:[KCSUser activeUser].username];
    
    self.profilePhotoImageView.layer.cornerRadius = self.profilePhotoImageView.frame.size.height / 2;
    self.profilePhotoImageView.layer.masksToBounds = YES;
    self.profilePhotoImageView.layer.borderWidth = 0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSInteger numberOfPosts = [[[KCSUser activeUser] getValueForAttribute:@"posts"] count];
    self.numberOfPostsLabel.text = [NSString stringWithFormat:@"%li", (long)numberOfPosts];
    self.fullNameLabel.text = [[KCSUser activeUser] getValueForAttribute:@"full name"];
    self.postIds = [[KCSUser activeUser] getValueForAttribute:@"posts"];
    [self.collectionView reloadData];
    
    [self updateProfilePhotoImageView];
    
    [self.services followersByUsername:[KCSUser activeUser].username
                       completionBlock:^(NSArray *followers) {
                           self.numberOfFollowersLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[followers count]];
                       }];
    [self.services followingByUsername:[KCSUser activeUser].username
                       completionBlock:^(NSArray *following) {
                           self.numberOfFollowingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[following count]];
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
    ActiveUserProfileCollectionViewCell *cell =
    [self.collectionView dequeueReusableCellWithReuseIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ActiveUserProfileCollectionViewCell alloc] init];
    }
    
    cell.postId = self.postIds[indexPath.row];
    
    cell.imageView.image = nil;
    
    [self.repository thumbnailByPostId:self.postIds[indexPath.row] completionBlock:^(UIImage *thumbnail) {
        [cell.imageView setImage:thumbnail];
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(screenWidth / 3 - 1, screenWidth / 3 - 1);
    
    return size;
}

- (IBAction)editProfile:(UIButton *)sender {
    NSLog(@"present edit profile view controller");
}

- (void)navigateToOptionsViewController {
    [self performSegueWithIdentifier:@"Present Edit Profile View Controller" sender:self];
}

- (void)updateProfilePhotoImageView {
    NSString *photoId = [[KCSUser activeUser] getValueForAttribute:@"profile photo"];
    if (photoId) {
        [self.services photoById:photoId
                 completionBlock:^(UIImage *image) {
                     [self.profilePhotoImageView setImage:image];
                 }];
    } else {
        [self.profilePhotoImageView setImage:[UIImage imageNamed:@"user-default"]];
    }
}

- (void)setRightBarButtonItemIcon {
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithTitle:@"Cog"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(navigateToOptionsViewController)];
    [button setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"FontAwesome" size:26.0],
                                     NSForegroundColorAttributeName:[UIColor darkGrayColor]}
                          forState:UIControlStateNormal];
    [button setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-cog"]];
    self.navigationItem.rightBarButtonItem = button;
}

- (IBAction)handleProfileImageImageViewTap:(UITapGestureRecognizer *)sender {
    FusumaViewController *fvc = [[FusumaViewController alloc] init];
    fvc.delegate = self;
    fvc.hasVideo = NO;
    [self presentViewController:fvc animated:YES completion:nil];
}

#pragma mark - Fusuma delegate methods

- (void)fusumaCameraRollUnauthorized {
    
}

- (void)fusumaVideoCompletedWithFileURL:(NSURL *)fileURL {
    // video is not supported
}

- (void)fusumaClosed {
    
}

- (void)fusumaImageSelected:(UIImage *)image {
    CGSize size = CGSizeMake(80.0f, 80.0f);
    UIImage *resizedImage = [UIImage imageWithImage:image scaledToSize:size];
    
    KCSMetadata *metaData = [[KCSMetadata alloc] init];
    [metaData setGloballyReadable:YES];
    
    [self.services uploadPhoto:resizedImage
                   withOptions:@{KCSFileACL: metaData}
               completionBlock:^(KCSFile *uploadInfo) {
                   [[KCSUser activeUser] setValue:[uploadInfo fileId] forAttribute:@"profile photo"];
                   [[KCSUser activeUser] saveWithCompletionBlock:^(NSArray *objects, NSError *error) {
                       if (error == nil) {
                           [self updateProfilePhotoImageView];
                       } else {
                           NSLog(@"error: %@", error);
                       }
                   }];
               }];
}

- (void)fusumaDismissedWithImage:(UIImage *)image {
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Navigate To Detailed Photo View Controller From Active User View Controller"]) {
        DetailedPhotoViewController *dpvc = [segue destinationViewController];
        dpvc.postId = ((ActiveUserProfileCollectionViewCell *)sender).postId;
        dpvc.username = [KCSUser activeUser].username;
    }
}

- (IBAction)navigateToFollowersTableViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowersTableViewController *ftvc = [sb instantiateViewControllerWithIdentifier:@"Followers Table View Controller"];
    
    ftvc.username = [KCSUser activeUser].username;
    
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (IBAction)navigateToFollowingTableViewController:(UITapGestureRecognizer *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowingTableViewController *ftvc = [sb instantiateViewControllerWithIdentifier:@"Following Table View Controller"];
    
    ftvc.username = [KCSUser activeUser].username;
    
    [self.navigationController pushViewController:ftvc animated:YES];
}

#pragma mark - Lazy Instantiation

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
